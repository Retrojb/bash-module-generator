#!/bin/bash

source utils.sh
# DESCRIPTION
# Script to create a monorepo environment fully configured but not nearly as bloated
# as a npx create-turbo@latest or npx create-lerna@latest
# Grant the user a way to add and setup base configuration for common tools
# in a javascript monorepo.
#
# Author: John "JB" Baltes (retrojb)
# Created: 12/02/2023
# Last Modified: 12/20/2023



####################################################################################
### Utils
####################################################################################
# Script current scope is creating React / React Native monorepos
NPM_DEP_ARR=("react" "react-native" "react-dom" "react-native-web" "react-native-svg")
NPM_DEV_DEP_ARR=("")

add_to_dep_arr() {
    NPM_DEP_ARR+=("$@")
}

add_to_dev_dep_arr() {
    NPM_DEV_DEP_ARR+=("$@")
}

#TODO: Add changeset, add rollup option, changeset, commit linting
CONFIG_OPTIONS=("AuditCI" "BuilderBob" "ESLint" "Prettier" "Turbo" "Lerna" "GithubActions")
CONFIG_CHOICES=()



####################################################################################
### Steak and Potatoes
####################################################################################

# Allows user to set the file case of the directory and files
# PascalCasing - package.json will not reflect this casing.
# Kebab-Casing
# TODO: Add snake_casing and camelCasing
set_file_case() {
    file_casings=("Pascal" "Kebab")
    print_question "What casing would you like to use for directory & file structure"
    select file_casing in "${file_casings[@]}"; do
        case $file_casing in
            "Pascal")
                PACKAGE_NAME=$(convert_to_pascal_case "$MODULE_NAME")
                break
                ;;
            "Kebab")
                PACKAGE_NAME=$(convert_to_kebab_case "$MODULE_NAME")
                break
                ;;
            *)
                print_red "Invalid choice \n"
                ;;
        esac
    done
}

# Create the root of the monorepo
create_project_root() {
    mkdir "$PACKAGE_NAME"
    print_green "Creating $PACKAGE_NAME \n"
    # shellcheck disable=SC2164
    cd "$PACKAGE_NAME"
    mkdir apps
    mkdir bin
    mkdir packages
    mkdir packages/utils
}


# Create module structure
create_module_structure() {
    mkdir "$PACKAGE_NAME"
    cd "$PACKAGE_NAME" || exit


#    touch src/index.${LANGUAGE}
#    print_white "created src/index.${LANGUAGE} \n"
#    touch src/$PACKAGE_NAME.${LANGUAGE}x
#    print_white "created src/$PACKAGE_NAME.${LANGUAGE}x \n"
#    touch src/${PACKAGE_NAME}Props.${LANGUAGE}x
#    print_white "created src/${PACKAGE_NAME}Props.${LANGUAGE}x \n "
#    print_green "\t Successfully created $PACKAGE_NAME \n"
}

#  Select the dependency manager and then drill into manager setup choices
# NPM currently barebones setup
# Support for yarn classic and yarn berry
# TODO: add PNPM
set_dep_manager() {
    dep_man_choices=("NPM" "Yarn")
    print_question "Please select a Package Manager: "
    select dep_man_choice in "${dep_man_choices[@]}"; do
        case $dep_man_choice in
            "NPM")
                create_project_root
                set_language
                run_npm_setup
                break
                ;;
            "Yarn")
                create_project_root
                set_language
                run_yarn_setup
                break
                ;;
            *)
                print_red "Invalid Choice \n"
                ;;
        esac
    done

DEP_MANAGER=$dep_man_choice
}

# TODO: Finalize the NPM setup
run_npm_setup() {
    print_purple "Setting up NPM"
    print_blue "Follow the NPM setup"
    npm init
}

run_yarn_setup() {
    print_purple "\n Setting up Yarn \n"
    set_yarn_version
    yarn init
}

set_yarn_version() {
    dep_version_choices=("Classic" "Berry")
    print_question "Please select a Package Manager:"
    select dep_version_choice in "${dep_version_choices[@]}"; do
        case $dep_version_choice in
            "Classic")
                print_success "$dep_version_choice \n"
                break
                ;;
            "Berry")
                print_green "$dep_version_choice \n"
                print_question "Use PnP? [y/N]: "
                read -r use_pnp
                if [[ $use_pnp == 'N' || $use_pnp == 'n' ]]; then
                  set_yarn_berry
                  break
                else
                  yarn set version stable
                  break
                fi
                ;;
            *)
                print_red "Invalid Choice"
                ;;
        esac
    done

DEP_VERSION=$dep_version_choice
}

# TODO: Allow the PnP be an option to use nodeLinker
set_yarn_berry() {
yarn set version stable
touch .yarnrc.yml
cat > .yarnrc.yml << EOF
    nodeLinker: node-modules
EOF
}

# Set the repos JS flavor and create any required configurations
set_language() {
    language_choices=("Javascript" "Typescript")
    print_question "Please select a language: "
    select language_choice in "${language_choices[@]}"; do
        case $language_choice in
            "Javascript")
                LANGUAGE="js"
                break
                ;;
            "Typescript")
                LANGUAGE="ts"
                create_tsconfig
                break
                ;;
            *)
                ;;
        esac
    done
}

# TODO: Once module creation script is built update this
set_module_type() {
    module_type_choices=("React Component" "React Component with Storybook" "Utility Module")
    print_question "Please select a Package Manager:"
    select dep_man_choice in "${dep_man_choices[@]}"; do
        case $dep_man_choice in
            "React Component")
                print_blue "$dep_man_choice \n"
                break
                ;;
            "React Component with Storybook")
                print_blue "$dep_man_choice \n"
                break
                ;;
            "Utility Module")
                print_blue "$dep_man_choice \n"
                break
                ;;
            *)
                print_red "Invalid Choice \n"
                ;;
        esac
    done

DEP_MANAGER=$dep_man_choice
}

####################################################################################
### Configurations Setup
####################################################################################
select_options() {
    print_question "Select configurations (enter the number of each option, separated by spaces):"

    # Display options
    for i in "${!CONFIG_OPTIONS[@]}"; do
        printf "%s) %s\n" "$((i + 1))" "${CONFIG_OPTIONS[$i]}"
    done
    read -ra SELECTED_OPTIONS
    for option in "${SELECTED_OPTIONS[@]}"; do
        CONFIG_CHOICES+=("${CONFIG_OPTIONS[$((option - 1))]}")
    done
}

confirm_selections() {
    for choice in "${CONFIG_CHOICES[@]}"; do
        if [[ "$choice" == "AuditCI" ]]; then
          print_blue "Creating Audit CI config \n"
          add_to_dev_dep_arr "audit-ci"
          sleep 1
          create_auditci
        elif [[ "$choice" == "Turbo" ]]; then
          print_blue "Adding Turbo monorepo support"
          add_to_dev_dep_arr "turbo"
          sleep 1
          create_turbo
        elif [[ "$choice" == "BuilderBob" ]]; then
           print_blue "Adding Turbo monorepo support"
          add_to_dev_dep_arr "react-native-builder-bob"
        elif [[ "$choice" == "ESLint" ]]; then
           print_blue "Adding eslint"
          add_to_dev_dep_arr "eslint"
          create_eslint
        elif [[ "$choice" == "Prettier" ]]; then
           print_blue "Adding prettier"
          add_to_dev_dep_arr "prettier"
          create_prettier
        elif [[ "$choice" == "GithubActions" ]]; then
           print_blue "Adding Github Actions"
          create_gh_actions
        elif [[ "$choice" == "Lerna" ]]; then
          print_blue "Adding Lerna monorepo support"
          add_to_dev_dep_arr "lerna"
          create_lerna
        fi

         print_blue "Finished adding project configurations \n"
    done
}

set_configs() {
  select_options
  confirm_selections
}

# IF $LANGUAGE = 'ts'
create_tsconfig() {
add_to_dev_dep_arr "typescript"
touch tsconfig.json
cat > tsconfig.json <<EOF
{
    "compilerOptions": {
        "allowJs": true,
        "strict": true,
        "allowImportingTsExtensions": true,
        "skipLibCheck": true,
        "baseUrl": ".",
        "paths": {
            "apps/*": ["apps/*"],
            "packages/utils/*": ["utils/*"]
        }
    },
    "exclude": ["node_modules", "lib", "dist"]
}
EOF
}

# IF $choices == 'auditci'
create_auditci() {
touch audit-ci.jsonc
cat > audit-ci.jsonc <<EOF
 {
    "\$schema": "https://github.com/IBM/audit-ci/raw/main/docs/schema.json",
    "moderate": true,
    "registry": "https://registry.npmjs.org"
  }
EOF
}

# IF $choices == 'turbo'
create_turbo() {
touch turbo.json
cat > turbo.json <<EOF
{
	"\$schema": "https://turbo.build/schema.json",
	"globalDependencies": ["**/.env.*local"],
	"pipeline": {
		"build": {
			"dependsOn": ["^build"],
			"outputs": ["lib/", "dist/"],
			"cache": false
		},
		"lint": {},
		"pack:foo": {
			"dependsOn": ["^build"]
		},
		"dev": {
			"cache": false,
			"persistent": true
		}
	}
}
EOF
}

#TODO: Setup eslint
create_eslint() {
  print_white "$choice - Creating $choice"
}

create_prettier() {
touch .prettierrc
cat >> .prettierrc <<EOT
{
	"quoteProps": "consistent",
	"singleQuote": true,
	"trailingComma": "es5",
	"tabWidth": 2
}

EOT
}

# TODO: Setup lerna support
create_lerna() {
  print_white "$choice - Creating $choice"
}

create_npmignore() {
cat >> .npmignore <<EOT
apps/
bin/
.github/
.idea/
.turbo/
.yarn/
.editorconfig
.npmrc
.yarnrc.yml
audit-ci.jsonc
turbo.json
EOT
}
# TODO: continue GHA setup
create_gh_actions() {
  mkdir .github
  touch .github/main.yml
  mkdir .github/workflows
  touch .github/workflows/pullrequest.yml
}

#TODO: move this create into the create modules
# This will only be used in packages.
create_builder_bob() {
cat>> package.json <<EOF
    "react-native-builder-bob": {
        "source": "src",
        "output": "lib",
        "targets": [
        "commonjs",
        "module",
        [
            "typescript",
            {
            "tsc": "../../../node_modules/.bin/tsc"
            }
        ]
        ]
    }
}
EOF
}

modify_package_json() {
yarn_version=$(yarn -v)
cat > package.json <<EOF
   {
    "name": "${PACKAGE_NAME_KEBAB}",
    "description": "${PACKAGE_NAME_KEBAB}",
    "version": "0.0.1",
    "packageManager": "yarn@${yarn_version}",
    "license": "UNLICENSED",
    "private": true,
    "workspaces": [
        "apps/*",
        "packages/*"
    ],
    "main": "lib/commonjs/index.js",
    "module": "lib/module/index.js",
    "react-native": "src/index.ts",
    "types": "lib/typescript/index.d.ts",
    "source": "index.ts",
    "publishConfig": {
        "access": "public"
    },
    "files": [
        "lib",
        "src"
    ],
    "scripts": {
        "build": "bob build",
        "lint": "eslint ./src"
    }
}
EOF
}

modify_git_ignore() {
cat >> .gitignore <<EOT
# Monorepo Specific
node_modules
.turbo/
dist/
lib/

EOT
}

create_utils_package() {
  cd packages/utils
  mkdir src
  yarn init
  if [[ $LANGUAGE == "ts" ]]; then
    create_tsconfig
    touch src/index.ts
    echo "export {};" >> src/index.ts
  elif [[ $LANGUAGE == "js" ]]; then
    touch src/index.js
    echo "module.exports = {};" >> src/index.js
  fi

  if [[ $choice == "BuilderBob" ]]; then
    modify_package_json
  fi
}

####################################################################################
### Execution
####################################################################################

execute() {
  print_purple "Monorepo package generator \n"
  print_question "What would you like to name your package: "
  read -r MODULE_NAME
  # Here to make sure that the package.json name is in kebab case
  PACKAGE_NAME_KEBAB=$(convert_to_kebab_case "$MODULE_NAME")
  PACKAGE_NAME_PASCAL=$(convert_to_pascal_case "$MODULE_NAME")
  set_file_case
  set_dep_manager
  set_configs
  modify_package_json
  # shellcheck disable=SC2068
  yarn add ${NPM_DEP_ARR[@]}
  if [[ "${#NPM_DEV_DEP_ARR[@]}" -ge 1 ]]; then
    # shellcheck disable=SC2068
    yarn add ${NPM_DEV_DEP_ARR[@]} -D
  fi
  modify_git_ignore
  create_npmignore
  create_utils_package
}

execute

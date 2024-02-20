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
### Directory Factory
####################################################################################
# Create the root of the monorepo
#######################################
# Creates the root monorepo structure
# including apps/ packages/ and bin/.
# Globals:
#   BACKUP_DIR
#   ORACLE_SID
# Arguments:
#   None
#######################################
create_project_root() {
    mkdir "$PACKAGE_NAME"
    print_green "Creating $PACKAGE_NAME \n"
    # shellcheck disable=SC2164
    cd "$PACKAGE_NAME"
    mkdir apps
    mkdir bin
    touch bin/generate-modules.sh

    mkdir packages
    mkdir packages/utils
}

#######################################
# Creates a package/ module directory structure
# Globals:
#   $DIR_TO_CREATE_IN
#   $SUB_PACKAGE_NAME - TODO: update this name
# Arguments:
#   None
#######################################
create_module_structure() {
    echo "In Create Module Structure"
    mkdir "$DIR_TO_CREATE_IN/$SUB_PACKAGE_NAME"
    cd "$DIR_TO_CREATE_IN/$SUB_PACKAGE_NAME" || exit
    touch src/index.${LANGUAGE}
    print_white "created src/index.${LANGUAGE} \n"
    touch src/$SUB_PACKAGE_NAME.${LANGUAGE}x
    print_white "created src/$SUB_PACKAGE_NAME.${LANGUAGE}x \n"
    touch src/${SUB_PACKAGE_NAME}Props.${LANGUAGE}x
    print_white "created src/${PACKAGE_NAME}Props.${LANGUAGE}x \n "
    print_green "\t Successfully created $SUB_PACKAGE_NAME \n"
}


#######################################
# Creates a utilities package in packages/
# Modifies the package JSON when using builder
# bob. Creates a barrel file to match configs.
# Globals:
#   $LANGUAGE
#   ORACLE_SID
# Arguments:
#   None
#######################################
create_utils_package() {
  cd packages/utils || exit
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
#
#  if [[ $choice == "BuilderBob" ]]; then
#    modify_package_json
#  fi
}

####################################################################################
### Dependency Management
####################################################################################
#######################################
# Allows user to select casing for dir
# and file structure through out.
# Except for instance where casing is
# specific i.e. name in package.json
#
# Globals:
#   MODULE_NAME
#   ORACLE_SID
# Arguments:
#   None
#######################################
set_file_case() {
    file_casings=("PascalCase" "Kebab-Case" "camelCase" "snake_case")
    print_question "What casing would you like to use for directory & file structure"
    select file_casing in "${file_casings[@]}"; do
        case $file_casing in
            "PascalCase")
                PACKAGE_NAME=$(convert_to_pascal_case "$MODULE_NAME")
                break
                ;;
            "Kebab-Case")
                PACKAGE_NAME=$(convert_to_kebab_case "$MODULE_NAME")
                break
                ;;
            "camelCase")
                PACKAGE_NAME=$(convert_to_camel_case "$MODULE_NAME")
                break
                ;;
            "snake_case")
                PACKAGE_NAME=$(convert_to_snake_case "$MODULE_NAME")
                break
                ;;
            *)
                print_red "Invalid choice \n"
                ;;
        esac
    done
}

#######################################
# Select the dependency manager and then
# drill into manager setup choices NPM
# and Yarn.
# Notes:
#   NPM currently barebones setup
# Globals:
#   LANGUAGE
#   ORACLE_SID
# TODO:
#  Add support for PNPM
#######################################
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

#######################################
# Runs the NPM setup with all subprocess
# Globals:
#   None
# Arguments:
#   None
#######################################
# TODO: Finalize the NPM setup
run_npm_setup() {
    print_purple "Setting up NPM"
    print_blue "Follow the NPM setup"
    npm init
}

#######################################
# Runs the Yarn setup with all subprocess includes allowing user to select the flavor of yarn
# Globals:
#   None
# Arguments:
#   None
#######################################
run_yarn_setup() {
    print_purple "\n Setting up Yarn \n"
    set_yarn_version
    yarn init
}

#######################################
# Sets the version of yarn
# Internal function to check if user
# wants to use pnp.
#######################################
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

#######################################
# Sets up Yarn berry with out PnP
# TODO:
#   Allow the PnP be an option to use nodeLinker
#######################################
set_yarn_berry() {
yarn set version stable
touch .yarnrc.yml
cat > .yarnrc.yml << EOF
    nodeLinker: node-modules
EOF
}

#######################################
# Set the repos JS flavor and create any required configurations
# Globals:
#   LANGUAGE
#######################################
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

####################################################################################
### Configurations Setup
####################################################################################

#######################################
# Multiselect for Dependency configuration
#######################################
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

#######################################
# Looping through the multi select for
# configurations
#######################################
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

#######################################
# Runs the above functions to determine
# which configs below to run
#######################################
set_configs() {
  select_options
  confirm_selections
}

#######################################
# Generate TS config file
#######################################
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

#######################################
# Creates IBM audit-ci and base configuration
#######################################
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

#######################################
# Creates a turbo monorepo config file
#######################################
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

#######################################
# Creates an ESLint configuration
# TODO:
#   Setup eslint
#######################################
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

#######################################
# WIP - Creates a lerna monorepo
# TODO:
#   Setup lerna support
#######################################
create_lerna() {
  print_white "$choice - Creating $choice"
}

#######################################
# For ignoring when publishing
#######################################
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

#######################################
# Creates a github action directory
# TODO:
#   continue GHA setup
#######################################
create_gh_actions() {
  mkdir .github
  touch .github/main.yml
  mkdir .github/workflows
  touch .github/workflows/pullrequest.yml
}

#######################################
# Adds builder bob configuration to package.json
# TODO:
#   move this create into the create modules
# Note:
#   This will only be used in packages.
#######################################
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

#######################################
# Modifies the root package.json
#######################################
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
    "publishConfig": {
        "access": "public"
    },
    "files": [
        "lib",
        "src"
    ],
    "scripts": {
        "build": "turbo run build",
        "lint": "eslint ./src"
    }
}
EOF
}

#######################################
# Modify the .gitignore generated with
# a yarn project
#######################################
modify_git_ignore() {
cat >> .gitignore <<EOT
# Monorepo Specific
node_modules
.turbo/
dist/
lib/

EOT
}

####################################################################################
### Execution
####################################################################################

#######################################
# Main executable for generate-monorepo.sh.
# Globals:
#   MODULE_NAME
#   PACKAGE_NAME_KEBAB
# Arguments:
#   NPM_DEP_ARR
#   NPM_DEV_DEP_ARR
#######################################
generate_monorepo() {
  print_purple "Monorepo package generator \n"
  print_question "What would you like to name your package: "
  read -r MODULE_NAME
  cd ../../React-Native-Apps
  # Here to make sure that the package.json name is in kebab case
  PACKAGE_NAME_KEBAB=$(convert_to_kebab_case "$MODULE_NAME")
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

generate_monorepo
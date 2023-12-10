#!/bin/bash


####################################################################################
### Utils
####################################################################################
NPM_DEP_ARR=("react")

reset="\033[0m"
highlight="\033[41m\033[97m"
dot="\033[31m $reset"
dim="\033[2m"
blue="\e[34m"
green="\e[32m"
yellow="\e[33m"
green_tag="\e[30;46m"
blue_tag="\e[38;5;33m"
bold=$(tput bold)
normal=$(tput sgr0)

print_red() {
  _print_in_color "$1" 1
}

print_green() {
  _print_in_color "${indent} $1" 2
}

print_yellow() {
  _print_in_color "$1" 3
}

print_blue() {
  _print_in_color "$1" 4
}

print_purple() {
  _print_in_color "$1" 5
}

print_white() {
  _print_in_color "$1" 6
}

print_question() {
  print_yellow" [?] $1\n"
}

_print_in_color() {
  printf "%b" \
    "$(tput setaf "$2" 2> /dev/null)" \
    "$1" \
    "$(tput sgr0 2> /dev/null)"
}

add_to_dep_arr() {
    NPM_DEP_ARR+=("$@")
}

convert_to_pascal_case() {
    local input=$1
    local pascalCase=""
    IFS=' ' # Internal Field Separator set to space

    read -r -a words <<< "$input"

    for word in "${words[@]}"; do
        firstLetter=$(echo ${word:0:1} | tr '[:lower:]' '[:upper:]')
        restOfWord=${word:1}
        pascalCase+="${firstLetter}${restOfWord}"
    done

    echo "$pascalCase"
}

convert_to_kebab_case() {
    local input=$1
    local kebab_case=""

    kebab_case="${input// /-}"
    kebab_case=$(echo "$kebab_case" | tr '[:upper:]' '[:lower:]')
    echo "$kebab_case"
}


# Create module structure
create_module_structure() {
    mkdir $PACKAGE_NAME && cd $PACKAGE_NAME
    touch index.${LANGUAGE}
    print_white "created index.${LANGUAGE} \n"
    mkdir src
    print_white "created src \n"
    touch src/index.${LANGUAGE}
    print_white "created src/index.${LANGUAGE} \n"
    touch src/$PACKAGE_NAME.${LANGUAGE}x
    print_white "created src/$PACKAGE_NAME.${LANGUAGE}x \n"
    touch src/${PACKAGE_NAME}Props.${LANGUAGE}x
    print_white "created src/${PACKAGE_NAME}Props.${LANGUAGE}x \n "
    print_green "\t Successfully created $PACKAGE_NAME \n" 
}
 
####################################################################################
### Steak and Potatoes
####################################################################################
set_file_case() {
    file_casings=("Pascal" "Kebab")
    print_yellow "What casing would you like to use for directory structure \n"
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

#  Select the dependency manager 
set_dep_manager() {
    dep_man_choices=("NPM" "Yarn")
    print_yellow "\nPlease select a Package Manager: \n"
    select dep_man_choice in "${dep_man_choices[@]}"; do
        case $dep_man_choice in
            "NPM")
                # run_npm_setup
                break
                ;;
            "Yarn")
                # run_yarn_setup
                break
                ;;
            *)
                print_red "Invalid Choice \n"
                ;;
        esac
    done

DEP_MANAGER=$dep_man_choice
}

run_npm_setup() {
    print_purple "Setting up NPM"
}

run_yarn_setup() {
    print_purple "Setting up Yarn"
    yarn init && set name $PACKAGE_NAME_KEBAB
    # set_yarn_version
}

set_yarn_version() {
    dep_version_choices=("Classic" "Berry 3" "Berry Latest")
    print_yellow "\n Please select a Package Manager: \n"
    select dep_version_choice in "${dep_version_choices[@]}"; do
        case $dep_version_choice in
            "Classic")
                print_success "$dep_version_choice \n"
                break
                ;;
            "Berry 3")
                print_success "$dep_version_choice \n"
                version_num=3
                set_yarn_berry $version_num
                break
                ;;
            "Berry Latest")
                print_success "$dep_version_choice \n" 
                version_num="stable"
                set_yarn_berry
                break
                ;;
            *)
                print_red "Invalid Choice"
                ;;
        esac
    done

DEP_VERSION=$dep_version_choice
}

set_yarn_berry() {
yarn set version $version
touch .yarnrc.yml
cat > .yarnrc.yml << EOF
    nodeLinker: node-modules
EOF
}

set_language() {
    language_choices=("Javascript" "Typescript")
    print_yellow "\n Please select a language: \n"
    select language_choice in "${language_choices[@]}"; do
        case $language_choice in
            "Javascript")
                LANGUAGE="js"
                break
                ;;
            "Typescript")
                LANGUAGE="ts"
                IS_TS=true
                break
                ;;
            *)
                ;;
        esac
    done
}

set_module_type() {
    module_type_choices=("React Component" "React Component with Storybook", "Utility Module")
    print_yellow "\n Please select a Package Manager: \n"
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

create_tsconfig() {
add_to_dep_arr "typescript"
touch tsconfig.json
cat > tsconfig.json <<EOF
{
    "extends": "tsconfig/base.json",
    "compilerOptions": {
        "jsx": "react",
        "baseUrl": ".",
        "paths": {
            "apps/*": ["apps/*"],
            "packages/utils/*: ["utils/*]
        }
    }
    "exclude": ["node_modules", "lib", "dist"]
}
EOF
}

create_auditci() {
add_to_dep_arr "audit-ci"
    touch audit-ci.jsonc
    cat > audit-ci.jsonc <<EOF
   {
	"\$schema": "https://github.com/IBM/audit-ci/raw/main/docs/schema.json",
	"moderate": true,
	"registry": "https://registry.npmjs.org"
    }
EOF
}

is_rn_Builder_BOB() {
cat <<EOF
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
EOF
}

modify_package_json() {
cat < package.json <<EOF
   {
    "name": "${PACKAGE_NAME_KEBAB}",
    "description": "${PACKAGE_NAME_KEBAB}",
    "version": "0.0.1",
    "packageManager": "yarn@3.6.4",
    "license": "UNLICESEND",
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
        "lint": "eslint \"**/*.{js,ts,tsx}\""
    },
EOF

    if [[ $USE_BUILDER_BOB == "yes" ]]; then
        is_rn_Builder_BOB >> package.json
    fi

    # Finish the JSON structure
    echo "}" >> package.json
}

execute() {
print_purple "Monorepo package generator \n"
print_yellow "What would you like to name your package: "
read MODULE_NAME

PACKAGE_NAME_PASCAL=$(convert_to_pascal_case "$MODULE_NAME")
PACKAGE_NAME_KEBAB=$(convert_to_kebab_case "$MODULE_NAME")

set_file_case
set_dep_manager
set_language
create_module_structure
if [[ $DEP_MANAGER == "Yarn" ]]; then
    run_yarn_setup
fi

if [[ $LANGUAGE == "ts" ]]; then
    create_tsconfig
fi
}

execute

# Enter a package name
    # Converted to Kebab and Pascal cases (Kebab - Package Manager, Pascal - Directory Stucture)
        # Could give the user the choice for how to create their directory structure (kebab or pascal)
# Select which package manager (NPM || YARN)
    # If Yarn execute a yarn select version to use Fx
# Select a language (TS || JS)
    # if TS, then generate tsconfig and add Typescript to dependency array.    
# Select the type of package to create (React | React Native | Utility | React Component )
    # if just a regular React or React Native just create Component, prop, __tests__/ and index with proper JSX
    # if with storybook  add a __stories__ and create the Story and Docs file.
        # could have this update the /.storybook/main.js file
# Create the package structure passed (assigned by package to create)
# Ask if they want security built in (audit-ci)
# Ask if ESLint, Prettier.
# Create a .gitignore and ignore the required files
# Install the required dependencies. 
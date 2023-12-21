#!/bin/bash

source utils.sh
source directory-factory.sh
source mono-config-setup.sh

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


####################################################################################
### Execution
####################################################################################

generate_monorepo() {
  print_purple "Monorepo package generator \n"
  print_question "What would you like to name your package: "
  read -r MODULE_NAME
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


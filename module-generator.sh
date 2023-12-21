#!/bin/bash

source utils.sh
source directory-factory.sh
source mono-config-setup.sh
source generate-monorepo.sh
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

create_app() {
  print_purple "Creating and app in $module_dir_choice"
  create_module_structure
}

create_package() {
  print_purple "Creating and package in $module_dir_choice"
  create_module_structure
}

set_module_directory() {
    module_dir_choices=("apps" "packages")
    print_question "Please select a directory where you want to create:"
    select module_dir_choice in "${module_dir_choices[@]}"; do
        case $module_dir_choice in
            "apps")
                print_blue "$module_dir_choice \n"
                cd $module_dir_choice
                create_app
                break
                ;;
            "packages")
                print_blue "$module_dir_choice \n"
                cd $module_dir_choice
                create_package
                break
                ;;
            *)
                print_red "Invalid Choice \n"
                ;;
        esac
    done

DIR_TO_CREATE_IN=$module_dir_choice
}
####################################################################################
### Execution
####################################################################################

generate_module() {
  print_question "What would you like to name your package: "
  read -r SUB_PACKAGE_NAME

  # Here to make sure that the package.json name is in kebab case
  PACKAGE_NAME_KEBAB=$(convert_to_kebab_case "$SUB_PACKAGE_NAME")
  set_module_directory
  echo $PACKAGE_NAME_KEBAB
#  set_configs
#  modify_package_json
#  yarn add ${NPM_DEP_ARR[@]}
#  if [[ "${#NPM_DEV_DEP_ARR[@]}" -ge 1 ]]; then
#    yarn add ${NPM_DEV_DEP_ARR[@]} -D
#  fi

}

generate_module

#!/bin/zsh

source utils.sh

NPM_DEP_ARR=("react" "react-native" "react-dom" "react-native-web" "react-native-svg")
NPM_DEV_DEP_ARR=("")

add_to_dep_arr() {
    NPM_DEP_ARR+=("$@")
}

add_to_dev_dep_arr() {
    NPM_DEV_DEP_ARR+=("$@")
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
    mkdir "$PACKAGE_NAME"
    cd "$PACKAGE_NAME" || exit
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

    touch src/index."${LANGUAGE}"
    print_white "created src/index.${LANGUAGE} \n"
    touch src/"$PACKAGE_NAME".${LANGUAGE}x
    print_white "created src/$PACKAGE_NAME.${LANGUAGE}x \n"
    touch src/${PACKAGE_NAME}Props.${LANGUAGE}x
    print_white "created src/${PACKAGE_NAME}Props.${LANGUAGE}x \n "
    print_green "\t Successfully created $PACKAGE_NAME \n"
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
                cd ../$module_dir_choice
                create_app
                break
                ;;
            "packages")
                print_blue "$module_dir_choice \n"
                cd ../$module_dir_choice
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
            "tsc": "../../node_modules/.bin/tsc"
            }
        ]
        ]
    }
}
EOF
}

#######################################
# Modifies the package.json
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
    },
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

####################################################################################
### Execution
####################################################################################

generate_package() {
  print_purple "Create a new package \n"
  print_question "What would you like to name your package: "
  read -r PACKAGE_NAME
  PACKAGE_NAME_KEBAB=$(convert_to_kebab_case "$PACKAGE_NAME")
  set_language
  set_module_directory
  echo $PACKAGE_NAME_KEBAB

  modify_package_json
  # shellcheck disable=SC2068
  yarn add ${NPM_DEP_ARR[@]}
  if [[ "${#NPM_DEV_DEP_ARR[@]}" -ge 1 ]]; then
    # shellcheck disable=SC2068
    yarn add ${NPM_DEV_DEP_ARR[@]} -D
  fi
  modify_git_ignore
  create_builder_bob
  create_tsconfig
  create_npmignore

}

generate_package

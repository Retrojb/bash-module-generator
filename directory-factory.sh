#!/bin/bash

source utils.sh
source generate-monorepo.sh
source module-generator.sh
# Create the root of the monorepo
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


# Create module structure
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
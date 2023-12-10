#!/bin/bash

read -p "Script E monorepo builder: " PROJECT_NAME
read -p "Please select a Package Manager ('npm' or 'yarn'): " DEP_MANAGER
read -p "Which version of Yarn? (classic | berry) " DEP_MANAGER_VERSION
read -p "Project Language? (typescript | javascript)" PROJECT_LANGUAGE


# Utils

add_to_dep_arr() {
    my_array+=("$input")
}

dep_management() {
if [[ $DEP_MANAGER == 'yarn' ]]; then 
    if [[ $DEP_MANAGER_VERSION == 'berry' ]]; then
        yarn
        set_yarn
    elif [[ $DEP_MANAGER == 'classic' ]]; then
        yarn
    else
        echo "ERROR: No version selected"
        exit 1
    fi
else 
    npx create-turbo@latest
fi
}

set_yarn() {
yarn set version stable
touch .yarnrc.yml
cat > .yarnrc.yml << EOF
    nodeLinker: node-modules
EOF
}

set_language() {
if [[ $PROJECT_LANGUAGE == 'typescript' ]]; then
    add_to_array=$PROJECT_LANGUAGE
    create_tsconfig
fi
}

create_repo() {
    yarn init
}

create_tsconfig() {
local input='typescript'
add_to_array
touch tsconfig.json
cat < tsconfig.json <<EOF
    {
        "extends": "tsconfig/base.json",
        "compilerOptions": {
            "jsx": "react",
            "baseUrl": ".",
            "paths": {
                "apps/*": ["apps/*"],
                "packages/utils/*: ["utils/*],
        }
        "exclude": ["node_modules", "lib", "dist"]
    }
EOF
}

create_auditci() {
touch audit-ci.jsonc
cat < audit-ci.jsonc <<EOF
   {
	"\$schema": "https://github.com/IBM/audit-ci/raw/main/docs/schema.json",
	"moderate": true,
	"registry": "https://registry.npmjs.org"
}
EOF
}

# create_npmignore() {

# }

# create_gitignore() {

# }

NPM_DEPS_TO_INSTALL='
react
react-dom
react-native
react-native-web
typescript
eslint
auditci

'

# Main function

execute() {
if [[ -z "$PROJECT_NAME" ]]; then
    echo "Come on, you've got to name your project! Let's try that again."
    exit 1
elif [[ -d "$PROJECT_NAME" ]]; then
    echo "OPE! Looks like a project with that name already exists in this dir"
    exit 1
else 
    cd ../
    mkdir $PROJECT_NAME && cd $PROJECT_NAME
    dep_management
fi
}

## Execute the script
execute
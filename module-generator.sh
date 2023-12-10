#!/bin/bash


####################################################################################
### Utils
####################################################################################
NPM_DEP_ARR=("react")

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
    mkdir $MODULE_NAME && cd $MODULE_NAME
    touch index.ts && echo "export * ./src"
    mkdir src
    touch src/index.${LANGUAGE}
    touch src/$MODULE_NAME.${LANGUAGE}x
    touch src/${MODULE_NAME}Props.${LANGUAGE}x
}
 
####################################################################################
### Steak and Potatoes
####################################################################################
#  Select the dependency manager 
set_dep_manager() {
    dep_man_choices=("NPM" "Yarn")
    echo "Please select a Package Manager: "
    select dep_man_choice in "${dep_man_choices[@]}"; do
        case $dep_man_choice in
            "NPM")
                echo "$dep_man_choice"
                npm init
                break
                ;;
            "Yarn")
                echo "$dep_man_choice"
                yarn init
                break
                ;;
            *)
                echo "Invalid Choice"
                ;;
        esac
    done

DEP_MANAGER=$dep_man_choice
}

set_dep_version() {
    dep_version_choices=("Classic" "Berry 3" "Berry Latest")
    echo "Please select a Package Manager: "
    select dep_version_choice in "${dep_version_choices[@]}"; do
        case $dep_version_choice in
            "Classic")
                break
                ;;
            "Berry 3")
                echo "$dep_version_choice"
                yarn set version 3
                break
                ;;
            "Berry Latest")
                echo "$dep_version_choice"
                yarn set version stable
                break
                ;;
            *)
                echo "Invalid Choice"
                ;;
        esac
    done

DEP_VERSION=$dep_version_choice
}

set_language() {
    language_choices=("Javascript" "Typescript")
    echo "Please select a language: "
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
    echo "Please select a Package Manager: "
    select dep_man_choice in "${dep_man_choices[@]}"; do
        case $dep_man_choice in
            "React Component")
                echo "$dep_man_choice"
                break
                ;;
            "React Component with Storybook")
                echo "$dep_man_choice"
                break
                ;;
            "Utility Module")
                echo "$dep_man_choice"
                break
                ;;
            *)
                echo "Invalid Choice"
                ;;
        esac
    done

DEP_MANAGER=$dep_man_choice
}

create_tsconfig() {
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
add_to_dep_arr "audit-ci"
touch audit-ci.jsonc
cat < audit-ci.jsonc <<EOF
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



# Basic JS module, Basic TS module, React Component / with SB, React or RN app. 

# read -p "What type of package do you want to create? " PKG_TYPE

execute() {
echo "Monorepo package generator"
read -p "What would you like to name your package: " MODULE_NAME
read -p "Use Builder bob: " USE_BUILDER_BOB
# Update casing for Package manager and project structure
PACKAGE_NAME_PASCAL=$(convert_to_pascal_case "$MODULE_NAME")
PACKAGE_NAME_KEBAB=$(convert_to_kebab_case "$MODULE_NAME")
echo $PACKAGE_NAME_PASCAL
echo $PACKAGE_NAME_KEBAB
# set_dep_manager
# set_language

# if [[ $LANGUAGE == "ts" ]]; then
#     add_to_dep_arr "typescript"
#     echo "It is: ${NPM_DEP_ARR[*]}"
#     create_tsconfig
# fi



# create_module_structure

echo "Selection was: $DEP_MANAGER"
echo "Language: $LANGUAGE"
}

execute

# Enter a package name
    # Converted to Kebab and Pascal cases (Kebab - Package Manager, Pascal - Directory Stucture)
        # Could give the user the choice for how to create their directory structure (kebab or pascal)
# Select which package manager (NPM || YARN)
# Select a language (TS || JS)
# Select the type of package to create (React | React Native | Utility | React Component )
# Execute a packagemanager create script (IF yarn - select version of yarn to use)
# Create the package structure passed (assigned by package to create)
# Ask if they want security built in (audit-ci)
# Install the required dependencies. 
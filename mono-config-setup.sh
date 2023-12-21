#!/bin/bash

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
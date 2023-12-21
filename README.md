# Retrojb/bash-monorepo-generator

## Project Scope:
This project is the result of my year building Monorepos for Design Systems, 
be warned that this is written with bias for Design Systems in mind.
Create a new monorepo in seconds, this script will help execute the following

--- 
### Casing Conversions:  (utils.sh)
- Kebab-Case - Stores a local var to be used in the package.json
- PascalCase - Directory Structure
- camelCase - Directory Structure / file naming choice
- snake_case - Because why not have it as an option

---
### Pretty Printing format (utils.sh)
Aesthetic CLI script for users burnt out by white chars on a black background.

---
### Multiple Package Manager Support 
- NPM - Support for the latest version of NPM

- Yarn - Support for Classic Yarn v1.22 and Yarn Berry 4 

- PNPM - Coming Soon

---
### Configure project with Javascript or Typescript
Generates a project based on your language of choice. Typescript creates base
tsconfig files in the root and any sub packages.

### Configuration base setup for the following commonly used NPM dependencies
- [Audit CI](https://github.com/IBM/audit-ci)  
- CallStacks [React Native Builder Bob](https://github.com/callstack/react-native-builder-bob)
- [TurboRepo](https://turbo.build/repo/docs)
- [Prettier](https://prettier.io/)
- WIP: Github Actions
- WIP: Lerna
- WIP:ESLint
- TBD: RollupJS
- TBD: Commit Lint
- TBD: ChangeSet

---
## Coming Soon
### Create modules AoT with support for:
#### React
Vite
CRA
#### React Native
Expo
React Native Bare Flow
#### React Native Web
Support React Native on web
#### Storybook - For Component Library component
React v6 & v7
React Native

--- 


### TODOs
Add support for PNPM
Add version specific support for package managers
Add a workspace setup

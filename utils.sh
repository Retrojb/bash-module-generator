#!/bin/bash

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
  _print_in_color "$1" 2
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
  print_yellow " [?] $1 \n"
}

_print_in_color() {
  printf "%b" \
    "$(tput setaf "$2" 2> /dev/null)" \
    "$1" \
    "$(tput sgr0 2> /dev/null)"
}

# TODO: Add support for camel casing
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

convert_to_camel_case() {
    local input=$1
    local camelCase=""
    IFS=' ' # Internal Field Separator set to space

    read -r -a words <<< "$input"
    local isFirstWord=true

    for word in "${words[@]}"; do
        if $isFirstWord; then
            # Lowercase the first word entirely
            camelCase+=$(echo "${word,,}")
            isFirstWord=false
        else
            # Capitalize the first letter of subsequent words
            firstLetter=$(echo ${word:0:1} | tr '[:lower:]' '[:upper:]')
            restOfWord=${word:1}
            camelCase+="${firstLetter}${restOfWord}"
        fi
    done

    echo "$camelCase"
}

convert_to_snake_case() {
    local input=$1
    local snakeCase=""
    IFS=' ' # Internal Field Separator set to space

    read -r -a words <<< "$input"

    for word in "${words[@]}"; do
        # Lowercase the word
        lowerCaseWord=$(echo "${word,,}")
        # Append to snakeCase with an underscore
        snakeCase+="${lowerCaseWord}_"
    done

    # Remove the trailing underscore
    snakeCase=${snakeCase%_}

    echo "$snakeCase"
}

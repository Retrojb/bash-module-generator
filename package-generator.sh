#!/bin/bash

source generate-monorepo.sh
source module-generator.sh

set_dest() {
    MAIN_PROCESS_CHOICES=("Build Monorepo" "Generate App or Package")
    print_question "Please select a Package Manager: "
    select main_process_choice in "${MAIN_PROCESS_CHOICES[@]}"; do
        case $main_process_choice in
            "Build Monorepo")
                generate_monorepo
                break
                ;;
            "Generate App or Package")
                generate_module
                break
                ;;
            *)
                print_red "Invalid Choice \n"
                ;;
        esac
    done

  DEP_MANAGER=$main_process_choice
}

echo "end"
main() {
  echo 'in main'
  set_dest
}

main
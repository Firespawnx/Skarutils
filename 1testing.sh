#!/bin/bash

#Variables to keep:
ServerKeychain="example, example"
SavedMacro="example 1"

___var_overwrite() { #___var_overwrite "var_name" "var_value"
    local var_name="$1"
    local var_value="$2"
    
    # Validate inputs
    if [[ -z "$var_name" || -z "$var_value" ]]; then
        echo "Usage: ___keychain_write <variable_name> <string_value>"
        return 1
    fi
    
    # Check if script file exists and is writable
    if [[ ! -f "$SCRIPT_FILE" ]]; then
        echo "Error: Script file '$SCRIPT_FILE' not found"
        return 1
    fi
    
    if [[ ! -w "$SCRIPT_FILE" ]]; then
        echo "Error: Script file '$SCRIPT_FILE' is not writable"
        return 1
    fi
    
    # Escape special characters for sed (more comprehensive escaping)
    local escaped_value=$(printf '%s\n' "$var_value" | sed 's/[[\.*^$()+?{|\\]/\\&/g; s/"/\\"/g')
    
    # Replace the entire variable value in the script file
    if sed -i "/^${var_name}=/c\\${var_name}=\"${escaped_value}\"" "$SCRIPT_FILE"; then
        # Replace the variable in current session (not append)
        eval "${var_name}=\"\${var_value}\""
        echo "Successfully replaced ${var_name} with: ${var_value}"
        return 0
    else
        echo "Error: Failed to replace ${var_name} in file"
        return 1
    fi
}

SCRIPT_FILE="${BASH_SOURCE[0]}"



function skarupdate {
    
    if ping -c 1 google.com &> /dev/null; then
        echo "Checking for updates..."
        echo ""
        
        difference=$(diff $SCRIPT_FILE <(curl -s https://raw.githubusercontent.com/Firespawnx/Skarutils/main/Skarutils.sh))
        if [[ "$difference" != "" ]]; then
            echo "There is a newer version of Skarutils. Would you like to install it?"
            echo "Update? Y/n"
            echo ""
            read user_input

            if [[ "$user_input" = "Y" ]]; then
                echo "$ServerKeychain" > tempforskar-ServerKeychain.txt
                echo "$SavedMacro" > tempforskar-SavedMacro.txt
                


                curl -s https://raw.githubusercontent.com/Firespawnx/Skarutils/main/Skarutils.sh > $SCRIPT_FILE
                


                ___var_overwrite "ServerKeychain" "$(cat ./tempforskar-ServerKeychain.txt)"
                ___var_overwrite "SavedMacro" "$(cat ./tempforskar-SavedMacro.txt)"
                
                rm -f ./tempforskar-ServerKeychain.txt ./tempforskar-SavedMacro.txt
            fi
        fi
    else
        echo "Please connect to the internet to update."
    fi
}
#!/bin/bash

# "End" is a placeholder that resolves a vscode editor issue with functions absorbing new lines.



#Persistent storage:

ServerKeychain=""
SavedMacro=""


#Important for the storage system to work
SCRIPT_FILE="${BASH_SOURCE[0]}"



#Built in functions:
___var_overwrite() { #___keychain_write "var_name" "var_value"
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
___keychain_write() { #___keychain_write "key_name" "key_value"
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
    
    # Update the variable in the script file
    if sed -i "s/^${var_name}=.*/${var_name}=\"${escaped_value}\"/" "$SCRIPT_FILE"; then
        # Update the variable in current session
        eval "${var_name}=\"${var_value}\""
        echo "Successfully updated ${var_name} to: ${var_value}"
        return 0
    else
        echo "Error: Failed to update ${var_name} in file"
        return 1
    fi
}
___keychain_del() { #___keychain_del "$name" "$ServerKeychain"
    local search_name="$1"
    local keychain="$2"
    
    # Split by commas since the data format uses commas as separators
    IFS=',' read -ra ServerTemp1 <<< "$keychain"
    
    # Array to store items that don't match the search name
    local filtered_items=()
    
    # Search through items
    local item
    for item in "${ServerTemp1[@]}"; do
        # Trim whitespace
        local trimmed_item=$(echo "$item" | xargs)
        
        # Skip empty items
        if [[ -z "$trimmed_item" ]]; then
            continue
        fi
        
        # Extract name (text before first space) and value (text after first space)
        local item_name="${trimmed_item%% *}"
        local item_value="${trimmed_item#* }"
        
        # If this item's name doesn't match the search name, keep it
        if [[ "$item_name" != "$search_name" ]]; then
            filtered_items+=("$trimmed_item")
        fi
    done
    
    # Join the remaining items back with commas
    local result=""
    for ((i=0; i<${#filtered_items[@]}; i++)); do
        if [[ $i -eq 0 ]]; then
            result="${filtered_items[i]}"
        else
            result="$result,${filtered_items[i]}"
        fi
    done
    
    echo "$result"
}
___text_box() { #___text_box "text" "frame 1-4"
    local string="$1"
    
    if [ "$2" = "1" ]; then
        local character="─"
        local ln=${#string}
        local line=""
        
        for ((i=0; i<ln+2; i++)); do
            line+="$character"
        done
        
        echo "┌$line┐"
        echo "│ $string │"
        echo "└$line┘"
    elif [ "$2" = "2" ]; then
        local character="═"
        local ln=${#string}
        local line=""
        
        for ((i=0; i<ln+2; i++)); do
            line+="$character"
        done
        
        echo "╒$line╕"
        echo "│ $string │"
        echo "╘$line╛"
    elif [ "$2" = "3" ]; then
        local character="─"
        local ln=${#string}
        local line=""
        
        for ((i=0; i<ln+2; i++)); do
            line+="$character"
        done
        
        echo "╭$line╮"
        echo "│ $string │"
        echo "╰$line╯"
    elif [ "$2" = "4" ]; then
        local character="═"
        local ln=${#string}
        local line=""
        
        for ((i=0; i<ln+2; i++)); do
            line+="$character"
        done
        
        echo "╔$line╗"
        echo "║ $string ║"
        echo "╚$line╝"
    fi
}



#Commands:



#Skar functions
    function home {
        clear

        printf '%s\n' \
        "┌──────────────────────────────────────────┐" \
        "│ ____   _                                 │" \
        "│/ ___| | | __ __ _  _ __                  │" \
        "│\___ \ | |/ // _' || '__|                 │" \
        "│ ___) ||   <| (_| || |                    │" \
        "│|____/ |_|\_\\__,_||_|                     │" \
        "│ _   _  _    _  _                         │" \
        "│| | | || |_ (_)| | ___                ┌───┤" \
        "│| | | || __|| || |/ __|               │V.2│" \
        "│| |_| || |_ | || |\__ \ ┌─────────────┘∙∙∙│" \
        "│ \___/  \__||_||_||___/ │By Skandar ######│" \
        "└────────────────────────┴─────────────────┘" \
        "  ───────────────────────                   " \
        "   HELP for instructions                    " \
        "  ───────────────────────                   "
        
        # Check if script is being sourced
        if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
            ___text_box "⚠ You must run \". ${0}\" to load the commands. ⚠" 4
        fi
    }
    function HELP {

        clear
        
        printf '%s\n' \
        "  ____                                                _       " \
        " / ___| ___   _ __ ___   _ __ ___    __ _  _ __    __| | ___  " \
        "| |    / _ \ | '_ ' _ \ | '_ ' _ \  / _' || '_ \  / _' |/ __| " \
        "| |___| (_) || | | | | || | | | | || (_| || | | || (_| |\__ \ " \
        " \____|\___/ |_| |_| |_||_| |_| |_| \__,_||_| |_| \__,_||___/ " \
        "──┬────────────────────────────────────────────────────────── " \
        "  |SPACEBAR to advance, Q to quit.                            " \
        "  └────────────────────────────────                           " \
        "                                                              " \
        "  ┌───────────────                                            " \
        "  │ New commands:                                             " \
        "  ├────────────────────────────────────────────────────────   " \
        "  │home = clears the terminal andreturns to the home badge    " \
        "  ├────────────────────────────────────────────────────────   " \
        "  │HELP = Gets you here                                       " \
        "  ├─────────────────────                                      " \
        "  │netkeychain                                                " \
        "  └───┬────────────────────────────────                       " \
        "      │ls = displays all saved servers                        " \
        "      ├─────────────────────────────────────                  " \
        "      │add = save a server to your keychain                   " \
        "  ┌───┴─────────────────────────────────────                  " \
        "  │server                                                     " \
        "  └───┬───────────────────────────────────────────────────    " \
        "      │ssh = connects to an ssh server from your keychain     " \
        "      ├─────────────────────────────────────────────────────  " \
        "      │sftp = connects to an sftp server from your keychain   " \
        "  ┌───┴─────────────────────────────────────────────────────  " \
        "  |macro                                                      " \
        "  └───┬─────────────────────────────────────────────          " \
        "      |create = saves commands to be executed later           " \
        "      ├─────────────────────────────────────────────          " \
        "      |leave blank = executes your saved macro                " \
        "  ┌───┴────────────────────────────────────────               " \
        "  |lsg = an ASCII graphical alternative to ls                 " \
        "  ├───────────────────────────────────────────                " \
        "  |backup                                                     " \
        "  └───┬────────────────────────────────────────────────────   " \
        "      |filename = backs up a file in the current directory    " \
        "      ├────────────────────────────────────────────────────   " \
        "      |filname path = backs up a file to another directory    " \
        "  ┌───┴────────────────────────────────────────────           " \
        "  |.bashrc reset = resets your .bashrc config file            " \
        "  └────────────────────────────────────────────────           " \
        "                                                              " \
        "  ┌──────────────────────────────────                         " \
        "  |Prexisting but modified commands:                          " \
        "  ├──────────────────────────────────                         " \
        "  |pwd                                                        " \
        "  └───┬────────────────────────────────────────────────────── " \
        "      |adds a little bit of text, and colors in the location  " \
        "  ┌───┴────────────────────────────────────────────────────── " \
        "  |clear                                                      " \
        "  └───┬───────────────────────────────────────────────────    " \
        "      |displays the home badge once the terminal is empty     " \
        "  ┌───┴───────────────────────────────────────────────────    " \
        "  |reset                                                      " \
        "  └───┬───────────────────────────────────────────────────    " \
        "      |displays the home badge once the terminal is reset     " \
        "  ┌───┴───────────────────────────────────────────────────    " \
        "  |mkdir                                                      " \
        "  └───┬───────────────────────────────────────────────────    " \
        "      |not only creates a directory, but cd's to it after     " \
        "      └───────────────────────────────────────────────────    " | less

        home
    }
#End



#Handy
    function macro () {
        if [[ -z "$1" ]]; then
            echo "executing macro..."
            echo ""
            
            # Check if SavedMacro is set before executing
            if [[ -n "$SavedMacro" ]]; then
                eval "$SavedMacro"
            else
                echo "No macro saved. Use \"macro create\" to create one."
            fi
            
        elif [[ "$1" = "create" ]]; then
            clear
            
            printf '%s\n' \
            " ____                                                                                 " \
            "|  _ \  _ __  ___    __ _  _ __  __ _  _ __ ___    _ __ ___    __ _   ___  _ __  ___  " \
            "| |_) || '__|/ _ \  / _' || '__|/ _' || '_ ' _ \  | '_ ' _ \  / _' | / __|| '__|/ _ \ " \
            "|  __/ | |  | (_) || (_| || |  | (_| || | | | | | | | | | | || (_| || (__ | |  | (_) |" \
            "|_|    |_|   \___/  \__, ||_|   \__,_||_| |_| |_| |_| |_| |_| \__,_| \___||_|   \___/ " \
            "                    |___/                                                             "

            echo ""
            echo "type in the commands you'd like to save, separated by \" && \" "
            echo ""
            
            read -r user_input
            ___var_overwrite "SavedMacro" "$user_input"
            echo "Macro saved successfully!"
            
        else
            echo "Usage: macro [create]"
            echo "  macro       - execute saved macro"
            echo "  macro create - create/update macro"
        fi
    
    }
    function .bashrc () {
        
        if [ "$1" = "reset" ]; then
        
                    

            # Display the names
            local name
            for name in "${ServerTemp2[@]}"; do
                echo "$name"
            done
            ___text_box "WARNING: you need to be in the directory .bashrc is normally placed in. This is usually /home, or /home/username" 4
            
            echo""
            echo "Continue? Y/n"

            read user_input
            
                if [ "$user_input" = "Y" ]; then
                    echo "reseting .bashrc file from /etc/skel/.bashrc (requires sudo permission)"
                    sudo cp /etc/skel/.bashrc ./.bashrc
                fi
        fi
    }
#End



#Files
    function lsg {
            # Display directory path
            local string="$PWD"
            local ln=${#string}
            local line=""
            for ((i=0; i<ln+2; i++)); do line+="─"; done
            echo " $string │"
            echo "$line┘"
            echo



            # ASCII art templates
            local -A ascii_art=(
                ["folder"]=" ____  _______ 
            │    \/       │
            ├────┘        │
            │             │
            │             │
            └─────────────┘"
                    ["text"]="   ___________ 
            /  ──────── │
            /  ───────── │
            │  ────────── │
            │ ─────────── │
            │ ─────────── │
            │ ─────────── │
            │ ─────────── │
            └─────────────┘"
                    ["doc"]="   ___________ 
            /           │
            / ┌────────┐ │
            │  │o --    │ │
            │  │        │ │
            │  │┌──────┐│ │
            │  └┤──────├┘ │
            │   │──────│  │
            │   └──────┘  │
            └─────────────┘"
                    ["sheet"]="   ___________ 
            /           │
            /            │
            │             │
            │ ┌┬┬┬┬┬┬┬┬┬┐ │
            │ ├┼┼┼┼┼┼┼┼┼┤ │
            │ ├┼┼┼┼┼┼┼┼┼┤ │
            │ ├┼┼┼┼┼┼┼┼┼┤ │
            │ └┴┴┴┴┴┴┴┴┴┘ │
            └─────────────┘"
                    ["image"]="   ___________ 
            /           │
            /            │
            │ ┌─────────┐ │
            │ │  /\   ° │ │
            │ │ /  \ /\ │ │
            │ │/    \  \│ │
            │ └─────────┘ │
            │             │
            └─────────────┘"
                    ["audio"]="   ___________ 
            /           │
            /            │
            │     |~~~~~| │
            │     |~~~~~| │
            │     |     | │
            │ /~~\| /~~\| │
            │ \__/  \__/  │
            │             │
            └─────────────┘"
                    ["video"]="   ___________ 
            /           │
            /            │
            │ ┌┬───────┬┐ │
            │ └┤   _   ├┘ │
            │ ┌┤  │ \  ├┐ │
            │ └┤  │_/  ├┘ │
            │ ┌┤       ├┐ │
            │ └┴───────┴┘ │
            └─────────────┘"
                    ["archive"]="   ___________ 
            /  ▄▀       │
            /   ▄▀       │
            │    ▄▀       │
            │    ▄▀       │
            │   ┌▄▀┐      │
            │   ├─▀┤      │
            │   └──┘      │
            │             │
            └─────────────┘"
                    ["exec"]="   ___________ 
            /           │
            /            │
            │  │\ │\ │\   │
            │  │ \│ \│ \  │
            │  │ /│ /│ /  │
            │  │/ │/ │/   │
            │             │
            │     Run     │
            └─────────────┘"
                    ["binary"]="   ___________ 
            /           │
            /         _  │
            │ ┌───┐   / │ │
            │ │┌─┐│  //││ │
            │ ││ ││    ││ │
            │ ││ ││    ││ │
            │ │└─┘│    ││ │
            │ └───┘    └┘ │
            └─────────────┘"
                    ["unknown"]="   ___________ 
            /           │
            /            │
            │             │
            │             │
            │             │
            │             │
            │             │
            │             │
            └─────────────┘"
                )

                # Get file type and return ASCII with centered filename
                get_ascii() {
                    local file="$1" type="unknown"
                    
                    if [[ -d "$file" ]]; then
                        type="folder"
                    elif [[ -f "$file" ]]; then
                        local mime=$(file --mime-type -b "$file" 2>/dev/null)
                        case "$mime" in
                            text/*|*json*|*xml*|*script*) type="text" ;;
                            *pdf*|*document*|*office*) type="doc" ;;
                            *sheet*|*csv*) type="sheet" ;;
                            image/*) type="image" ;;
                            audio/*) type="audio" ;;
                            video/*) type="video" ;;
                            *zip*|*tar*|*rar*|*7z*) type="archive" ;;
                            *) [[ -x "$file" ]] && type="exec" || type="binary" ;;
                        esac
                    fi
                    
                    # Add ASCII art lines
                    IFS=$'\n' read -rd '' -a lines <<< "${ascii_art[$type]}"
                    printf '%s\n' "${lines[@]}"
                    
                    # Add centered filename
                    local name="$file"
                    [[ ${#name} -gt 15 ]] && name="${name:0:12}..."
                    local pad=$(( (15 - ${#name}) / 2 ))
                    printf "%*s%s%*s \n" $pad "" "$name" $((15 - ${#name} - pad)) ""
                }

                # Get items
                local items=()
                if [[ "$1" == "-a" || "$1" == "--all" ]]; then
                    for item in .[^.]* ..?* *; do [[ -e "$item" ]] && items+=("$item"); done
                else
                    for item in *; do [[ -e "$item" ]] && items+=("$item"); done
                fi
                
                [[ ${#items[@]} -eq 0 ]] && { echo "No files found."; return; }

                # Calculate layout and display
                local cols=$(( $(tput cols 2>/dev/null || echo 80) / 17 ))
                [[ $cols -lt 1 ]] && cols=1
                
                for ((i=0; i<${#items[@]}; i+=cols)); do
                    local row_items=() max_lines=0
                    
                    # Collect ASCII for this row
                    for ((j=0; j<cols && i+j<${#items[@]}; j++)); do
                        readarray -t "ascii_$j" < <(get_ascii "${items[i+j]}")
                        row_items+=($j)
                        local -n arr="ascii_$j"
                        [[ ${#arr[@]} -gt $max_lines ]] && max_lines=${#arr[@]}
                    done
                    
                    # Print row line by line
                    for ((line=0; line<max_lines; line++)); do
                        local output=""
                        for col in "${row_items[@]}"; do
                            local -n arr="ascii_$col"
                            [[ $col -gt 0 ]] && output+="  "
                            output+="${arr[line]:-               }"
                        done
                        echo "$output"
                    done
                    
                    # Cleanup and spacing
                    for col in "${row_items[@]}"; do unset "ascii_$col"; done
                    [[ $((i + cols)) -lt ${#items[@]} ]] && echo
                done
    }
    
    function ___pwd_better {
            #ANSI colors
            local Red='\033[0;31m'
            local ResetColor='\033[0m'

            #Path data
            local name=$(basename $PWD)

            #Extract the prefix before the last part
            local path=$(echo "$PWD" | sed "s/${name}$//")

            #Construct the colored output string
            local output="${path}${Red}${name}${ResetColor}"

            # Print the result
            echo -e "Current directory: $output"
    }
    function mkdir_better () {
        # Check if at least one argument is provided
        if [ $# -eq 0 ]; then
            echo "Usage: mkdir_better <directory> [options...]"
            return 1
        fi
        
        # Use mkdir with all provided arguments
        if mkdir "$@"; then
            # If mkdir succeeded, cd to the first argument (the directory name)
            cd "${1}"
        else
            echo "Failed to create directory"
        fi
    }
    function backup () {
            if [ -z "$2" ]; then # This directory
                local file_content=$(cat "$1")
                echo "$file_content" > "$1.backup"
                echo "Backup file created successfully at ./$1.backup"
            elif [ -n "$2" ]; then # Another directory
                local file_content=$(cat "$1")
                echo "$file_content" > "$2/$1.backup"
                echo "Backup file created successfully at $2/$1.backup"
            fi
    }
#End



#Network
    function server () {
        
        local ServerTemp2=()  # Add this before the loop
        
        if [ "$1" = "ssh" ] || [ "$1" = "sftp" ]; then

            clear

            echo "type the name of the server you want to connect to from your keychain."
            echo ""

            # Split by commas since the data format uses commas as separators
            IFS=',' read -ra ServerTemp1 <<< "$ServerKeychain"
            
            # Extract just the names (first word of each comma-separated item)
            local item
            for item in "${ServerTemp1[@]}"; do
                # Trim whitespace and get first word
                local trimmed_item=$(echo "$item" | xargs)
                ServerTemp2+=("${trimmed_item%% *}")  # Remove everything after first space
            done
            
            # Display the names
            local name
            for name in "${ServerTemp2[@]}"; do
                echo "$name"
            done
            
            echo ""
            read user_input



            local string="$ServerKeychain"
            local result=$(echo "$string" | grep -o "$user_input [^,]*" | cut -d' ' -f2)
            echo "$result"



            echo "$1 tunnel will now connect, and run through a set of prompts. make sure you know your password. To disconnect, run \"exit\""
            echo ""
            

            local search_name="$user_input"
            local keychain="$ServerKeychain"
            
            # Split by commas since the data format uses commas as separators
            IFS=',' read -ra ServerTemp1 <<< "$keychain"
            
            # Search for the item by name
            local item
            for item in "${ServerTemp1[@]}"; do
                # Trim whitespace
                local trimmed_item=$(echo "$item" | xargs)
                
                # Extract name (text before first space) and value (text after first space)
                local item_name="${trimmed_item%% *}"
                local item_value="${trimmed_item#* }"
                
                # Connect ssh/sftp
                if [[ "$item_name" == "$search_name" ]]; then
                    $1 $item_value
                    return 0
                fi
            done
        fi
    }
    function netkeychain () {
        clear

        if [ "$1" = "ls" ]; then
            printf '%s\n' \
            " ____                          _                                           " \
            "/ ___|   __ _ __   __ ___   __| |  ___   ___  _ __ __   __ ___  _ __  ___  " \
            "\___ \  / _' |\ \ / // _ \ / _' | / __| / _ \| '__|\ \ / // _ \| '__|/ __| " \
            " ___) || (_| | \ V /|  __/| (_| | \__ \|  __/| |    \ V /|  __/| |   \__ \ " \
            "|____/  \__,_|  \_/  \___| \__,_| |___/ \___||_|     \_/  \___||_|   |___/ " \
            "────────────────────────────────────────────────────────────────────────── "
            
            echo ""
            
            # Clear previous arrays
            local ServerTemp1=()
            local ServerTemp2=()
            
            # Split by commas since the data format uses commas as separators
            IFS=',' read -ra ServerTemp1 <<< "$ServerKeychain"
            
            # Extract just the names (first word of each comma-separated item)
            local item
            for item in "${ServerTemp1[@]}"; do
                # Trim whitespace and get first word
                local trimmed_item=$(echo "$item" | xargs)
                if [[ -n "$trimmed_item" ]]; then
                    ServerTemp2+=("${trimmed_item%% *}")  # Remove everything after first space
                fi
            done
            
            # Display the names
            local name
            for name in "${ServerTemp2[@]}"; do
                echo "$name"
            done
            
        elif [ "$1" = "add" ]; then
            printf '%s\n' \
            "    _        _      _                                     " \
            "   / \    __| |  __| |  ___   ___  _ __ __   __ ___  _ __ " \
            "  / _ \  / _' | / _' | / __| / _ \| '__|\ \ / // _ \| '__|" \
            " / ___ \| (_| || (_| | \__ \|  __/| |    \ V /|  __/| |   " \
            "/_/   \_\\__,_| \__,_| |___/ \___||_|     \_/  \___||_|   " \
            "──────────────────────────────────────────────────────────"
            
            printf '%s\n' \

            "Notes:" \
            "for security reasons, passwords will not be saved in the keychain.                                 " \
            "if you are on the same network as the machine you're connecting to, you may not need to add a port." \
            "                                                                                                   " \
            "Type the following format to add a server to your Keychain:                                        " \
            "ServerAlias accountname@ipv4:port                                                                  " \
            "                                                                                                   " 

            read -r user_inputprintf '%s\n' \
            ___keychain_write "ServerKeychain" "$ServerKeychain,$user_input"
            echo "New ServerKeychain entry: $user_input"

        elif [ "$1" = "del" ]; then

            printf '%s\n' \
            " ____                                                                         " \
            "|  _ \  ___  _ __ ___    ___ __   __ ___   ___   ___  _ __ __   __ ___  _ __  " \
            "| |_) |/ _ \| '_ ' _ \  / _ \\ \ / // _ \ / __| / _ \| '__|\ \ / // _ \| '__| " \
            "|  _ <|  __/| | | | | || (_) |\ V /|  __/ \__ \|  __/| |    \ V /|  __/| |    " \
            "|_| \_\\___||_| |_| |_| \___/  \_/  \___| |___/ \___||_|     \_/  \___||_|    " \
            "───────────────────────────────────────────────────────────────────────────── "
            
            echo ""
            
            # Clear previous arrays
            local ServerTemp1=()
            local ServerTemp2=()
            
            # Split by commas since the data format uses commas as separators
            IFS=',' read -ra ServerTemp1 <<< "$ServerKeychain"
            
            # Extract just the names (first word of each comma-separated item)
            local item
            for item in "${ServerTemp1[@]}"; do
                # Trim whitespace and get first word
                local trimmed_item=$(echo "$item" | xargs)
                if [[ -n "$trimmed_item" ]]; then
                    ServerTemp2+=("${trimmed_item%% *}")  # Remove everything after first space
                fi
            done
            
            # Display the names
            local name
            for name in "${ServerTemp2[@]}"; do
                echo "$name"
            done

            echo ""
            echo "which would you like to remove?"
            echo ""
            read -r user_input

            # Use the ___keychain_del function to remove the item
            ServerKeychain=$(___keychain_del "$user_input" "$ServerKeychain")
            
            # Update the stored data (assuming ___keychain_write function exists)
            ___keychain_write "ServerKeychain" "$ServerKeychain"
            echo "Removed server: $user_input"
        fi
    }
#End



#Aliases (existing but modified)
    
    #Does not hav source code, references functions and commands.

    alias pwd="___pwd_better"

    alias mkdir="___mkdir_better"

    alias clear="command clear && home"
    alias reset="command reset && home"
    
#End



#Startup: initialize
home
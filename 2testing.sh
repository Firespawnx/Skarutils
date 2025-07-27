#!/bin/bash

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
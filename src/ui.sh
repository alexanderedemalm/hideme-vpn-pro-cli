# src/network.sh


# --- _select_server ---
# Arguments:
#   N/A
_select_server() {

    local title=" select server " # Title for option menu
    local -ri menu_content_width=25 # # The width of menu rendering

    local raw_input # Users raw input
    local -r servers=( # List of servers
        "[1] UK - London"
        "[2] NL - Netherlands"
        "[3] SE - Sweden"
        "[4] US - USA" 
    )

    # Prints option menu
    _print_formatted_list "$menu_content_width" "$title" "${servers[@]}" >/dev/tty

    # Reads user input
    read -rp "$(echo -e "\nEnter Region: ")" raw_input

    # Trim leading & trailing whitespace
    raw_input="${raw_input#"${raw_input%%[![:space:]]*}"}"
    raw_input="${raw_input%"${raw_input##*[![:space:]]}"}"

    # Too lowercase
    raw_input=${raw_input,,}

    # Find in servers, user server of choise
    for server in "${servers[@]}"; do

        # Extract at index
        local nr="${server:1:1}" # Option menu, e.g., 3
        local country_code="${server:4:2}" # Option menu, e.g., se
        local country="${server:9}" # Option menu, e.g., Sweden

        # Too lowercase
        country_code=${country_code,,}
        country=${country,,}

        if [[ "$raw_input" == "$nr" || "$raw_input" == "$country_code" \
                                    || "$raw_input" == "$country" ]]; then
            echo "$country_code"
            return 0
        fi
    done

    echo -e "\nError: invalid input\n"
    return 1
}

# --- loading_animation_start ---
# Arguments:
#   $1 (String): Title
_loading_animation_start() {

    local title="$1" # Title
    local spinner='-\|/' # Animation frames
    local i=0 # Animation reset

    # Start animation
    while true; do

        # Removes process [pid] print
        if [ "$i" == 0 ]; then
            echo -e "\033[A\033[K"
        fi

        echo -ne "\r[${title}] ${spinner:i++%${#spinner}:1}"
        sleep 0.1
    done &
    # Capture the PID of the background animation process
    _global_loading_variable=$!
}

# --- loading_animation_stop ---
# Arguments:
#   N/A
_loading_animation_stop() {

    if [ -n "$_global_loading_variable" ]; then
        kill "$_global_loading_variable" 2>/dev/null # Stop the process
        wait "$_global_loading_variable" 2>/dev/null # Wait too conintue
               _global_loading_variable="" # Clear the PID variable
        echo -ne "\r\033[K" 
    fi
}

# --- print_formatted_list ---
# Arguments:
#   $1 (Integer): content_width - The inner width for text elements (excluding borders).
#   $2 (String): title_string - The title to display at the top of the list.
#   $@ (Array): list_array - The list of option strings to display.
_print_formatted_list() {
    local -ri content_width=$1
    local title_string=$2
    local title_length="${#title_string}"
    
    shift 2
    local -r list_array=("$@")

    local -ri remaining_eq_space=$((content_width - title_length))
    local -ri eq_left=$((remaining_eq_space / 2))
    local -ri eq_right=$((remaining_eq_space - eq_left))

    _print_formatted_list__header "$eq_left" "$title_string" "$eq_right"
    _print_formatted_list__options $((content_width - 3)) "${list_array[@]}"
    _print_formatted_list__bottom $((content_width - 1))
}

# --- print_header ---
# Arguments:
#   $1 (Integer): eq_left - Number of '=' characters to print on the left.
#   $2 (String): title_string - The title to display.
#   $3 (Integer): eq_right - Number of '=' characters to print on the right.
_print_formatted_list__header() {
    local eq_left=$1
    local title_string=$2
    local eq_right=$3
    
    echo ""
    printf "%${eq_left}s" | tr ' ' '='
    echo -n "${title_string}"
    printf "%${eq_right}s" | tr ' ' '='
    echo ""
}

# --- print_options ---
# Arguments:
#   $1 (Integer): content_width - The inner width for text elements (excluding borders).
#   $@ (Array): list_array - The list of option strings to display.
_print_formatted_list__options() {
    local content_width=$1
    shift
    local list_array=("$@")

    for item in "${list_array[@]}"; do
        local item_length=${#item}
        local padding_needed=$((content_width - item_length))
        printf "| %s%*s |\n" "$item" "$padding_needed" ""
    done
}

# --- print_bottom_border ---
# Arguments:
#   $1 (int): border_width - The width of the border.
_print_formatted_list__bottom() {
    local border_width=$1

    echo -n  "|"
    printf "%${border_width}s" | tr ' ' '_'
    echo -ne "|\n"
}
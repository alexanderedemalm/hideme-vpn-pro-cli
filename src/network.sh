# src/network.sh

# --- _verify_connection ---
# Arguments:
#   N/A
_verify_connection() {

    local title=" connection info " # Title for option menu
    local -ri menu_content_width=37 # # The width of menu rendering

    local interface # Interface
    local -A data_formated # Connection info
    local services_status # Services status

    # Services status
    if [[ -z "$(_active_services)" ]]; then
        services_status="[DOWN]"
    else 
        services_status="[UP]"
    fi

    # Fetching interface & conection info
    interface=$(_verify_connection__interface)
    eval "$(_verify_connection__info)"

    # Connection info
    local -r data_display=(
        "Service: ${services_status}"
        "Interface: ${interface^^}"
        "IP adress: ${data_formated[ip]}"
        "Country: ${data_formated[country]} Server: ${data_formated[server]^^}"
    )
    
     # Prints option menu
    _print_formatted_list "$menu_content_width" "$title" "${data_display[@]}" >/dev/tty
}


# --- verify_connection___interface ---
# Arguments:
# N/A
_verify_connection__interface() {
    
    local interface
    
    # Grep vpn interface
    interface=$(ip a | grep -Po '^\d+: (\Kvpn[0-9]*|tun[0-9]*)(?=:)' | head -n 1
               #ip a | grep -Po '^\d+: (\Kvpn[0-9]*|tun[0-9]*)(?=:)' 
               #ip a | grep -Po '^\d+: (\Kwlo1)(?=:)' || \
               #ip a | awk '/^[0-9]+: /{print $2}' | sed 's/://' | grep -vE 'lo' | head -n 1
    )

    # Interface not null
    if [[ -z "$interface" ]]; then
        echo "N/A"
        return 0
    fi

    echo "$interface"
    return 0
}


# --- verify_connection___interface ---
# Arguments:
# N/A
_verify_connection__info() {

    local raw_json
    declare -A data_formated

    # Use ifconfig.me, while ipinfo.io as a fallback
    raw_json=$(curl -s https://api.hide.me/ip)

    # Raw json not null
    if [[ -z "$raw_json" ]]; then
        echo "N/A"
        return 1
    fi

    data_formated[ip]=$(echo "$raw_json" | jq -r '.ip // "N/A"')
    data_formated[country]=$(echo "$raw_json" | jq -r '.countryName // "N/A"')
    data_formated[server]=$(echo "$raw_json" | jq -r '.countryCode // "N/A"')
    data_formated[isConnected]=$(echo "$raw_json" | jq -r '.isConnected // false | tostring')
    
    declare -p data_formated
    return 0
}
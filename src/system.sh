# src/system.sh

# --- _start_service ---
# Arguments:
#   $1 (string): The chosen server region code (e.g., "se").
_start_service() {

    local server_name="$1" # Service name
    local max_attempts=3 # Limit attempts
    local counter=0 # Reset attempts

    # Service to start
    local service="hide.me@${server_name}.service"

    while [[ "$counter" -lt "$max_attempts" ]]; do 

        if sudo systemctl start "$service" &>/dev/null; then
            return 0
        fi
            echo -e "\nWarning: failed to start service, new attempt...\n"
            ((counter++))
            sleep 0.2
    done

    echo -e "\nError: system service failed to start 'hide.me@${server_name}'" \
            "\nChecking status...\n" >&2

    return 1
}

# --- stop_services ---
# Arguments:
#   N/A
_stop_services() {

    # Stopping services
    while read -r service_name; do

        if sudo systemctl stop "$service_name" &>/dev/null; then
            _stop_services__wait_for_stop "$service_name"
        elif [ -n "$service_name" ]; then
            echo -e "Error: failed to stop ${service_name}. Might already be stopped or an issue\n"
        fi
    done <<< "$(_active_services)"
}

# --- _stop_services__wait_for_stop ---
# Arguments:
#   $1 (String): The service name to stop
_stop_services__wait_for_stop() {
    
    local service_name=$1
    
    # Stopping service
    while sudo systemctl is-active --quiet "$service_name"; do
        sleep 0.2
    done
}

# --- active_services ---
# Arguments: 
#   N/A
_active_services() {
    
    local service_pattern="hide.me@.*\.service" # Services name whildcard
    local services_active # Services processes
    local services_vpn # Fetching active processes

    # sudo__superuser, systemctl__service manager, 
    # list-units__list systemd units, --type=service__services only, 
    # --state=active__active services, --no-legend__supress header
    services_active=$(sudo systemctl list-units --type=service --state=active \
                                                --no-legend 2>/dev/null)

    # Extract hide.me service names
    services_vpn=$(echo "$services_active" | grep -E "$service_pattern" \
                                           | awk '{print $1}' \
                                           || true)

    echo "$services_vpn"
}

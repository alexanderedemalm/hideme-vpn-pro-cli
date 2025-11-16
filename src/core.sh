# src/core.sh


_get_privileges() {
    echo -e "\n"

    if ! sudo -v; then 
        exit 1
    fi
}

_drop_privileges() {
    sudo -k
}

_get_privileges_read_file() {
    local file_path="$1"

    _get_privileges

    if [[ -z "$file_path" ]]; then
        echo -e "\nError: File path is required.\n"
        exit 1
    fi

    content=$(sudo cat "$file_path" 2>/dev/null)

    # Check if the read was successful
    if [[ -z "$content" ]] && [[ $? -ne 0 ]]; then
        echo -e "\nError: reading file: $file_path" >&2
        echo -e "\n"
        return 1
    fi

    _drop_privileges
    
    echo "$content" # Output the content to stdout
    return 0
}

_get_privileges_write_file() {
    local file_path="$1"
    local value="$2"

     _get_privileges

    if [[ -z "$file_path" || -z "$value" ]]; then
        echo -e "\nError: File path and value are required.\n" >&2
        exit 1
    fi

    echo "$value" | sudo tee "$file_path" >/dev/null 2>&1

    _drop_privileges

    if [[ $exit_code -ne 0 ]]; then
        echo "Error writing value to $file_path" >&2
        return 1
    fi
}
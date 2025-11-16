# src/main.sh

#  ========================================================
#       HIDE.ME VPN [ Main Functions ]
#  =========================================================
# |                                                         |
# |                                                         |
# |      ===============                                    |
# |   =====================                                 |
# |  ==                   ==                                |
# |      _=============_                          /=====\\  |
# |         _=======_               _============|      ||  |
# |           /==\                  \/\/\_/\/\__/|      //  |      
# |           \==/                                \____//   |        
# |_________________________________________________________|


#  ========================================================
#       GLOBAL [ variables ]
#  =========================================================
# |                                                         |
# | - global_loading_variable                               |
# |_________________________________________________________|


# Animation global variable
_global_loading_variable=""


#  ========================================================
#       SECTION [ ALIASES ]
#  =========================================================
# |                                                         |
# | - N/A                                                   |
# |_________________________________________________________|


#  ========================================================
#       SECTION [ functions ]
#  =========================================================
# |                                                         |
# | = establish connection                                  |
# |     - connect                                           |
# |     - connect_server                                    |
# | = discontinue connection                                |
# |     - disconnect                                        |
# | = verify connection                                     |
# |     - status                                            |
# |_________________________________________________________|


#  ========================================================
#       SECTION-INNER [ establish connection ]
#  =========================================================


# --- connect ---
# Arguments:
#   N/A
connect() {
    
    local val_server="se"

    # Run as superuser
    _get_privileges

    _loading_animation_start "connecting"

    # Ensure any existing VPN connections are stopped.
    _stop_services

    # Start_service / establish connection
    _start_service "$val_server"

    _loading_animation_stop

    # Verify connection
    _verify_connection

    # Stops user from running superuser
    _drop_privileges
}


# --- connect_server ---
# Arguments:
#   N/A
connect_server() {
    
    local val_server

    # Run as superuser
    _get_privileges

    val_server=$(_select_server)
    local input_status=$?

    if [ "$input_status" -ne 0 ]; then
        return 1 # if input status equals error than will exit script
    fi

    _loading_animation_start "connecting"

    # Ensure any existing VPN connections are stopped.
    _stop_services

    # Start_service / establish connection
    _start_service "$val_server"

    _loading_animation_stop

    # Verify connection
    _verify_connection

    # Stops user from running superuser
    _drop_privileges
}


#  ========================================================
#       SECTION-INNER [ discontinue connection ]
#  =========================================================


# --- disconnect ---
# Arguments:
#   N/A
disconnect() {

    # Run as superuser
    _get_privileges

    _loading_animation_start "disconnecting"

    # Ensure any existing VPN connections are stopped.
    _stop_services

    _loading_animation_stop

    # Verify connection status
    _verify_connection

    # Stops user from running superuser
    _drop_privileges
}


#  ========================================================
#       SECTION-INNER [ verify connection ]
#  =========================================================


# --- status ---
# Arguments.
#   N/A
status() {

    # Run as superuser
    _get_privileges

    # Verify connection status
    _verify_connection

    # Stops user from running superuser
    _drop_privileges
}
#!/bin/bash

# Make Executable 
# chmod +x ./doc_ref_auto/main.sh
#
# Execute script 
#./doc_ref_auto/main.sh

# Example comment-structure
#/*!
# @brief Short explanation of what the function does
#
# @Param describe what ingoing parameters, 
# if not N/A or avoid using @param
#
# @return explain what the functions returns, 
# if not N/A or avoid using @return
# */

# Result
#### Function: `connect`
#
#  **Brief:** Short explanation of what the function does
#
#  ''Parameter: describe what ingoing parameters, 
#if not N/A or avoid using @param 
#
#  **Returns:** explain what the functions returns, 
#if not N/A or avoid using @return

# DOCS output
DOC_DIR="docs"
DOC_FILE="$DOC_DIR/API_reference.md"

# DOCS directory to search
DIRS=("bin" "src") 

# AWK parser logick file
AWK_SCRIPT="./doc_ref_auto/parser_logic.awk"

_documentation_extraction() {
    # 1. Capture (file path)
    local file_path="$1"
    
    if [ ! -f "$AWK_SCRIPT" ]; then
        echo "Error: AWK script not found at $AWK_SCRIPT" >&2
        return 1
    fi
    
    # 3. Execute the AWK parser
    # -v OFILE passes the main output file path to AWK
    # -f executes the logic from the external file
    awk -v OFILE="$DOC_FILE" -f "$AWK_SCRIPT" "$file_path"
}

_loop_project_dirs() {
    for dir in "${DIRS[@]}"; do

        if [ ! -d "$dir" ]; then 
            echo -e "\n\nWarning: directory '$dir' does not exist, skipping..."
            continue
        fi 
        
        find "$dir" -name "*.sh" | while read -r file_path; do 

            echo "" >> "$DOC_FILE"
            echo "## File: $(basename "$file_path")" >> "$DOC_FILE"
            echo "*(Path: $file_path)*" >> "$DOC_FILE"
            echo "---" >> "$DOC_FILE"
            echo "" >> "$DOC_FILE"

            _documentation_extraction "$file_path"

        done
    done
}

# Create Doc directory if not exists
mkdir -p "$DOC_DIR"

# Initialize DOC file with header
echo -e "\n\n# Project API Reference" > "$DOC_FILE"
echo -e "---" >> "$DOC_FILE"

# Start documentaion process
_loop_project_dirs

# Print location of generated file
echo -e "\n\nDocumentation generated at: $DOC_FILE"
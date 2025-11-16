function clean_line(line) {
    gsub(/^[[:space:]]*#/, "", line);

    gsub(/^[[:space:]]*\*/, "", line);

    gsub(/^[[:space:]]*\//, "", line);

    return line;
}    

function output_doc(func_name, doc_buffer, output_file) {
    if (doc_buffer != "") {

        # Print function header
        print "### Function: `" func_name "`\n" >> output_file

        # Format and print the @tags
        gsub(/@brief /, " **Brief:** ", doc_buffer);
        gsub(/@param /, "\n  **Parameter:** ", doc_buffer);
        gsub(/@return /, "\n  **Returns:** ", doc_buffer);

        print doc_buffer "\n" >> output_file;
    }
}   

BEGIN {
    false = 0;
    true = 1;

    in_doc = false;
    doc = "";
}

/^#\/\*!/ { 
    in_doc = true; 
    doc = ""; 
    next 
}

in_doc {

    if ($0 !~ /^[[:space:]]*#/) {
        in_doc = false;
        
    } else {
        
        cleaned_line = clean_line($0);
        
        if (cleaned_line ~ /^[[:space:]]*$/) {
            next
        }

        doc = doc cleaned_line "\n";
        next
    }
}

# Regex pattern matching 

/^[[:space:]]*(function)?[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\).*\{/ {
    match($0, /[a-zA-Z_][a-zA-Z0-9_]*\(\)/);
    func_name = substr($0, RSTART, RLENGTH - 2);

    output_doc(func_name, doc, OFILE);

    doc = "";
    in_doc = false;

}

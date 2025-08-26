#!/bin/bash

# Name of the output file
OUTPUT_FILE="index.html"

# Function to get the most recent commit message for a file
get_commit_message() {
    local file=$1
    git log --oneline -1 -- "$file" 2>/dev/null | cat || echo "Not committed yet"
}

# Start writing the HTML content
cat > "$OUTPUT_FILE" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Status Index</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 40px; }
        h1 { color: #333; }
        ul { list-style-type: none; padding-left: 20px; }
        li { margin: 5px 0; }
        a { color: #0366d6; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .commit { font-style: italic; color: #555; font-size: 0.9em; margin-left: 10px; }
        .folder { font-weight: bold; color: #28a745; }
    </style>
</head>
<body>
    <h1>Daily Status Project Index</h1>
    <p><em>This file was automatically generated on $(date).</em></p>
    <p>Use this page to navigate all daily status files. Click on any file to open it.</p>

    <h2>File and Folder Structure</h2>
EOF

# Function to generate HTML for a given directory
generate_tree() {
    local dir=$1
    local indent=$2

    # Find all items, excluding .git, the index file, and this script itself
    local entries=$(find "$dir" -maxdepth 1 -mindepth 1 \( -name ".git" -o -name "$OUTPUT_FILE" -o -name "generate_index.sh" \) -prune -o -print | sort)

    echo "${indent}<ul>"

    for entry in $entries; do
        local base_entry=$(basename "$entry")
        if [[ -d "$entry" ]]; then
            # It's a directory
            echo "${indent}  <li class=\"folder\">📁 $base_entry/</li>"
            generate_tree "$entry" "${indent}  " # Recurse into the directory
        else
            # It's a file
            local commit_msg=$(get_commit_message "$entry")
            # Create a relative path for the href link
            local relative_path=${entry#./}
            echo "${indent}  <li>📄 <a href=\"$relative_path\">$base_entry</a> - <span class=\"commit\">$commit_msg</span></li>"
        fi
    done

    echo "${indent}</ul>"
}

# Generate the tree structure, starting from the current directory
generate_tree "." "    " >> "$OUTPUT_FILE"

# Close the HTML tags
cat >> "$OUTPUT_FILE" << EOF
</body>
</html>
EOF

echo "✅ Successfully generated '$OUTPUT_FILE'!"
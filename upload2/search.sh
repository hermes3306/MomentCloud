#!/bin/bash

# Check if a directory path is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Directory to search in
search_dir="$1"

# Check if the directory exists
if [ ! -d "$search_dir" ]; then
    echo "Error: Directory '$search_dir' does not exist."
    exit 1
fi

# Find all .csv files and check for corresponding .mnt files
echo "Matching files:"
for csv_file in "$search_dir"/*.csv; do
    # Check if there are any .csv files
    [ -e "$csv_file" ] || continue
    
    # Get the base name without extension
    base_name=$(basename "$csv_file" .csv)
    
    # Check if a corresponding .mnt file exists
    if [ -f "$search_dir/$base_name.mnt" ]; then
        echo "$base_name"
    fi
done

echo "Search completed."

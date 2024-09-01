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

# Counter for deleted files
deleted_count=0

# Find all .csv files and check for corresponding .mnt files
for csv_file in "$search_dir"/*.csv; do
    # Check if there are any .csv files
    [ -e "$csv_file" ] || continue
    
    # Get the base name without extension
    base_name=$(basename "$csv_file" .csv)
    
    # Check if a corresponding .mnt file exists
    mnt_file="$search_dir/$base_name.mnt"
    if [ -f "$mnt_file" ]; then
        echo "Deleting: $mnt_file"
        rm "$mnt_file"
        if [ $? -eq 0 ]; then
            ((deleted_count++))
        else
            echo "Error deleting $mnt_file"
        fi
    fi
done

echo "Deletion completed. $deleted_count .mnt file(s) were deleted."

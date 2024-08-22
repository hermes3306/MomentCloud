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

# Find and delete empty files
find "$search_dir" -type f -size 0 -print -delete

echo "Finished deleting empty files in $search_dir"

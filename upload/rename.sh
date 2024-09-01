#!/bin/bash

# Script to rename yyyymmdd.csv files to yyyymmdd_000000.csv

# Set the directory where the CSV files are located
# Change this to the actual directory path if different
CSV_DIR="."

# Change to the directory containing the CSV files
cd "$CSV_DIR" || exit

# Counter for renamed files
count=0

# Loop through all CSV files matching the pattern
for file in ????????.csv; do
    # Check if the file exists (to handle cases where no matching files are found)
    if [[ -f "$file" ]]; then
        # Create the new filename
        newname="${file%.csv}_000000.csv"
        
        # Rename the file
        mv "$file" "$newname"
        
        # Increment the counter
        ((count++))
        
        # Print a message
        echo "Renamed $file to $newname"
    fi
done

# Print summary
echo "Renamed $count file(s)"

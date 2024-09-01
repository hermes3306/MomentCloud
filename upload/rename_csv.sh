#!/bin/bash

# Loop through all CSV files in the current directory
for file in *.csv; do
    # Check if the file exists and is readable
    if [ -f "$file" ] && [ -r "$file" ]; then
        # Extract the second line of the file
        second_line=$(sed -n '2p' "$file")
        
        # Extract the date and time fields
        IFS=',' read -r _ _ date time <<< "$second_line"
        
        # Remove forward slashes from date and colons from time
        date_formatted=$(echo "$date" | tr -d '/')
        time_formatted=$(echo "$time" | tr -d ':')
        
        # Construct the new filename
        new_filename="${date_formatted}_${time_formatted}.csv"
        
        # Rename the file
        mv "$file" "$new_filename"
        echo "Renamed: $file -> $new_filename"
    else
        echo "Error: Cannot read file $file"
    fi
done

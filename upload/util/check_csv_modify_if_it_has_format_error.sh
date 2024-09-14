#!/bin/bash

# Function to validate date format (YYYY/MM/DD)
validate_date() {
    date -d "$1" >/dev/null 2>&1
}

# Function to validate time format (HH:MM:SS)
validate_time() {
    [[ $1 =~ ^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$ ]]
}

# Process each .csv file in the current directory
for file in *.csv; do
    if [ -f "$file" ]; then
        echo "Processing $file..."
        
        # Create a temporary file
        temp_file=$(mktemp)
        
        # Process the file line by line
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Remove carriage return (Windows format)
            line=${line//$'\r'/}
            
            # Split the line into fields
            IFS=',' read -ra fields <<< "$line"
            
            # Check if the line has exactly 4 fields
            if [ ${#fields[@]} -eq 4 ]; then
                # Validate date and time format
                if validate_date "${fields[2]}" && validate_time "${fields[3]}"; then
                    echo "$line" >> "$temp_file"
                fi
            fi
        done < "$file"
        
        # Replace the original file with the processed content
        mv "$temp_file" "$file"
        echo "Finished processing $file"
    fi
done

echo "All CSV files have been processed."

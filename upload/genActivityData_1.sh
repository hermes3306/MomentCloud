#!/bin/bash

# Function to calculate approximate distance between two points
calculate_distance() {
    local lat1=$1
    local lon1=$2
    local lat2=$3
    local lon2=$4
    
    # Rough approximation (suitable for small distances)
    local dlat=$(echo "$lat2 - $lat1" | awk '{printf "%.6f", $1}')
    local dlon=$(echo "$lon2 - $lon1" | awk '{printf "%.6f", $1}')
    local distance=$(echo "sqrt($dlat*$dlat + $dlon*$dlon) * 111" | awk '{printf "%.2f", $1}')
    
    echo $distance
}

# Function to generate track image (placeholder)
generate_track_image() {
    local filename=$1
    local picname="${filename%.*}_track.png"
    echo "Generating track image for $filename as $picname" >&2
    # Replace this with actual image generation logic
    touch "$picname"
}

# Start writing to activityDataList.xml
echo "<ActivityDataList>" > activityDataList.xml

for file in *.csv; do
    if [ -f "$file" ] && [ -r "$file" ]; then
        # Read the first data line (second line of the file)
        first_line=$(sed -n '2p' "$file")
        IFS=',' read -r start_lat start_lon start_date start_time <<< "$first_line"
        
        # Read the last line of the file
        last_line=$(tail -n 1 "$file")
        IFS=',' read -r end_lat end_lon end_date end_time <<< "$last_line"
        
        # Calculate start and end timestamps
        start_timestamp=$(date -d "${start_date} ${start_time}" +%s)
        end_timestamp=$(date -d "${end_date} ${end_time}" +%s)
        
        # Calculate elapsed time
        elapsed_time=$((end_timestamp - start_timestamp))
        
        # Calculate distance
        distance=$(calculate_distance $start_lat $start_lon $end_lat $end_lon)
        
        # Generate track image
        generate_track_image "$file"
        picname="${file%.*}_track.png"
        
        # Output ActivityData to XML file
        {
            echo "  <ActivityData>"
            echo "    <id>$(date +%s%N)</id>"
            echo "    <filename>$file</filename>"
            echo "    <type>WALK</type>"
            echo "    <name>Activity from $start_date</name>"
            echo "    <startTimestamp>$start_timestamp</startTimestamp>"
            echo "    <endTimestamp>$end_timestamp</endTimestamp>"
            echo "    <startLocationId>0</startLocationId>"
            echo "    <endLocationId>0</endLocationId>"
            echo "    <distance>$distance</distance>"
            echo "    <elapsedTime>$elapsed_time</elapsedTime>"
            echo "    <address>Unknown</address>"
            echo "    <trackImage>$picname</trackImage>"
            echo "  </ActivityData>"
        } >> activityDataList.xml
    fi
done

# Close the ActivityDataList tag
echo "</ActivityDataList>" >> activityDataList.xml

echo "activityDataList.xml has been generated successfully."

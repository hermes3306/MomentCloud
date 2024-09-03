#!/bin/bash

# Replace with your actual Google Maps API key
GOOGLE_MAPS_API_KEY="YOUR_GOOGLE_MAPS_API_KEY"

# Function to calculate approximate distance between two points
calculate_distance() {
    local lat1=$1
    local lon1=$2
    local lat2=$3
    local lon2=$4
    awk -v lat1="$lat1" -v lon1="$lon1" -v lat2="$lat2" -v lon2="$lon2" '
    function deg2rad(deg) { return deg * 3.14159 / 180 }
    BEGIN {
        R = 6371 # Earth radius in kilometers
        dlat = deg2rad(lat2 - lat1)
        dlon = deg2rad(lon2 - lon1)
        a = sin(dlat/2) * sin(dlat/2) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dlon/2) * sin(dlon/2)
        c = 2 * atan2(sqrt(a), sqrt(1-a))
        distance = R * c
        printf "%.6f", distance
    }'
}

generate_track_image() {
    local filename=$1
    local picname="${filename%.*}_track.png"
    echo "Generating track image for $filename as $picname" >&2

    # Read coordinates from the file
    local coordinates=""
    while IFS=',' read -r lat lon _; do
        if [ "$lat" != "lat" ]; then
            coordinates+="${lat},${lon}|"
        fi
    done < "$filename"
    coordinates=${coordinates%|}  # Remove trailing |

    # Prepare the URL for Google Maps Static API
    local url="https://maps.googleapis.com/maps/api/staticmap?"
    url+="size=600x400&"  # Image size
    url+="maptype=roadmap&"
    url+="path=color:0x0000ff|weight:5|${coordinates}&"  # Blue track line
    url+="markers=color:green|label:S|${coordinates%%|*}&"  # Start marker
    url+="markers=color:red|label:E|${coordinates##*|}&"  # End marker
    url+="key=${GOOGLE_MAPS_API_KEY}"

    # Download the image
    if ! curl -s "$url" -o "$picname"; then
        echo "Failed to generate track image for $filename" >&2
        return 1
    fi

    echo "Track image generated: $picname" >&2
}

# Start writing to activityDataList.xml
echo "<ActivityDataList>" > activityDataList.xml

for file in *.csv; do
    if [ -f "$file" ] && [ -r "$file" ]; then
        # Read the header line
        read header < "$file"
        
        # Initialize variables
        total_distance=0
        prev_lat=""
        prev_lon=""
        start_timestamp=""
        end_timestamp=""
        
        # Process each line of the CSV file
        while IFS=',' read -r lat lon date time; do
            # Skip the header line
            if [ "$lat" != "lat" ]; then
                # Set start timestamp if it's not set
                if [ -z "$start_timestamp" ]; then
                    start_timestamp=$(date -d "${date} ${time}" +%s)
                    start_lat=$lat
                    start_lon=$lon
                fi
                
                # Update end timestamp
                end_timestamp=$(date -d "${date} ${time}" +%s)
                
                # Calculate distance if we have a previous point
                if [ -n "$prev_lat" ]; then
                    segment_distance=$(calculate_distance $prev_lat $prev_lon $lat $lon)
                    total_distance=$(awk -v a="$total_distance" -v b="$segment_distance" 'BEGIN {print a + b}')
                fi
                
                # Update previous coordinates
                prev_lat=$lat
                prev_lon=$lon
            fi
        done < "$file"
        
        # Calculate elapsed time
        elapsed_time=$((end_timestamp - start_timestamp))
        
        # Generate track image
        generate_track_image "$file"
        picname="${file%.*}_track.png"
        
        # Output ActivityData to XML file
        {
            echo "  <ActivityData>"
            echo "    <id>$(date +%s%N)</id>"
            echo "    <filename>${file%.*}</filename>"
            echo "    <type>Run</type>"
            echo "    <name>Activity from ${date}</name>"
            echo "    <startTimestamp>$start_timestamp</startTimestamp>"
            echo "    <endTimestamp>$end_timestamp</endTimestamp>"
            echo "    <startLocationId>0</startLocationId>"
            echo "    <endLocationId>0</endLocationId>"
            echo "    <distance>$(printf "%.2f" $total_distance)</distance>"
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

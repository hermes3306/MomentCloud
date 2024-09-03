#!/bin/bash

# 함수: 시간 차이 계산 (초 단위)
time_diff() {
    start=$1
    end=$2
    start_sec=$(date -d "$start" +%s)
    end_sec=$(date -d "$end" +%s)
    echo $((end_sec - start_sec))
}

# 함수: 거리 계산 (Haversine 공식)
calculate_distance() {
    lat1=$1
    lon1=$2
    lat2=$3
    lon2=$4
    
    awk -v lat1="$lat1" -v lon1="$lon1" -v lat2="$lat2" -v lon2="$lon2" '
    function deg2rad(deg) { return deg * 3.14159265359 / 180 }
    BEGIN {
        R = 6371  # 지구 반경 (km)
        dlat = deg2rad(lat2 - lat1)
        dlon = deg2rad(lon2 - lon1)
        a = sin(dlat/2)^2 + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dlon/2)^2
        c = 2 * atan2(sqrt(a), sqrt(1-a))
        distance = R * c
        printf "%.6f", distance
    }'
}

# CSV 파일 처리
for file in *.csv; do
    if [[ -f "$file" ]]; then
        echo "처리 중인 파일: $file"
        
        # 파일 이름에서 ^M 제거
        new_file=$(echo "$file" | tr -d '\r')
        if [[ "$file" != "$new_file" ]]; then
            mv "$file" "$new_file"
            echo "파일 이름 변경: $file -> $new_file"
        fi
        
        # 파일 내용에서 ^M 제거하고 임시 파일에 저장
        tr -d '\r' < "$new_file" > "${new_file}.tmp"
        mv "${new_file}.tmp" "$new_file"
        
        # 데이터 분석
        total_distance=0
        start_time=""
        end_time=""
        prev_lat=""
        prev_lon=""
        
        while IFS=',' read -r lat lon date time || [[ -n "$lat" ]]; do
            if [[ -z "$start_time" ]]; then
                start_time="${date} ${time}"
            fi
            end_time="${date} ${time}"
            
            if [[ -n "$prev_lat" && -n "$prev_lon" ]]; then
                distance=$(calculate_distance $prev_lat $prev_lon $lat $lon)
                total_distance=$(awk -v td="$total_distance" -v d="$distance" 'BEGIN {printf "%.6f", td + d}')
            fi
            
            prev_lat=$lat
            prev_lon=$lon
        done < "$new_file"
        
        # 결과 출력
        duration=$(time_diff "$start_time" "$end_time")
        hours=$(awk -v d="$duration" 'BEGIN {printf "%.2f", d / 3600}')
        avg_speed=$(awk -v td="$total_distance" -v h="$hours" 'BEGIN {printf "%.2f", td / h}')
        
        echo "시작 시간: $start_time"
        echo "종료 시간: $end_time"
        echo "총 시간: $(date -u -d @${duration} +"%H:%M:%S")"
        echo "총 거리: $(printf "%.2f" $total_distance) km"
        echo "평균 속도: ${avg_speed} km/h"
        echo "------------------------"
    fi
done

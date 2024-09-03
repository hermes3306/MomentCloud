#!/bin/bash

for file in *; do
    # 파일 이름이 yyyymmdd_hhmmss 형식으로 시작하고 .csv로 끝나는지 확인
    if [[ $file =~ ^([0-9]{8}_[0-9]{6}).*\.csv$ ]]; then
        # 정규표현식에서 캡처한 yyyymmdd_hhmmss 부분
        date_time=${BASH_REMATCH[1]}
        
        # 새 파일 이름 생성 (yyyymmdd_hhmmss.csv)
        new_name="${date_time}.csv"
        
        # 파일 이름 변경
        if [ "$file" != "$new_name" ]; then
            mv "$file" "$new_name"
            echo "Renamed: $file -> $new_name"
        fi
    fi
done

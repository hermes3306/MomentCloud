#!/bin/bash

# 현재 디렉토리의 모든 CSV 파일을 처리
for file in *.csv
do
    if [ -f "$file" ]; then
        echo "Processing $file"
        
        # 파일의 첫 번째 줄 읽기
        first_line=$(head -n 1 "$file")
        
        # 첫 번째 줄이 'x,y,d,t'가 아니면 수정
        if [ "$first_line" != "x,y,d,t" ]; then
            echo "Modifying header in $file"
            
            # 임시 파일 생성
            temp_file=$(mktemp)
            
            # 새로운 헤더 추가
            echo "x,y,d,t" > "$temp_file"
            
            # 원본 파일의 내용을 임시 파일에 추가 (첫 번째 줄 제외)
            tail -n +2 "$file" >> "$temp_file"
            
            # 임시 파일을 원본 파일로 이동
            mv "$temp_file" "$file"
        else
            echo "Header already correct in $file"
        fi
    fi
done

echo "All CSV files processed"

#!/bin/bash

# 현재 디렉토리의 모든 CSV 파일에 대해 반복
for file in *.csv; do
    # 파일이 실제로 존재하는지 확인
    if [[ -f "$file" ]]; then
        # 파일 이름에서 날짜와 시간 추출
        if [[ $file =~ ([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{6})\.csv$ ]]; then
            year="${BASH_REMATCH[1]}"
            month="${BASH_REMATCH[2]}"
            day="${BASH_REMATCH[3]}"
            time="${BASH_REMATCH[4]}"
            
            # 새 파일 이름 형식 생성
            new_filename="${year}${month}${day}_${time}.csv"
            
            # 파일 이름 변경
            mv "$file" "$new_filename"
            echo "변경됨: $file -> $new_filename"
        else
            echo "건너뜀: $file (형식이 맞지 않음)"
        fi
    fi
done

echo "모든 파일 처리 완료."

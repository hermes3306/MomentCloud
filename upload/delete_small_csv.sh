#!/bin/bash

# CSV 파일이 있는 디렉토리 설정
# 실제 디렉토리 경로로 변경하세요
CSV_DIR="."

# 삭제된 파일 수를 세는 카운터
deleted_count=0

# CSV_DIR로 이동
cd "$CSV_DIR" || exit

# 모든 CSV 파일을 순회
for file in *.csv; do
    # 파일이 실제로 존재하는지 확인
    if [[ -f "$file" ]]; then
        # 파일 크기 확인 (바이트 단위)
        file_size=$(stat -c%s "$file")
        
        # 파일 크기가 1000 바이트 이하인 경우
        if [ "$file_size" -le 1000 ]; then
            # 파일 삭제
            rm "$file"
            ((deleted_count++))
            echo "삭제됨: $file (크기: $file_size 바이트)"
        fi
    fi
done

# 요약 출력
echo "총 $deleted_count 개의 파일이 삭제되었습니다."

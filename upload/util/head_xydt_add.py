import os

def add_header_if_missing(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    
    lines = content.split('\n')
    if lines[0].strip().lower() != 'x,y,d,t':
        with open(file_path, 'w') as file:
            file.write('x,y,d,t\n' + content)
        print(f"{file_path}에 헤더가 추가되었습니다.")
    else:
        print(f"{file_path}에 헤더가 이미 존재합니다.")

def process_csv_files(directory):
    for filename in os.listdir(directory):
        if filename.endswith('.csv'):
            file_path = os.path.join(directory, filename)
            add_header_if_missing(file_path)

# 작업할 디렉토리를 지정하세요
directory = '.'

process_csv_files(directory)

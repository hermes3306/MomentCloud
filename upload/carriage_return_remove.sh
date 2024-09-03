import csv
from datetime import datetime, timedelta
from math import radians, sin, cos, sqrt, atan2

def haversine_distance(lat1, lon1, lat2, lon2):
    R = 6371  # Earth's radius in kilometers

    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    distance = R * c

    return distance

def analyze_gps_data(file_path):
    with open(file_path, 'r', newline='') as file:
        reader = csv.reader(file)
        data = list(reader)

    total_distance = 0
    total_time = timedelta()
    start_time = None
    end_time = None
    prev_lat, prev_lon = None, None

    for row in data:
        # Remove any trailing ^M characters
        row = [field.rstrip('\r') for field in row]
        lat, lon, date, time = row
        lat, lon = float(lat), float(lon)
        current_time = datetime.strptime(f"{date} {time}", "%Y/%m/%d %H:%M:%S")

        if start_time is None:
            start_time = current_time
        end_time = current_time

        if prev_lat is not None and prev_lon is not None:
            distance = haversine_distance(prev_lat, prev_lon, lat, lon)
            total_distance += distance

        prev_lat, prev_lon = lat, lon

    total_time = end_time - start_time
    average_speed = total_distance / (total_time.total_seconds() / 3600)  # km/h

    return {
        "start_time": start_time,
        "end_time": end_time,
        "total_time": total_time,
        "total_distance": total_distance,
        "average_speed": average_speed
    }

# 파일 경로를 지정하세요 (^M 문자 제거됨)
file_path = "20240831_083136.csv"
result = analyze_gps_data(file_path)

print(f"운동 시작 시간: {result['start_time']}")
print(f"운동 종료 시간: {result['end_time']}")
print(f"총 운동 시간: {result['total_time']}")
print(f"총 이동 거리: {result['total_distance']:.2f} km")
print(f"평균 속도: {result['average_speed']:.2f} km/h")

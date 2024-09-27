import asyncio
import websockets
import json
import sqlite3
import base64
import os
from uuid import uuid4
import datetime

# Global variables
global BASE_URL
BASE_URL = "http://58.233.69.198:8080/moment/images/"

# Initialize SQLite database
conn = sqlite3.connect('mychat_history.db')
cursor = conn.cursor()
cursor.execute('''
    CREATE TABLE IF NOT EXISTS messages
    (id INTEGER PRIMARY KEY AUTOINCREMENT,
     sender TEXT,
     content TEXT,
     is_image BOOLEAN,
     timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)
''')
conn.commit()

# Store connected clients
connected_clients = set()

# Create a directory to store uploaded images
UPLOAD_DIR = "images"
os.makedirs(UPLOAD_DIR, exist_ok=True)

async def save_message(sender, content, is_image):
    cursor.execute('INSERT INTO messages (sender, content, is_image) VALUES (?, ?, ?)',
                   (sender, content, is_image))
    conn.commit()

async def get_chat_history():
    cursor.execute('SELECT sender, content, is_image, timestamp FROM messages ORDER BY timestamp ASC LIMIT 50')
    return cursor.fetchall()

async def handle_client(websocket, path):
    global BASE_URL
    connected_clients.add(websocket)
    try:
        history = await get_chat_history()
        for sender, content, is_image, timestamp in history:
            if is_image:
                content = f"{BASE_URL}{content}"
            await websocket.send(json.dumps({
                "sender": sender,
                "content": content,
                "is_image": is_image,
                "timestamp": str(timestamp)
            }))
        
        async for message in websocket:
            try:
                data = json.loads(message)
                if data.get('type') == 'image':
                    # Handle image upload
                    image_data = base64.b64decode(data['content'])
                    filename = f"{uuid4()}.jpg"
                    filepath = os.path.join(UPLOAD_DIR, filename)
                    with open(filepath, 'wb') as f:
                        f.write(image_data)
                    content = filename
                    is_image = True
                elif data.get('type') == 'set_base_url':
                    # Handle setting new base URL
                    BASE_URL = data['content']
                    await websocket.send(json.dumps({"type": "base_url_updated", "content": BASE_URL}))
                    continue
                else:
                    content = data['content']
                    is_image = False
                
                await save_message(data['sender'], content, is_image)
                if is_image:
                    content = f"{BASE_URL}{content}"
                await broadcast(json.dumps({
                    "sender": data['sender'],
                    "content": content,
                    "is_image": is_image,
                    "timestamp": str(datetime.datetime.now())
                }))
            except Exception as e:
                print(f"Error processing message: {e}")
    finally:
        connected_clients.remove(websocket)

async def broadcast(message):
    for client in connected_clients:
        await client.send(message)

start_server = websockets.serve(handle_client, "0.0.0.0", 8765)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

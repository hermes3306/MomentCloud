import sqlite3
import asyncio
import websockets
import json

# Initialize SQLite database
conn = sqlite3.connect('chat_history.db')
cursor = conn.cursor()
cursor.execute('''
    CREATE TABLE IF NOT EXISTS messages
    (id INTEGER PRIMARY KEY AUTOINCREMENT,
     sender TEXT,
     content TEXT,
     timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)
''')
conn.commit()

# Store connected clients
connected_clients = set()

async def save_message(sender, content):
    cursor.execute('INSERT INTO messages (sender, content) VALUES (?, ?)', (sender, content))
    conn.commit()

async def get_chat_history():
    cursor.execute('SELECT sender, content FROM messages ORDER BY timestamp ASC LIMIT 50')
    return cursor.fetchall()

async def handle_client(websocket, path):
    # Register client
    connected_clients.add(websocket)
    try:
        # Send chat history to the newly connected client
        history = await get_chat_history()
        for sender, content in history:
            await websocket.send(json.dumps({"sender": sender, "content": content}))

        async for message in websocket:
            data = json.loads(message)
            # Save message to database
            await save_message(data['sender'], data['content'])
            # Broadcast the message to all connected clients
            await broadcast(json.dumps(data))
    finally:
        # Unregister client
        connected_clients.remove(websocket)

async def broadcast(message):
    for client in connected_clients:
        await client.send(message)

start_server = websockets.serve(handle_client, "0.0.0.0", 8765)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

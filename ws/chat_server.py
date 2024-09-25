import asyncio
import websockets
import json

# Store connected clients
connected_clients = set()

async def handle_client(websocket, path):
    # Register client
    connected_clients.add(websocket)
    try:
        async for message in websocket:
            data = json.loads(message)
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

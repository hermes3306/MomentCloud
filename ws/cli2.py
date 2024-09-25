import asyncio
import websockets
import json
import aioconsole

class ChatClient:
    def __init__(self, server_uri):
        self.server_uri = server_uri
        self.username = None
        self.websocket = None

    async def connect(self):
        self.username = input("Enter your username: ")
        try:
            self.websocket = await websockets.connect(self.server_uri)
            print("Connected to the server.")
            await asyncio.gather(self.receive_messages(), self.send_messages())
        except Exception as e:
            print(f"Failed to connect: {e}")

    async def receive_messages(self):
        try:
            while True:
                message = await self.websocket.recv()
                data = json.loads(message)
                print(f"\n{data['sender']}: {data['content']}")
        except websockets.exceptions.ConnectionClosed:
            print("Connection to server closed.")

    async def send_messages(self):
        try:
            while True:
                message = await aioconsole.ainput()
                if message.lower() == 'quit':
                    break
                data = {
                    "sender": self.username,
                    "content": message
                }
                await self.websocket.send(json.dumps(data))
        except asyncio.CancelledError:
            pass

    async def run(self):
        await self.connect()

if __name__ == "__main__":
    client = ChatClient("ws://localhost:8765")
    asyncio.get_event_loop().run_until_complete(client.run())

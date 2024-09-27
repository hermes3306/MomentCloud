import asyncio
import websockets
import json
import base64
import os

class ChatClient:
    def __init__(self):
        self.websocket = None
        self.username = "DefaultUser"
        self.base_url = "http://58.233.69.198/images/"

    async def connect(self):
        try:
            self.websocket = await websockets.connect('ws://localhost:8765')
            print("Connected to server")
            await self.receive_messages()
        except Exception as e:
            print(f"Connection Error: {str(e)}")

    async def receive_messages(self):
        try:
            while True:
                message = await self.websocket.recv()
                data = json.loads(message)
                if data.get('type') == 'base_url_updated':
                    self.base_url = data['content']
                    print(f"Base URL updated to: {data['content']}")
                else:
                    sender = data.get('sender', 'Unknown')
                    content = data.get('content', '')
                    is_image = data.get('is_image', False)
                    if is_image:
                        print(f"{sender}: [Image] {content}")
                    else:
                        print(f"{sender}: {content}")
        except websockets.exceptions.ConnectionClosed:
            print("Disconnected from server")

    async def send_message(self, content):
        if self.websocket:
            message = {
                'sender': self.username,
                'content': content,
                'type': 'text'
            }
            await self.websocket.send(json.dumps(message))
        else:
            print("Error: Not connected to server")

    async def send_image(self, file_path):
        if self.websocket:
            if os.path.exists(file_path):
                with open(file_path, "rb") as image_file:
                    encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
                    message = {
                        'sender': self.username,
                        'content': encoded_string,
                        'type': 'image'
                    }
                    await self.websocket.send(json.dumps(message))
            else:
                print(f"Error: File {file_path} not found")
        else:
            print("Error: Not connected to server")

    async def set_base_url(self, new_base_url):
        if self.websocket:
            message = {
                'type': 'set_base_url',
                'content': new_base_url
            }
            await self.websocket.send(json.dumps(message))
        else:
            print("Error: Not connected to server")

async def user_input(prompt: str = "") -> str:
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, input, prompt)

async def main():
    client = ChatClient()
    await client.connect()

    while True:
        command = await user_input("Enter command (message/image/url/exit): ")
        command = command.strip().lower()
        
        if command == 'exit':
            break
        elif command == 'message':
            content = await user_input("Enter message: ")
            await client.send_message(content)
        elif command == 'image':
            file_path = await user_input("Enter image file path: ")
            await client.send_image(file_path)
        elif command == 'url':
            new_url = await user_input("Enter new base URL: ")
            await client.set_base_url(new_url)
        else:
            print("Invalid command")

if __name__ == "__main__":
    asyncio.run(main())


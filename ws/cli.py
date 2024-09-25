import asyncio
import websockets
import json
import tkinter as tk
from tkinter import scrolledtext

class ChatClient:
    def __init__(self, server_uri):
        self.server_uri = server_uri
        self.username = None
        self.websocket = None
        self.root = tk.Tk()
        self.root.title("Chat Client")
        self.setup_gui()

    def setup_gui(self):
        self.chat_display = scrolledtext.ScrolledText(self.root, state='disabled')
        self.chat_display.pack(padx=10, pady=10, expand=True, fill='both')

        self.input_frame = tk.Frame(self.root)
        self.input_frame.pack(padx=10, pady=(0, 10), fill='x')

        self.message_input = tk.Entry(self.input_frame)
        self.message_input.pack(side='left', expand=True, fill='x')
        self.message_input.bind("<Return>", self.send_message)

        self.send_button = tk.Button(self.input_frame, text="Send", command=self.send_message)
        self.send_button.pack(side='right')

    async def connect(self):
        self.username = input("Enter your username: ")
        try:
            self.websocket = await websockets.connect(self.server_uri)
            print("Connected to the server.")
            await self.receive_messages()
        except Exception as e:
            print(f"Failed to connect: {e}")

    async def receive_messages(self):
        try:
            while True:
                message = await self.websocket.recv()
                data = json.loads(message)
                self.display_message(data['sender'], data['content'])
        except websockets.exceptions.ConnectionClosed:
            print("Connection to server closed.")

    def display_message(self, sender, content):
        self.chat_display.config(state='normal')
        self.chat_display.insert(tk.END, f"{sender}: {content}\n")
        self.chat_display.config(state='disabled')
        self.chat_display.see(tk.END)

    def send_message(self, event=None):
        message = self.message_input.get()
        if message:
            asyncio.create_task(self.send_to_server(message))
            self.message_input.delete(0, tk.END)

    async def send_to_server(self, message):
        data = {
            "sender": self.username,
            "content": message
        }
        await self.websocket.send(json.dumps(data))

    def run(self):
        asyncio.get_event_loop().run_until_complete(self.connect())
        self.root.mainloop()

if __name__ == "__main__":
    client = ChatClient("ws://localhost:8765")
    client.run()

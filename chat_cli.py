import asyncio
import websockets
import json
import tkinter as tk
from tkinter import filedialog, messagebox
import base64

class ChatClient:
    def __init__(self, master):
        self.master = master
        master.title("WebSocket Chat Client")

        self.websocket = None
        self.username = tk.StringVar()
        self.message = tk.StringVar()
        self.base_url = tk.StringVar(value="http://58.233.69.198/images/")

        # Username entry
        tk.Label(master, text="Username:").grid(row=0, column=0, sticky="e")
        tk.Entry(master, textvariable=self.username).grid(row=0, column=1)

        # Chat display
        self.chat_display = tk.Text(master, height=20, width=50)
        self.chat_display.grid(row=1, column=0, columnspan=2)

        # Message entry
        tk.Label(master, text="Message:").grid(row=2, column=0, sticky="e")
        tk.Entry(master, textvariable=self.message, width=40).grid(row=2, column=1)

        # Send button
        tk.Button(master, text="Send", command=self.send_message).grid(row=3, column=0, columnspan=2)

        # Send image button
        tk.Button(master, text="Send Image", command=self.send_image).grid(row=4, column=0, columnspan=2)

        # Set base URL
        tk.Label(master, text="Base URL:").grid(row=5, column=0, sticky="e")
        tk.Entry(master, textvariable=self.base_url, width=40).grid(row=5, column=1)
        tk.Button(master, text="Set Base URL", command=self.set_base_url).grid(row=6, column=0, columnspan=2)

        # Connect button
        tk.Button(master, text="Connect", command=self.connect).grid(row=7, column=0, columnspan=2)

    def connect(self):
        asyncio.create_task(self.websocket_connect())

    async def websocket_connect(self):
        try:
            self.websocket = await websockets.connect('ws://localhost:8765')
            self.chat_display.insert(tk.END, "Connected to server\n")
            asyncio.create_task(self.receive_messages())
        except Exception as e:
            messagebox.showerror("Connection Error", str(e))

    async def receive_messages(self):
        try:
            while True:
                message = await self.websocket.recv()
                data = json.loads(message)
                if data.get('type') == 'base_url_updated':
                    self.base_url.set(data['content'])
                    self.chat_display.insert(tk.END, f"Base URL updated to: {data['content']}\n")
                else:
                    sender = data.get('sender', 'Unknown')
                    content = data.get('content', '')
                    is_image = data.get('is_image', False)
                    if is_image:
                        self.chat_display.insert(tk.END, f"{sender}: [Image] {content}\n")
                    else:
                        self.chat_display.insert(tk.END, f"{sender}: {content}\n")
                self.chat_display.see(tk.END)
        except websockets.exceptions.ConnectionClosed:
            self.chat_display.insert(tk.END, "Disconnected from server\n")

    def send_message(self):
        if self.websocket:
            message = {
                'sender': self.username.get(),
                'content': self.message.get(),
                'type': 'text'
            }
            asyncio.create_task(self.websocket.send(json.dumps(message)))
            self.message.set("")
        else:
            messagebox.showerror("Error", "Not connected to server")

    def send_image(self):
        if self.websocket:
            file_path = filedialog.askopenfilename(filetypes=[("Image files", "*.png *.jpg *.jpeg *.gif")])
            if file_path:
                with open(file_path, "rb") as image_file:
                    encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
                    message = {
                        'sender': self.username.get(),
                        'content': encoded_string,
                        'type': 'image'
                    }
                    asyncio.create_task(self.websocket.send(json.dumps(message)))
        else:
            messagebox.showerror("Error", "Not connected to server")

    def set_base_url(self):
        if self.websocket:
            message = {
                'type': 'set_base_url',
                'content': self.base_url.get()
            }
            asyncio.create_task(self.websocket.send(json.dumps(message)))
        else:
            messagebox.showerror("Error", "Not connected to server")

async def main():
    root = tk.Tk()
    client = ChatClient(root)
    while True:
        root.update()
        await asyncio.sleep(0.1)

if __name__ == "__main__":
    asyncio.run(main())

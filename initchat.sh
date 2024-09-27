#!/bin/bash

# Kill all Python processes
pkill -f python

\rm *.db

# Wait a moment to ensure all processes are terminated
sleep 2

# Start the new Python script
nohup python3 chat_server.py > chat_server.log 2>&1 &

echo "Chat server restarted"

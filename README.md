# Bind Shells

A minimalist, single-threaded TCP bind shell servers written in python and php.
Listens on a specified port, accepts incoming connections, and executes 
received strings as system shell commands. Combines stdout and stderr, 
returning the complete output to the connected client. Includes a timeout 
mechanism to prevent the server from hanging on interactive commands.
You can adjust the `PORT` and `TIMEOUT` constants to change the listening port
and command timeout duration.
    
Usage:
```bash
# Start the python server
python bind_shell.py

# Start the php server
php bind_shell.py

# Connect to the server
nc ip_address listening_port
```

Disclaimer: 
This code is for educational purposes only. Use it at your own risk. 

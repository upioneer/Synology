<#
    Replace the IP and MAC addresses with that of your device
    Script will check and report when the device is online
#>

$macAddress = "00:11:22:AA:BB:CC"
$ipAddress = "192.168.1.1"

if ($macAddress -like "*:*") {
    Write-Host 'Formatting MAC address...' -ForegroundColor Magenta
    $macAddress = $macAddress -replace "-", ":"
}

# Convert MAC address to bytes
$macBytes = $macAddress -split ':' | ForEach-Object { [byte]('0x' + $_) }

# Create magic packet
$magicPacket = (,0xFF * 6) + ($macBytes * 16)

# Create UDP client
$udpClient = New-Object System.Net.Sockets.UdpClient

Write-Host "Sending magic packet to:"
Write-Host $ipAddress -ForegroundColor Green
Write-Host $macAddress -ForegroundColor Green

# Set the broadcast address and port
$udpClient.Connect(([System.Net.IPAddress]::Broadcast), 7)

# Send magic packet
$udpClient.Send($magicPacket, $magicPacket.Length)

# Close UDP client
$udpClient.Close()

# Confirm avialability and report boot time
$bootTime = Measure-Command {
    Write-Host "Confirming device ping response. Please wait..." -ForegroundColor Yellow
    do {
      Start-Sleep -Seconds 5
    } until(Test-NetConnection $ipAddress | ? {$_.PingSucceeded })
    $secs = $bootTime.Seconds
    Write-Host
    Write-Host "WOL to availability took $secs seconds" -ForegroundColor Magenta
}
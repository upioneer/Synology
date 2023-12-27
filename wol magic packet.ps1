<#
    Replace the IP and MAC addresses with that of your device
    Script will check and report when the device is online
    Timeout is set to 5 minutes but please adjust according to your needs

    TO DO
        - add visual cue while waiting for ping response
#>

####   SET VARIABLES BELOW   ####
#################################
$macAddress = "00:11:22:AA:BB:CC"
$ipAddress = "192.168.1.1"
$timeout = New-TimeSpan -Minutes 5
#################################

$OGmacAddress = $macAddress

if ($macAddress -like "*-*") {
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
Write-Host $OGmacAddress -ForegroundColor Green

# Set the broadcast address and port
$udpClient.Connect(([System.Net.IPAddress]::Broadcast), 7)

# Send magic packet
$udpClient.Send($magicPacket, $magicPacket.Length)

# Close UDP client
$udpClient.Close()

# Confirm availability and report boot time
$startTime = Get-Date
$bootTime = Measure-Command {
    Write-Host "Confirming device ping response. Please wait..."
    do {
        Start-Sleep -Seconds 5
        $elapsedTime = (Get-Date) - $startTime
    } until ((Test-NetConnection $ipAddress | ? {$_.PingSucceeded}) -or ($elapsedTime -ge $timeout))

    $mins = $bootTime.Minutes
    $secs = $bootTime.Seconds

    if ($elapsedTime -ge $timeout) {
        Write-Host "Timeout reached. Device is not responding." -ForegroundColor Red
    } else {
        Write-Host
        Write-Host "WOL to availability took $mins mins $secs seconds" -ForegroundColor Green
    }
}

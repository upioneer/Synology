$targetIPAddress = "192.168.1.1"
$targetMACAddress = "00-11-22-33-44-55"

# convert the MAC address to bytes
$macBytes = $targetMACAddress -split '-' | ForEach-Object { [byte]('0x' + $_) }

# create a magic packet by concatenating 6 bytes of 0xFF followed by 16 repetitions of the target MAC address
$magicPacket = (,[byte]0xFF * 6) + ($macBytes * 16)

# create a UDP client and send the magic packet to the target device
$udpClient = New-Object System.Net.Sockets.UdpClient
$udpClient.Connect($targetIPAddress, 9) # 9 is the standard WoL port

# send the magic packet
$udpClient.Send($magicPacket, $magicPacket.Length)
$udpClient.Close()

Write-Host "Magic packet sent to:"
Write-Host $targetIPAddress -ForegroundColor Green
Write-Host $targetMACAddress -ForegroundColor Green
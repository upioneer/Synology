<#
    Replace the IP and MAC addresses with that of your device
    Script will check and report when the device is online
    Timeout is set to 5 minutes but please adjust according to your needs
#>

####   SET VARIABLES BELOW   ####
#################################
$macAddress = "00:11:22:AA:BB:CC"
$ipAddress = "192.168.1.1"

$timeout = New-TimeSpan -Minutes 10
$sleep = 10
#################################

$OGmacAddress = $macAddress

if ($macAddress -like "*-*") {
    $macAddress = $macAddress -replace "-", ":"
}

$macBytes = $macAddress -split ':' | ForEach-Object { [byte]('0x' + $_) }

$magicPacket = (,0xFF * 6) + ($macBytes * 16)

$ports = @(
'7',
'9'
)

foreach ($port in $ports) {
    $udpClient = New-Object System.Net.Sockets.UdpClient

    Write-Host
    Write-Host "Sending magic packet to:" -ForegroundColor Gray
    Write-Host "IP:  $ipAddress`:$port"
    Write-Host "MAC: $OGmacAddress"

    $udpClient.Connect(([System.Net.IPAddress]::Broadcast), $port)
    $udpClient.Send($magicPacket, $magicPacket.Length) | Out-Null
    $udpClient.Close()
}

$startTime = Get-Date
$bootTime = Measure-Command {
    write-host
    Write-Host "Confirming device ping response. Please wait..."
    do {
        Start-Sleep -Seconds $sleep
        $elapsedTime = (Get-Date) - $startTime
        Write-Progress -Activity "Waiting for ping response" -PercentComplete ($elapsedTime.TotalSeconds / $timeout.TotalSeconds * 100)
    } until ((Test-NetConnection $ipAddress | ? {$_.PingSucceeded}) -or ($elapsedTime -ge $timeout))

    $mins = $bootTime.Minutes
    $secs = $bootTime.Seconds

    if ($elapsedTime -ge $timeout) {
        Write-Host "Timeout reached. Device is not responding." -ForegroundColor Red
    } else {
        Write-Host
        Write-Host "WOL to availability took $mins mins $secs seconds" -ForegroundColor Green

        Add-Type -AssemblyName System.Windows.Forms

        $iconPath = "C:\Users\hgran\OneDrive\Documents\code\powershell\WOL Synology\favicon.ico"

        $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
        $notifyIcon.Icon = New-Object System.Drawing.Icon($iconPath)
        $notifyIcon.Text = "MetaSkullz"
        $notifyIcon.Visible = $true
        $notifyIcon.ShowBalloonTip(5000, "Synology Wake on LAN", "NAS took $mins mins $secs seconds", [System.Windows.Forms.ToolTipIcon]::Info)

        Start-Sleep -Seconds 5
        $notifyIcon.Dispose()
    }
}
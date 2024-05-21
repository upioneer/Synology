
# Synology Wake On LAN (WOL)

This PowerShell script is designed to send a Wake-on-LAN (WOL) magic packet to a Synology NAS device and check when the device comes online. The script sends the WOL packet to the device's IP and MAC address then waits for a ping response to confirm the device's availability

## Features
- **Configurable IP and MAC Address**: Easily replace the placeholder IP and MAC addresses with those of your device
- **Adjustable Timeout**: Set a custom timeout duration to wait for the device to respond
- **Progress Monitoring**: Displays progress while waiting for the device to respond
- **Notification**: Provides a Windows notification once the device is confirmed online

## Configuration
1. **Set Variables**: Replace the placeholder values for `$macAddress` and `$ipAddress` with the actual MAC and IP addresses of your device
2. **Adjust Timeout**: Modify the `$timeout` variable to set the duration the script waits for the device to come online (default is 10 minutes)
3. **Set Sleep Interval**: Adjust the `$sleep` variable to change the interval between ping attempts (default is 10 seconds)

Please consider this script was developed and tested against the Synology DS418 only.

## 

![DS923+](https://www.synology.com/img/products/detail/DS923plus/heading.png)

## Authors

[@upioneer](https://www.github.com/upioneer)

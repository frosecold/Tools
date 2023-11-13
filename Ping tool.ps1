# Set the location of the sound file you want to play (.wav)
$sound = "C:\Windows\Media\Windows Critical Stop.wav"

function Test-ValidIP {
    param($ip)
    $ipRegex = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    return $ip -match $ipRegex
}

function Test-ValidHostname {
    param($hostname)
    $hostnameRegex = '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'
    return $hostname -match $hostnameRegex -and $null -ne (Resolve-DnsName $hostname -ErrorAction SilentlyContinue)
}


do {
    $input = Read-Host "Please enter an IP or Hostname"
    $toPing = $null

    if (Test-ValidIP $input) {
        try {
            $hostname = [System.Net.Dns]::GetHostEntry($input).HostName
            Write-Host "The hostname for IP $input is: $hostname"
            $toPing = $input
        } catch {
            Write-Host "The IP address is valid but no hostname could be resolved. Please try again."
        }
    } elseif (Test-ValidHostname $input) {
        try {
            $ip = [System.Net.Dns]::GetHostAddresses($input)[0].IPAddressToString
            Write-Host "The IP for hostname $input is: $ip"
            $toPing = $ip
        } catch {
            Write-Host "The hostname is valid but no IP could be resolved. Please try again."
        }
    } else {
        Write-Host "The input is not a valid IP or Hostname. Please try again."
    }
} while ($null -eq $toPing)

do {
    try {
        $pingResult = Test-Connection $toPing -Count 1 -Quiet
        if ($pingResult) {
            Write-Host "Ping successful at $(Get-Date)"
        } else {
            Write-Host "Ping failed at $(Get-Date)"
            (New-Object Media.SoundPlayer $sound).PlaySync()
        }
    } catch {
        Write-Host "An error occurred while pinging $toPing at $(Get-Date)"
        (New-Object Media.SoundPlayer $sound).PlaySync()
    }
    Start-Sleep -Seconds 30
} while ($true)

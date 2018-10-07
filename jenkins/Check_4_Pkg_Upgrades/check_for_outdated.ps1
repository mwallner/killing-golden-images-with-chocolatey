$mrecipient = $env:P_MAIL_REC
$msender = $env:P_MAIL_SEND
$msmtp = $env:P_SMTP_SERVER
$availPkgs = @()

$chocoout = $(choco outdated --ignore-pinned --ignore-unfound -r)
$chocoout | ForEach-Object {
  $up = $_.Split("|")
  if ($up -And ($up[3] -eq "false")) {
    if ($up[1] -ne $up[2]) {
      $availPkgs += "$($up[0]): $($up[1]) => $($up[2])"
    }
		} 
}

$res = $availPkgs | Format-Table | Out-String
if ($res) {
  Write-Output "Chocolatey Packages Outdated!"
  Write-Output $res
  Write-Output "sending mail..."
  Send-MailMessage -To $mrecipient -Subject "Chocolatey Packages Outdated!" -Body $res -Verbose -ErrorAction "Stop" -From $msender -SmtpServer $msmtp
}

Import-Module BurntToast

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$pkgs = choco outdated --ignore-pinned --ignore-unfound -r
$total = $pkgs.Count

if ($total.Count -eq 0) {
  New-BurntToastNotification "all Chocolatey packages are up-to-date!"
}
else {
  $pkgText = ""
  $pkgs | % { $pkgText += "$($_ -split "\|" | Select-Object -First 1), " } 
  if ($pkgText.Length -gt 103) {
    $pkgText = $pkgText.Substring(0, 100)
    $pkgText += "..."
  }
  New-BurntToastNotification -Text "there are $total package updates available", $pkgText -AppLogo $(Join-Path $scriptPath choco_logo_square.png)
}


<#
$t = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "C:\git\killing-golden-images-with-chocolatey\update_notify.ps1"
$Trigger = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(10); $Trigger.EndBoundary = (get-date).AddSeconds(120).ToString('s')
$S = New-ScheduledTaskSettingsSet -StartWhenAvailable -DeleteExpiredTaskAfter 00:00:30
Register-ScheduledTask -Force -user $.. current user .. -TaskName "choco upgrade" -Action $t -Trigger $Trigger -Settings $S
#>
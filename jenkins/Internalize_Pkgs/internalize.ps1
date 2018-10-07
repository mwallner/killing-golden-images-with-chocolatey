# PowerShell script to internalize chocolatey packages from the community feed to an internal server using the business edition 'internalize' feature. This script is designed to be run from jenkins, P_* variables are defined in jenkins job!

$pkgs = $env:P_PKGLIST
$uncshare = $env:P_UNC_SHARE
$targetfolder = $env:P_DST_FOLDER
$targetserver = $env:P_DST_SRV
$apikey = $env:P_API_KEY

$envtmp = $env:temp
$tmpdir = "$envtmp\chocointernalize"
$basefeed = "https://chocolatey.org/api/v2/"

function InternalizePkg($pkg) {
  if ((Test-Path $tmpdir)) {
    Remove-Item $tmpdir -Recurse -Force -Verbose
  }
  New-Item $tmpdir -ItemType Directory -Force -Verbose

  Push-Location $tmpdir
  choco download --internalize $pkg --resources-location="$uncshare\$pkg" --source="$basefeed" --no-progress
  $genpkg = ((Get-ChildItem *.nupkg -recurse).FullName)
  if ($targetfolder) {
    Write-Output "> copying package '$genpkg' to '$targetfolder'"
    if (-Not (Test-Path $targetfolder)) {
      New-Item $targetfolder -ItemType Directory -Force -Verbose
    }
    Copy-Item $genpkg $targetfolder -Verbose -ErrorAction "Stop"
  }
  else {
    Write-Output "> pushing package '$genpkg' to '$targetserver'"
    choco push $genpkg --source="$targetserver" --api-key="$apikey" -Verbose
  }
  Write-Output "------------------------------------------------------------------------"
  Write-Output ""
  Pop-Location
}

$pkgs | ForEach-Object {
  InternalizePkg $_
}

Remove-Item $tmpdir -Recurse -Force -Verbose
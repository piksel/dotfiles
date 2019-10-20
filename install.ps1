$DotPath = "C:\dot"
$DotRepo = "github.com/piksel/dotfiles"

if( ! Test-Path $DotPath ){
Write-Host -n -f cy "Cloning "; Write-Host -n -f w $DotRepo; Write-Host -n -f cy " to "; Write-Host -n -f w $DotPath; Write-Host -f cy "..."
  git clone $DotRepo $DotPath
}
Write-Host -n -f cy "Using DotPath: "; Write-Host -f w $DotPath
cd $DotPath
$ProfilePath = Split-Path $Profile
Write-Host -n -f cy "Using ProfilePath: "; Write-Host -f w $ProfilePath
if (Test-Path $ProfilePath) {
  Write-Host -f Cyan "Profile path exists, linking scripts..."
  New-Item -ItemType SymbolicLink -Path $ProfilePath -Name Microsoft.PowerShell_profile.ps1 -Value $DotPath\ps\Microsoft.PowerShell_profile.ps1 -Verbose
  New-Item -ItemType SymbolicLink -Path $ProfilePath -Name NuGet_profile.ps1 -Value $DotPath\ps\NuGet_profile.ps1 -Verbose
} else {
  Write-Host -f Cyan "Linking profile path..."
  $ProfilePathName = Split-Path $ProfilePath -Leaf
  $ProfilePathDir = Split-Path $ProfilePath
  New-Item -ItemType SymbolicLink -Path $ProfilePathDir -Name $ProfilePathName -Value $DotPath\ps -Verbose
}

Write-Host -n -f cy "Installing "; Write-Host -n -f w "posh-git"; Write-Host -f cy "..."
PowerShellGet\Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force

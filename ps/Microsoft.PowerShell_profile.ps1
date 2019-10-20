function Test-CmdParam ($cmd, $param) {
  ((Get-Command $cmd).ParameterSets | Select -ExpandProperty Parameters | Where Name -eq $param).Count -gt 0
}


# Basic console colors --------------------------------------------------------

[console]::backgroundcolor = "Black"
[console]::foregroundcolor = "Gray"

# Syntax highlighting colors --------------------------------------------------

if(Test-CmdParam Set-PSReadlineOption "TokenKind") {
	Set-PSReadlineOption -TokenKind command -ForegroundColor Cyan
	Set-PSReadlineOption -TokenKind comment -ForegroundColor Blue
	Set-PSReadlineOption -TokenKind parameter -ForegroundColor Green
	Set-PSReadlineOption -TokenKind string -ForegroundColor Yellow
} elseif (Test-CmdParam Set-PSReadlineOption "Colors") {
	Set-PSReadLineOption -Colors @{
		Command            = 'Cyan'
		Comment            = 'DarkBlue'
		String             = 'Yellow'
		Number             = 'Magenta'
		Member             = 'DarkCyan'
		Operator           = 'Red'
		Type               = 'Green'
		Variable           = 'DarkYellow'
		Parameter          = 'DarkCyan'
		ContinuationPrompt = 'Gray'
		Default            = 'Gray'
	  }
}

# Logging / Progress colors ---------------------------------------------------

$p = $host.privatedata
$p.ErrorForegroundColor    = "Red"
$p.ErrorBackgroundColor    = "Black"
$p.WarningForegroundColor  = "Yellow"
$p.WarningBackgroundColor  = "Black"
$p.DebugForegroundColor    = "Yellow"
$p.DebugBackgroundColor    = "Black"
$p.VerboseForegroundColor  = "Yellow"
$p.VerboseBackgroundColor  = "Black"
$p.ProgressForegroundColor = "White"
$p.ProgressBackgroundColor = "DarkGray"

# Posh git --------------------------------------------------------------------

Import-Module posh-git

$global:GitPromptSettings.BeforeText = '['
$global:GitPromptSettings.AfterText  = '] '
$global:GitPromptSettings.EnableWindowTitle = ">"

# Prompt ----------------------------------------------------------------------

function prompt
{
    Write-VcsStatus
    Write-Host $ExecutionContext.SessionState.Path.CurrentLocation
    Write-Host (">") -nonewline -ForegroundColor White
    return " "
}

# Clear screen to update colors -----------------------------------------------

clear-host

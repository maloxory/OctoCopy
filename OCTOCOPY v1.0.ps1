<#
    Title: OCTOCOPY Enhanced Permission-Preserving Copier v1.0
    Copyright© 2024 Magdy Aloxory. All rights reserved.
    Contact: maloxory@gmail.com
#>

# Check if the script is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch the script with administrator privileges
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Function to center text
function CenterText {
    param (
        [string]$text,
        [int]$width
    )
    
    $textLength = $text.Length
    $padding = ($width - $textLength) / 2
    return (" " * [math]::Max([math]::Ceiling($padding), 0)) + $text + (" " * [math]::Max([math]::Floor($padding), 0))
}

# Function to create a border
function CreateBorder {
    param (
        [string[]]$lines,
        [int]$width
    )

    $borderLine = "+" + ("-" * $width) + "+"
    $borderedText = @($borderLine)
    foreach ($line in $lines) {
        $borderedText += "|$(CenterText $line $width)|"
    }
    $borderedText += $borderLine
    return $borderedText -join "`n"
}

# Display script information with border
$title = "OCTOCOPY Enhanced Permission-Preserving Copier v1.0"
$copyright = "Copyright 2024 Magdy Aloxory. All rights reserved."
$contact = "Contact: maloxory@gmail.com"
$maxWidth = 60

$infoText = @($title, $copyright, $contact)
$borderedInfo = CreateBorder -lines $infoText -width $maxWidth

Write-Host $borderedInfo -ForegroundColor Cyan

# Prompt the user for credentials
$Source = Read-Host "Enter the source path (e.g., \\server\share)"
$Destination = Read-Host "Enter the destination path (e.g., Z:\Destination Folder)"
$LogFile = "$Destination\OctoCopy_Log.log"

# Prompt for username and password
$Username = Read-Host "Enter the username for the source" 
$Password = Read-Host "Enter the password for the source" -AsSecureString

# Create a credential object
$Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

# Use the credential to map the network drive temporarily
New-PSDrive -Name Z -PSProvider FileSystem -Root $Source -Credential $Credential -ErrorAction Stop

# Build the Robocopy command
$RobocopyCmd = "Robocopy `"$Source`" `"$Destination`" /MIR /COPY:DATS /R:1 /W:1 /NP /LOG:`"$LogFile`""

# Run the Robocopy command
Write-Host "Starting Robocopy..."
Start-Process -FilePath "cmd.exe" -ArgumentList "/c $RobocopyCmd" -NoNewWindow -Wait

# Remove the temporary drive after copy
Remove-PSDrive -Name Z -ErrorAction SilentlyContinue

Write-Host "OctoCopy completed."
Pause

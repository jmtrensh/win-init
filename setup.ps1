# Define the startup directory and the default Windows startup folder
$sourceStartupDir = "C:\Path\To\Your\Startup\Directory"  # Replace with your startup directory path
$windowsStartupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$work = $false  # Set to $true if installing work-only programs

# Function to check if winget is installed
function Check-Winget {
    Write-Host "Checking if winget is installed..."
    try {
        $wingetVersion = winget --version
        if ($wingetVersion) {
            Write-Host "Winget is installed. Version: $wingetVersion"
            return $true
        }
    } catch {
        Write-Host "Winget is not installed."
        return $false
    }
}

# Function to install winget from GitHub
function Install-Winget {
    Write-Host "Installing winget from GitHub..."
    $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $tempFile = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"

    try {
        Write-Host "Downloading winget installer..."
        Invoke-WebRequest -Uri $wingetUrl -OutFile $tempFile
        Write-Host "Installing winget..."
        Add-AppxPackage -Path $tempFile
        Write-Host "Winget installed successfully."
    } catch {
        Write-Host "Failed to install winget. Error: $_"
        exit 1
    }
}

# Check if winget is installed, and install it if necessary
if (-not (Check-Winget)) {
    Install-Winget
}

# Copy files from the custom startup directory to the Windows startup folder
Write-Host "Copying files from $sourceStartupDir to $windowsStartupFolder..."
if (Test-Path $sourceStartupDir) {
    Copy-Item -Path "$sourceStartupDir\*" -Destination $windowsStartupFolder -Recurse -Force
    Write-Host "Files copied successfully."
} else {
    Write-Host "Source startup directory does not exist. Please check the path."
}

# Install software using winget
Write-Host "Installing software using winget..."

# List of software to install always
$softwareList = @(
    "Microsoft.PowerToys",
    "Adobe.Acrobat.Reader.64", # may delete due to 
    "voidtools.Everything.Alpha", # Alpha for dark mode
    "Git.Git",
    "AutoHotkey.AutoHotkey",
    "7zip.7zip",
    "GitHub.cli",
    "Python.Python.3",
    "TeraTerm.TeraTerm",
    "WinSCP.WinSCP",
    "PuTTY.PuTTY",
    "ShareX.ShareX",
    "GitExtensionsTeam.GitExtensions",
    "Bruno.Bruno",
    "15722UsefulApp.WorkspaceLauncherForVSCode",
    "Proton.ProtonPass"
)

# Work Only Software
$workOnlySoftware = @(
    "ScooterSoftware.BeyondCompare.5", # Needs License
    "WiresharkFoundation.Wireshark",
    "Microsoft.VisualStudioCode",
    "JRSoftware.InnoSetup",
    "NitroSoftware.NitroPDFPro"
)

# Personal Only Software
$personalOnlySoftware = @(
    "Brave.Brave",
    "Spotify.Spotify",
    "VideoLAN.VLC",
    "FreeCAD.FreeCAD",
    "Inkscape.Inkscape",
    "LibreOffice.LibreOffice",
    "VSCodium.VSCodium",
    "LibreCAD.LibreCAD"
)

# TODO: Clean this up
foreach ($software in $softwareList) {
    Write-Host "Installing $software..."
    try {
        winget install --id $software --silent --accept-package-agreements --accept-source-agreements
        Write-Host "$software installed successfully."
    } catch {
        Write-Host "Failed to install $software. Error: $_"
    }
}

if ($work) {
    Write-Host "Installing work-only software..."
    foreach ($software in $workOnlySoftware)  {
        Write-Host "Installing $software..."
        try {
            winget install --id $software --silent --accept-package-agreements --accept-source-agreements
            Write-Host "$software installed successfully."
        } catch {
            Write-Host "Failed to install $software. Error: $_"
        }
    }
}
else
{
    Write-Host "Installing personal-only software..."
    foreach ($software in $personalOnlySoftware)  {
        Write-Host "Installing $software..."
        try {
            winget install --id $software --silent --accept-package-agreements --accept-source-agreements
            Write-Host "$software installed successfully."
        } catch {
            Write-Host "Failed to install $software. Error: $_"
        }
    }
}

# TODO: Add regedit for using the old Explorer context menu instead of the new one

Write-Host "All tasks completed."

$WorkspaceFolder = ".work"
$WingetVersion = "v1.8.1791"
$UiXamlVersion = "2.8.6"

$Arch = "x86".ToLower()

$releases_uri = "https://api.github.com/repos/microsoft/winget-cli/releases/tags/" + $WingetVersion
$VCLibs_uri = if ( $Arch.Contains("arm64") ) { "https://aka.ms/Microsoft.VCLibs.arm64.14.00.Desktop.appx" } else { "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" }
$ui_xaml_uri = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/" + $UiXamlVersion

# Setting up workspace
Write-Host "[INFO] Setting up workspace..."
if( Test-Path -Path "$WorkspaceFolder" ) {
	Write-Host "Resetting Workspace..."
	Cleanup
}

$WorkspaceFolderObj = New-Item -Path "." -Name $WorkspaceFolder -ItemType Directory
Write-Host "[INFO] Created Workspace at $($WorkspaceFolderObj.FullName)"
cd $WorkspaceFolderObj

# Getting winget
Write-Host "[INFO] Downloading Winget..."
$releases = Invoke-WebRequest -Uri $releases_uri | ConvertFrom-Json

foreach( $asset in $releases.assets ) {
	# Download License file
	if ( $asset.name.Contains("License1.xml") ) {
		Invoke-WebRequest $asset.url -Out "License1.xml"
	}
	
	# Download Winget Release
	if ( $asset.name.Contains("msixbundle") ) {
		Invoke-WebRequest $asset.url -Out "Microsoft.DesktopAppInstaller.msixbundle"
	}
}

# Getting Dependencies
Write-Host "[INFO] Downloading Dependencies..."
Invoke-WebRequest $VCLibs_uri -Out "Microsoft.VCLibs.Desktop.appx"
Invoke-WebRequest $ui_xaml_uri -Out "microsoft.ui.xaml.zip"

Expand-Archive -LiteralPath "microsoft.ui.xaml.zip" -DestinationPath "microsoft.ui.xaml"
$xamlFiles = Get-ChildItem ("./microsoft.ui.xaml/tools/AppX/" + $Arch + "/Release/")
Copy-Item $xamlFiles[0] -Destination "microsoft.ui.xaml.appx"

# Install Dependencies
Write-Host "[INFO] Installing Dependencies..."
Add-AppxPackage -Path "./Microsoft.VCLibs.Desktop.appx"
Add-AppxPackage -Path "./microsoft.ui.xaml.appx"

# Install Winget
Write-Host "[INFO] Installing Winget-Cli"
Add-AppxPackage -Path "./Microsoft.DesktopAppInstaller.msixbundle"
Add-AppxProvisionedPackage -Online -PackagePath "./Microsoft.DesktopAppInstaller.msixbundle" -LicensePath "./License1.xml"

# Cleaning up workspace
Write-Host ("[INFO] Cleaning up workspace at (" + $WorkspaceFolder + ")")
cd $WorkspaceFolderObj.Parent
Remove-Item -Path $WorkspaceFolderObj -Recurse
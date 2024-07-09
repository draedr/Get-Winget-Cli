<#
.SYNOPSIS
A powershell script to install winget on windows editions without Microsoft Store.
Version defaults as per official microsoft instruction for Windows IoT version (as of 05/08/2024)

.DESCRIPTION
A powershell script to install winget on windows editions without Microsoft Store.
Version defaults as per official microsoft instruction for Windows IoT version (as of 05/08/2024)

.PARAMETER WorkspaceFolder
Specifies the name to use when creating the workspace folder. This folder will be removed at the end if Cleanup is used

.PARAMETER WingetVersion
Which version of Winget to donwload from Github. Specify the release tag.

.PARAMETER UiXamlVersion
Which version of Microsoft.Ui.Xaml to download from NuGet. Currently set to 2.8.6.

.PARAMETER Arch
Which architecture to install. Currently supported only values "x86" or "arm64".

.FUNCTIONALITY Cleanup
Cleans the workspace directory. To be used in case of an error interrupting the script and leaving the workspace

.FUNCTIONALITY Dry
Runs the script without actually installing anything.

.OUTPUTS
None. Get-Winget-Cli.ps1 doesn't generate any output.

.EXAMPLE
PS> .\Get-Winget-Cli.ps1
.EXAMPLE
PS> .\Get-Winget-Cli.ps1 -Dry
.EXAMPLE
PS> .\Get-Winget-Cli.ps1 -Cleanup
#> 
param (
	[String]$WorkspaceFolder = ".work",
	[String]$WingetVersion = "v1.8.1791",
	[String]$UiXamlVersion = "2.8.6",
	[String]$Arch = "x86",
	[switch]$Dry,
	[switch]$Cleanup,
	[switch]$Workspace
)

function PrepareWorkspace {
	# Setting up workspace
	Write-Host "[INFO] Setting up workspace..."
	if( Test-Path -Path "$WorkspaceFolder" ) {
		Write-Host "Resetting Workspace..."
		Cleanup
	}

	$WorkspaceFolderObj = New-Item -Path "." -Name "$($WorkspaceFolder)" -ItemType Directory
	Write-Host "[INFO] Created Workspace at $($WorkspaceFolderObj.FullName)"
}

function Download {
	$Arch = $Arch.ToLower()

	$releases_uri = "https://api.github.com/repos/microsoft/winget-cli/releases/tags/$($WingetVersion)"
	$VCLibs_uri = if ( $Arch.Contains("arm64") ) { "https://aka.ms/Microsoft.VCLibs.arm64.14.00.Desktop.appx" } else { "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" }
	$ui_xaml_uri = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/$($UiXamlVersion)"

	# Getting winget
	Write-Host "[INFO] Downloading Winget..."
	$releases = Invoke-WebRequest -Uri $releases_uri | ConvertFrom-Json

	foreach( $asset in $releases.assets ) {
		# Download License file
		if ( $asset.name.Contains("License1.xml") ) {
			Invoke-WebRequest $asset.url -Out ".\$($WorkspaceFolder)\License1.xml"
		}
		
		# Download Winget Release
		if ( $asset.name.Contains("msixbundle") ) {
			Invoke-WebRequest $asset.url -Out ".\$($WorkspaceFolder)\Microsoft.DesktopAppInstaller.msixbundle"
		}
	}

	# Getting Dependencies
	Write-Host "[INFO] Downloading Dependencies..."
	Invoke-WebRequest $VCLibs_uri -Out ".\$($WorkspaceFolder)\Microsoft.VCLibs.Desktop.appx"
	Invoke-WebRequest $ui_xaml_uri -Out ".\$($WorkspaceFolder)\microsoft.ui.xaml.zip"

	Expand-Archive -LiteralPath ".\$($WorkspaceFolder)\microsoft.ui.xaml.zip" -DestinationPath ".\$($WorkspaceFolder)\microsoft.ui.xaml"
	Copy-Item ".\$($WorkspaceFolder)\microsoft.ui.xaml\tools\Appx\$($Arch)\Release\*.appx" -Destination ".\$($WorkspaceFolder)\microsoft.ui.xaml.appx"
}

function Install {
		# Install Dependencies
		Write-Host "[INFO] Installing Dependencies..."
		Add-AppxPackage -Path ".\$($WorkspaceFolder)\Microsoft.VCLibs.Desktop.appx"
		Add-AppxPackage -Path ".\$($WorkspaceFolder)\microsoft.ui.xaml.appx"

		# Install Winget
		Write-Host "[INFO] Installing Winget-Cli"
		Add-AppxPackage -Path ".\$($WorkspaceFolder)\Microsoft.DesktopAppInstaller.msixbundle"
		Add-AppxProvisionedPackage -Online -PackagePath ".\$($WorkspaceFolder)\Microsoft.DesktopAppInstaller.msixbundle" -LicensePath ".\$($WorkspaceFolder)\License1.xml"
}

function Cleanup {
		Write-Host "[INFO] Cleaning up workspace at (.\$($WorkspaceFolder))"

		if( Test-Path -Path $WorkspaceFolder ) {
		Remove-Item -Path $WorkspaceFolder -Recurse
		}
}

function Post-Install {
	if (Get-Command "winget" -errorAction SilentlyContinue)
	{
		"[INFO] Congratulations! Winget has been installed. You can try it by typing 'winget'."
	}
}

function Pre-Install {
	if (Get-Command "winget" -errorAction SilentlyContinue)
	{
		Write-Host "[ERROR] Winget is already installed on this system. This script is to be used only for first installation; To update Winget you can use Winget itself."
		
		Terminate
	}
}

function Terminate {
	Read-Host -Prompt "Press Any Key to exit"
	exit;
}

function Main {
	Pre-Install

	PrepareWorkspace

	Download

	if( !$Dry ) {
		Install
	}
	
	Cleanup

	Post-Install
}

function Commands {
	if($Cleanup) {
		Cleanup
		break
	}

	if($Workspace) {
		PrepareWorkspace
		break
	}
	
	Main
}

Commands
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

.PARAMETER Cleanup
Specify if the workspace folder should be deleted after completion. Defaults to true.

.PARAMETER Dry
Specify if script should by run "Dry", by only setting up downloads and files, but without actually installing them.

#> 
param (
	[String]$WorkspaceFolder = ".work",
	[String]$WingetVersion = "v1.8.1791",
	[String]$UiXamlVersion = "2.8.6",
	[String]$Arch = "x86",
	[Boolean]$Cleanupup = $true,
	[switch]$Dry,
	[switch]$Cleanup
)

function GWC-Download {
	$Arch = $Arch.ToLower()

	$releases_uri = "https://api.github.com/repos/microsoft/winget-cli/releases/tags/$WingetVersion"
	$VCLibs_uri = if ( $Arch.Contains("arm64") ) { "https://aka.ms/Microsoft.VCLibs.arm64.14.00.Desktop.appx" } else { "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" }
	$ui_xaml_uri = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/$UiXamlVersion"

	# Setting up workspace
	Write-Host "Setting up workspace..."
	if( Test-Path -Path $WorkspaceFolder ) {
		Write-Host "Resetting Workspace..."
		GWC-Cleanup
	}
	
	$WorkspaceFolderObj = New-Item -Path "." -Name $WorkspaceFolder, -ItemType Directory

	# Getting winget
	Write-Host "Downloading Winget..."
	$releases = Invoke-WebRequest -Uri $releases_uri | ConvertFrom-Json

	foreach( $asset in $releases.assets ) {
		# Download License file
		if ( $asset.name.Contains("License1.xml") ) {
			Invoke-WebRequest $asset.url -Out ".\$WorkspaceFolder\License1.xml"
		}
		
		# Download Winget Release
		if ( $asset.name.Contains("msixbundle") ) {
			Invoke-WebRequest $asset.url -Out ".\$WorkspaceFolder\Microsoft.DesktopAppInstaller.msixbundle"
		}
	}

	# Getting Dependencies
	Write-Host "Downloading Dependencies..."
	Invoke-WebRequest $VCLibs_uri -Out "Microsoft.VCLibs.Desktop.appx"
	Invoke-WebRequest $ui_xaml_uri -Out "microsoft.ui.xaml.zip"

	Expand-Archive -LiteralPath '.\microsoft.ui.xaml.zip' -DestinationPath '.\$WorkspaceFolder\microsoft.ui.xaml'
	cp "microsoft.ui.xaml\tools\Appx\$Arch\Release\*.appx' '.\$WorkspaceFolder\microsoft.ui.xaml.appx"
}

function GWC-Install {
		# Install Dependencies
		Write-Host "Installing Dependencies..."
		Add-AppxPackage -Path ".\$WorkspaceFolder\Microsoft.VCLibs.Desktop.appx"
		Add-AppxPackage -Path ".\$WorkspaceFolder\microsoft.ui.xaml.zip"

		# Install Winget
		Write-Host "Installing Winget-Cli"
		Add-AppxPackage -Path ".\$WorkspaceFolder\Microsoft.DesktopAppInstaller.msixbundle"
		Add-AppxProvisionedPackage -Online -PackagePath ".\$WorkspaceFolder\Microsoft.DesktopAppInstaller.msixbundle" -LicensePath ".\License1.xml"
}

function GWC-Cleanup {
		Write-Host "Cleaning up workspace at (.\$WorkspaceFolder)"

		if( Test-Path -Path $WorkspaceFolder ) {
		Remove-Item -Path $WorkspaceFolder -Recurse
		}
}

function GWC-Main {
	GWC-Download

	if( !$Dry ) {
		GWC-Install
	}

	GWC-Cleanup
}

function Commands {
	if($Cleanupup) {
		GWC-Cleanup
		break
	}
	
	GWC-Main
}

Commands
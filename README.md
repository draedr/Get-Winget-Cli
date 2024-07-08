# Get-Winget-Cli
A powershell script to install winget on windows editions without Microsoft Store

# Minimum Requirements
Tested with Powershell v5.1.22621.3672 on Windows 11 Enterprise.

# Parameters
## .SYNOPSIS
A powershell script to install winget on windows editions without Microsoft Store.
Version defaults as per official microsoft instruction for Windows IoT version (as of 05/08/2024)

## .DESCRIPTION
A powershell script to install winget on windows editions without Microsoft Store.
Version defaults as per official microsoft instruction for Windows IoT version (as of 05/08/2024)

## .PARAMETER WorkspaceFolder
Specifies the name to use when creating the workspace folder. This folder will be removed at the end if Cleanup is used

## .PARAMETER WingetVersion
Which version of Winget to donwload from Github. Specify the release tag.

## .PARAMETER UiXamlVersion
Which version of Microsoft.Ui.Xaml to download from NuGet. Currently set to 2.8.6.

## .PARAMETER Arch
Which architecture to install. Currently supported only values "x86" or "arm64".

## .PARAMETER Cleanup
No value. Cleans up the Workspace Folder.

## .PARAMETER Dry
No value. Specify if script should by run "Dry", by only setting up downloads and files, but without actually installing them.

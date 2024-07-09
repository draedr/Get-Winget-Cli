# Get-Winget-Cli
A powershell script to install winget on windows editions without Microsoft Store.

## Minimum Requirements
Tested with Powershell v5.1.22621.3672 on Windows 11 Enterprise.

## Usage
Clone the repository, open a Powershell Console as Admin, and then call `.\Get-Winget-Cli.ps1`.

Otherwise you can use `irm https://raw.githubusercontent.com/draedr/Get-Winget-Cli/main/Get-Winget-Cli.ps1 | iex` directly in the Powershell Console.

This script is to be used only for first installation; To update Winget you can use Winget itself.

## Command Help
### .SYNOPSIS
A powershell script to install winget on windows editions without Microsoft Store.
Version defaults as per official microsoft instruction for Windows IoT version (as of 05/08/2024)

### .DESCRIPTION
A powershell script to install winget on windows editions without Microsoft Store.
Version defaults as per official microsoft instruction for Windows IoT version (as of 05/08/2024)

### .PARAMETER WorkspaceFolder
Specifies the name to use when creating the workspace folder. This folder will be removed at the end if Cleanup is used

### .PARAMETER WingetVersion
Which version of Winget to donwload from Github. Specify the release tag.

### .PARAMETER UiXamlVersion
Which version of Microsoft.Ui.Xaml to download from NuGet. Currently set to 2.8.6.

### .PARAMETER Arch
Which architecture to install. Currently supported only values "x86" or "arm64".

### .FUNCTIONALITY Cleanup
Cleans the workspace directory. To be used in case of an error interrupting the script and leaving the workspace

### .FUNCTIONALITY Dry
Runs the script without actually installing anything.

### .OUTPUTS
None. Get-Winget-Cli.ps1 doesn't generate any output.

### .EXAMPLE
PS> .\Get-Winget-Cli.ps1
### .EXAMPLE
PS> .\Get-Winget-Cli.ps1 -Dry
### .EXAMPLE
PS> .\Get-Winget-Cli.ps1 -Cleanup
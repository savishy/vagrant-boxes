<#
.SYNOPSIS
Run Windows Update, download and install updates automatically
.DESCRIPTION
This script runs Windows Update, and downloads and installs any updates it may find. Automatic installation and reboot is optional.
.PARAMETER Install
Whether or not to install the updates automatically. If Null, the user will be prompted. Valid values are "Y", "Yes", "N" and "No". Optional parameter
.PARAMETER Reboot
If updates require a reboot, whether or not to reboot automatically.  If Null, the user will be prompted. Optional parameter
.EXAMPLE
./WindowsUpdate.ps1 "Yes"
.EXAMPLE
./WindowsUpdate.ps1 "Y" "N"
.NOTES
Run the script on the server or client which requires updates
#>
[cmdletbinding()]
param(
    [ValidateSet("Y", "Yes", "N", "No")]
    [Parameter(HelpMessage="Automatically install updates?")]
    [STRING]$Install,
    [ValidateSet("Y", "Yes", "N", "No")]
    [Parameter(HelpMessage="Automatically reboot when required?")]
    [STRING]$Reboot
)

cls
# Create session and searcher
$UpdateSession = New-Object -Com Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
 
Write-Host("Searching for new updates...") -Fore Green
 
$SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
 
# List all available updates
Write-Host("")
Write-Host("List of available updates:") -Fore Green

For ($X = 0; $X -lt $SearchResult.Updates.Count; $X++){
    $Update = $SearchResult.Updates.Item($X)
    Write-Host( ($X + 1).ToString() + " - " + $Update.Title)
}
 
# No updates available
If ($SearchResult.Updates.Count -eq 0) {
    Write-Host("There are no available updates.")
    Exit
}

# Updates to download
$UpdatesToDownload = New-Object -Com Microsoft.Update.UpdateColl
 
For ($X = 0; $X -lt $SearchResult.Updates.Count; $X++){
    $Update = $SearchResult.Updates.Item($X)
    $Null = $UpdatesToDownload.Add($Update)
}

# Download updates 
Write-Host("")
Write-Host("Downloading Updates...")  -Fore Green
 
$Downloader = $UpdateSession.CreateUpdateDownloader()
$Downloader.Updates = $UpdatesToDownload
$Null = $Downloader.Download()

# Updates to install
$UpdatesToInstall = New-Object -Com Microsoft.Update.UpdateColl
 
For ($X = 0; $X -lt $SearchResult.Updates.Count; $X++){
    $Update = $SearchResult.Updates.Item($X)
    If ($Update.IsDownloaded) {
        $Null = $UpdatesToInstall.Add($Update)        
    }
}
 
If (!$Install){
    $Install = Read-Host("Would you like to install these updates now? (Y/N)")
}
 
# Install updates
If ($Install.ToUpper() -eq "Y" -or $Install.ToUpper() -eq "YES"){
    Write-Host("")
    Write-Host("Installing Updates...") -Fore Green
 
    $Installer = $UpdateSession.CreateUpdateInstaller()
    $Installer.Updates = $UpdatesToInstall
 
    $InstallationResult = $Installer.Install()
 
    Write-Host("")
    Write-Host("List of Installed Updates:") -Fore Green
 
    For ($X = 0; $X -lt $UpdatesToInstall.Count; $X++){
        Write-Host($UpdatesToInstall.Item($X).Title)
        Write-Verbose($UpdatesToInstall.Item($X).Title + ": " + $InstallationResult.GetUpdateResult($X).ResultCode)
    }
 
    Write-Host("")

    switch ($InstallationResult.ResultCode)
    {
        0 { Write-Host("Installation Result: Not Started") }
        1 { Write-Host("Installation Result: In Progress") }
        2 { Write-Host("Installation Result: Succeeded") }
        3 { Write-Host("Installation Result: Succeeded With Errors") -Fore Red }
        default { Write-Host("Installation Result: Succeeded") }
    }
    
    Write-Host("Reboot Required: " + $InstallationResult.RebootRequired)
 
    # Reboot required
    If ($InstallationResult.RebootRequire -eq $True){
        If (!$Reboot){
            $Reboot = Read-Host("Would you like to install these updates now? (Y/N)")
        }
 
        If ($Reboot.ToUpper() -eq "Y" -or $Reboot.ToUpper() -eq "YES"){
            Write-Host("")
            Write-Host("Rebooting...") -Fore Green
            (Get-WMIObject -Class Win32_OperatingSystem).Reboot()
        }
    }
}
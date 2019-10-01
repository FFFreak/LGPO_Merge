<# Install-Baselines.ps1 #>
<#
    Input Lgpo.exe if not in current location
    Reads through subdirectories for
    In each sub directory:
        If a bkupInfo.xml is present
            Read the info and prompt user if they would like to merge this GPO
              backup with local policy

#>

$strLGPO_Location = ".\lgpo.exe"
if (test-path $strLGPO_Location){write-host " ** LGPO Detected -- Continuing!"}
else {
  while (-not (test-path $strLGPO_Location)) {
    $strLGPO_Location = Read-Host -Prompt "Enter path to LGPO: [exit]"
    if ($strLGPO_Location.length -eq 0) {write-host "No Input - exiting";exit}
    if (-not (test-path $strLGPO_Location)) {write-host "`t**Not Detected!"}
    else {write-host " ** LGPO Detected -- Continuing!"}
  } # End WHile
} # END Else

$AllGuids = Get-ChildItem -Directory
$intTotal = $AllGuids.count
$intCurrent = 0

foreach ($guid in $AllGuids) {
  $intCurrent++
  # Read XML Info
  Write-host "`r`nGPO [$intCurrent / $intTotal] *********"
  if (test-path $(".\" + $guid.Name + "\bkupInfo.xml")) {
    [xml]$XmlDocument = Get-Content -Path $(".\" + $guid.Name + "\bkupInfo.xml")
    $strGPOName = $XmlDocument.ChildNodes.GPODisplayName.'#cdata-section'
    $strGPODate = $XmlDocument.ChildNodes.BackupTime.'#cdata-section'.split("T")[0]
    $strGPOTime = $XmlDocument.ChildNodes.BackupTime.'#cdata-section'.split("T")[1]
  
    Write-host "`tName:`r`n`t`t$strGPOName"
    Write-host "`tCreated:`r`n`t`t$strGPODate @ $strGPOTime"
    Write-host "`tGUID:`r`n`t`t$($guid.Name)"
  
    # Prompt to Install
    $blnInstall = $false
    $strInstall = Read-Host -Prompt "Install? [No]"
    if ($strInstall.toLower() -eq 'y' -or $strInstall.toLower() -eq 'yes') {$blnInstall = $true}
  
    # Install
    if ($blnInstall) {
      write-host "`tInstallation -- Installing"
      start-process -NoNewWindow -wait -filepath $strLGPO_Location -argument $("/g " + """" + $($guid.FullName) + """")
      write-host "`t`t-- Installed"
    } else {write-host "`t** Installation -- SKIPPED"}
  } else {write-host "`tNo Backup found in Folder $($guid.Name) -- Skip"}
}
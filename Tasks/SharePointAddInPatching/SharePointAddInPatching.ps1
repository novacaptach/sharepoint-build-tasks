#Requires -Version 4.0

[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    [String] [Parameter(Mandatory = $true)]
    $AddInFile,
    
    [String] [Parameter(Mandatory = $true)]
    $Url,
    
    [String] [Parameter(Mandatory = $true)] 
    $ClientId
)

Write-Verbose "Entering script SharePointAddInPatching.ps1"
Write-Verbose "AddInFile = $AddInFile"
Write-Verbose "Url = $Url"
Write-Verbose "ClientId = $ClientId"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

# Updates the AppManifest.xml
function UpdateManifest (
    [System.Xml.XmlDocument] $AppManifest,
    [string] $Url,
    [string] $ClientId
)
{
    $AppManifest.App.Properties.StartPage = $AppManifest.App.Properties.StartPage -replace "~remoteAppUrl", $Url
    
    if ($AppManifest.App.Properties.InstalledEventEndpoint)
    {
        $AppManifest.App.Properties.InstalledEventEndpoint =
            $AppManifest.App.Properties.InstalledEventEndpoint -replace "~remoteAppUrl", $Url
    }
    
    if ($AppManifest.App.Properties.UninstallingEventEndpoint)
    {
        $AppManifest.App.Properties.UninstallingEventEndpoint =
            $AppManifest.App.Properties.UninstallingEventEndpoint -replace "~remoteAppUrl", $Url
    }
     
    if ($AppManifest.App.Properties.UpgradedEventEndpoint)
    {
        $AppManifest.App.Properties.UpgradedEventEndpoint =
            $AppManifest.App.Properties.UpgradedEventEndpoint -replace "~remoteAppUrl", $Url
    }
    $AppManifest.App.AppPrincipal.RemoteWebApplication.ClientId = $ClientId
}

# Validate input
if (!$AddInFile)
{
    throw (Get-LocalizedString -Key "Add-In file not set.")
}
if (!$Url)
{
    throw (Get-LocalizedString -Key "Url not set.")
}
if (!$ClientId)
{
    throw (Get-LocalizedString -Key "Client ID not set.")
}

# Check for file pattern
if ($AddInFile.Contains("*") -or $AddInFile.Contains("?"))
{
    Write-Verbose "Pattern found in add-in file parameter."
    Write-Verbose "Find-Files -SearchPattern $AddInFile"
    $addInFiles = Find-Files -SearchPattern $AddInFile
    Write-Verbose "addInFiles = $addInFiles"
}
else
{
    Write-Verbose "No Pattern found in add-in file parameter."
    $addInFiles = ,$AddInFile
}

if (!$addInFiles)
{
    throw (Get-LocalizedString -Key "No add-in was found using search pattern '{0}'." -ArgumentList $addInFile)
}

foreach ($af in $addInFiles)
{
    Write-Verbose "Processing $af."
    if ([System.IO.Path]::GetFileName($af) -eq "AppManifest.xml") 
    {
        Write-Verbose "Detected AppManifest type for $af."
        [System.Xml.XmlDocument] $appManifestDoc = new-object System.Xml.XmlDocument
        $appManifestDoc.Load($af)
        UpdateManifest -AppManifest $appManifestDoc -Url $Url -ClientId $ClientId 
        $appManifestDoc.Save($af)
    }
    elseif ([System.IO.Path]::GetExtension($af) -eq ".app")
    {
        Write-Verbose "Detected packaged app for $af."
        [System.Xml.XmlDocument] $xmlDoc = new-object System.Xml.XmlDocument
        
        # Unpack Add-In
        Add-Type -assembly  System.IO.Compression.FileSystem
        $zip =  [System.IO.Compression.ZipFile]::Open($af, "Update")

        # Modify manifest
        Write-Verbose "Patch AppManifest.xml in $af."
        $appManifestEntry = $zip.Entries.Where({$_.name -eq "AppManifest.xml"})
        $appManifestStream = $appManifestEntry.Open()
        $xmlDoc.Load($appManifestStream)
        UpdateManifest -AppManifest $xmlDoc -Url $Url -ClientId $ClientId
                 
        # Save modifications back
        $appManifestStream.SetLength(0)
        $xmlDoc.Save($appManifestStream)
        
        # Repack Add-In
        $appManifestStream.Flush()
        $appManifestStream.Close()
        
        # Process elements
        Write-Verbose "Looking for elements files in $af."
        $elementsEntries = $zip.Entries.Where({$_.name.StartsWith("elements")})
        foreach ($elementEntry in $elementsEntries)
        {
            Write-Verbose "Patch $elementEntry in $af."
            
            # Read content
            $elementEntryStream = $elementEntry.Open()            
            $elementEntryReader = [System.IO.StreamReader](elementEntryStream)
            $elementEntryContent = $elementEntryReader.ReadToEnd()
            $elementEntryReader.Close()
            $elementEntryReader.Dispose()
            
            # Modify content
            $elementEntryContent = $elementEntryContent -replace '~remoteAppUrl', $Url
            
            # Write content back
            $elementEntryWriter = [System.IO.StreamWriter](elementEntryStream)
            $elementEntryWriter.BaseStream.SetLength(0)
            $elementEntryWriter.Write($elementEntryContent)
            $elementEntryStream.Flush()
            $elementEntryStream.Close()            
        }

        $zip.Dispose()
    }
    else 
    {
        throw (Get-LocalizedString -Key "Not supported file type {0}." -ArgumentList $af)
    }
    
    Write-Verbose "Finished processing $af."
}

Write-Verbose "Leaving script SharePointAddInVersioning.ps1"
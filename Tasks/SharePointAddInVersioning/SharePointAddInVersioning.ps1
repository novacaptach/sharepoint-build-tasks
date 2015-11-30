[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    [String] [Parameter(Mandatory = $true)]
    $AddInFile,
    
    [String] [Parameter(Mandatory = $true)] 
    $Version
)

Write-Verbose "Entering script SharePointAddInVersioning.ps1"
Write-Verbose "AddInFile = $AddInFile"
Write-Verbose "Version = $Version"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

# Validate input
if (!$AddInFile)
{
    throw (Get-LocalizedString -Key "Add-In file not set.")
}
if (!$Version)
{
    throw (Get-LocalizedString -Key "Version not set.")
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
        $appManifestDoc.App.Version = $Version
        $appManifestDoc.Save($af)
    }
    elseif ([System.IO.Path]::GetExtension($af) -eq ".app")
    {
        Write-Verbose "Detected packaged app for $af."
        # Unpack Add-In
        Add-Type -assembly  System.IO.Compression.FileSystem
        $zip =  [System.IO.Compression.ZipFile]::Open($af, "Update")
        $appManifestEntry = $zip.Entries.Where({$_.name -eq "AppManifest.xml"})
        $appManifestStream = $appManifestEntry.Open()

        # Modify manifest
        [System.Xml.XmlDocument] $appManifestDoc = new-object System.Xml.XmlDocument
        $appManifestDoc.Load($appManifestStream)
        $appManifestDoc.App.Version = $Version

        # Save modifications back
        $appManifestStream.SetLength(0)
        $appManifestDoc.Save($appManifestStream)

        # Repack Add-In
        $appManifestStream.Flush()
        $appManifestStream.Close()
        $zip.Dispose()
    }
    else 
    {
        throw (Get-LocalizedString -Key "Not supported file type {0}." -ArgumentList $af)
    }
    
    Write-Verbose "Applied version $Version to $af."
}

Write-Verbose "Leaving script SharePointAddInVersioning.ps1"
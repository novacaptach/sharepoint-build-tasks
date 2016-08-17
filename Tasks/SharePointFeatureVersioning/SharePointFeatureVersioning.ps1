#Requires -Version 4.0

[CmdletBinding(DefaultParameterSetName = 'None')]
param(
    [String] [Parameter(Mandatory = $true)]
    $FeatureFile,
    
    [String] [Parameter(Mandatory = $true)] 
    $Version
)

Write-Verbose "Entering script SharePointFeatureVersioning.ps1"
Write-Verbose "FeatureFile = $FeatureFile"
Write-Verbose "Version = $Version"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

# Validate input
if (!$FeatureFile)
{
    throw (Get-LocalizedString -Key "Feature file not set.")
}
if (!$Version)
{
    throw (Get-LocalizedString -Key "Version not set.")
}

# Check for file pattern
if ($FeatureFile.Contains("*") -or $FeatureFile.Contains("?"))
{
    Write-Verbose "Pattern found in feature file parameter."
    Write-Verbose "Find-Files -SearchPattern $FeatureFile"
    $featureFiles = Find-Files -SearchPattern $FeatureFile
    Write-Verbose "featureFiles = $featureFiles"
}
else
{
    Write-Verbose "No Pattern found in feature file parameter."
    $featureFiles = ,$FeatureFile
}

if (!$featureFiles)
{
    throw (Get-LocalizedString -Key "No solution or feature file was found using search pattern '{0}'." -ArgumentList $FeatureFile)
}

foreach ($f in $featureFiles)
{
    Write-Verbose "Processing $f."
    if ([System.IO.Path]::GetExtension($f) -eq ".feature") 
    {
        # Load SharePoint assemblies
        Add-Type -assembly "Microsoft.VisualStudio.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
        Add-Type -assembly "Microsoft.VisualStudio.SharePoint.Designers.Models.Features, Version=14.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"

        Write-Verbose "Detected feature file for $f."
        $feature = [Microsoft.VisualStudio.SharePoint.Designers.Models.Features.FeatureManager]::ReadFeature($f)
        $transaction = $feature.Store.TransactionManager.BeginTransaction("Load Feature Manifest")
        try
        {
	        $newVersion = New-Object -TypeName System.Version -ArgumentList $Version
            Write-Verbose "Update feature $feature.Id  to version $newVersion"
	        $feature.Version = $newVersion;
	        [Microsoft.VisualStudio.SharePoint.Designers.Models.Features.FeatureManager]::WriteFeature($feature, $f);
            $transaction.Commit();        
        }
        finally 
        {
            $transaction.Dispose();        
        }
    }
    else 
    {
        throw (Get-LocalizedString -Key "Not supported file type {0}." -ArgumentList $af)
    }
    
    Write-Verbose "Applied version $Version to $af."
}

Write-Verbose "Leaving script SharePointFeatureVersioning.ps1"
param(
    [string]$project, 
    [string]$publishProfile, 
    [string]$publishDir, 	
    [string]$clean,
    [string]$vsVersion,
    [string]$msBuildArgs,
    [string]$msBuildArchitecture,
    [string]$logProjectEvents
)

Write-Verbose "Entering script SharePointAddInBuild.ps1"
Write-Verbose "publishProfile = $publishProfile"
Write-Verbose "publishDir = $publishDir"
Write-Verbose "project = $project"
Write-Verbose "clean = $clean"
Write-Verbose "vsVersion = $vsVersion"
Write-Verbose "msBuildArgs = $msBuildArgs"
Write-Verbose "msBuildArchitecture = $msBuildArchitecture"
Write-Verbose "logProjectEvents = $logProjectEvents"

# Import the Task.Common and Task.Internal dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if (!$project)
{
    throw (Get-LocalizedString -Key "Project parameter not set on script")
}

if (!$publishProfile)
{
    throw (Get-LocalizedString -Key "Publish profile parameter not set on script")
}

$logEvents = Convert-String $logProjectEvents Boolean
Write-Verbose "logEvents (converted) = $logEvents"
$noTimelineLogger = !$logEvents
Write-Verbose "noTimelineLogger = $noTimelineLogger"
$cleanBuild = Convert-String $clean Boolean
Write-Verbose "clean (converted) = $cleanBuild"

# check for project pattern
if ($project.Contains("*") -or $project.Contains("?"))
{
    Write-Verbose "Pattern found in project parameter."
    Write-Verbose "Find-Files -SearchPattern $project"
    $projectFiles = Find-Files -SearchPattern $project
    Write-Verbose "projectFiles = $projectFiles"
}
else
{
    Write-Verbose "No Pattern found in project parameter."
    $projectFiles = ,$project
}

if (!$projectFiles)
{
    throw (Get-LocalizedString -Key "No solution was found using search pattern '{0}'." -ArgumentList $project)
}

# Look for a specific version of Visual Studio.
$vsLocation = $null
if ($vsVersion -and "$vsVersion".ToUpperInvariant() -ne 'LATEST')
{
    Write-Verbose "Searching for Visual Studio version: $vsVersion"
    $vsLocation = Get-VisualStudioPath -Version $vsVersion

    # Warn if not found.
    if (!$vsLocation)
    {
        Write-Warning (Get-LocalizedString -Key 'Visual Studio not found: Version = {0}. Looking for the latest version.' -ArgumentList $vsVersion)
    }
}

# Look for the latest version of Visual Studio.
if (!$vsLocation)
{
    Write-Verbose 'Searching for the latest Visual Studio version.'
    [string[]]$vsVersions = '14.0', '12.0', '11.0', '10.0' | where { $_ -ne $vsVersion }
    foreach ($vsVersion in $vsVersions)
    {
        # Look for the specific version.
        Write-Verbose "Searching for Visual Studio version: $vsVersion"
        $vsLocation = Get-VisualStudioPath -Version $vsVersion

        # Break if found.
        if ($vsLocation)
        {
            break;
        }
    }

    # Null out the version info and warn if not found.
    if (!$vsLocation)
    {
        $vsVersion = $null
        Write-Warning (Get-LocalizedString -Key 'Visual Studio not found. Try installing a supported version of Visual Studio. See the task definition for a list of supported versions.')
    }
}

# Log the Visual Studio info.
Write-Verbose ('vsVersion = {0}' -f $vsVersion)
Write-Verbose ('vsLocation = {0}' -f $vsLocation)

# Determine which MSBuild version to use.
$msBuildVersion = $null;
if ($vsLocation)
{
    switch ($vsVersion)
    {
        '14.0' { $msBuildVersion = '14.0' }
        '12.0' { $msBuildVersion = '12.0' }
        '11.0' { $msBuildVersion = '4.0' }
        '10.0' { $msBuildVersion = '4.0' }
        default { throw (Get-LocalizedString -Key "Unexpected Visual Studio version '{0}'." -ArgumentList $vsVersion) }
    }
}

Write-Verbose "msBuildVersion = $msBuildVersion"

# Find the MSBuild location.
Write-Verbose "Finding MSBuild location."
$msBuildLocation = Get-MSBuildLocation -Version $msBuildVersion -Architecture $msBuildArchitecture
if (!$msBuildLocation)
{
    # Not found. Throw.
    throw (Get-LocalizedString -Key 'MSBuild not found: Version = {0}, Architecture = {1}' -ArgumentList $msBuildVersion, $msBuildArchitecture)
}

Write-Verbose "msBuildLocation = $msBuildLocation"

# Append additional information to the MSBuild args.
$args = $msBuildArgs;

$args = ('{0} /p:IsPackaging=true /p:ActivePublishProfile="{1}"' -f $args, $publishProfile)

if ([string]::IsNullOrEmpty($publishDir) -ne $true)
{
    Write-Verbose ('adding PublishDir: {0}' -f $publishDir)
    $args = ('{0} /p:PublishDir="{1}"' -f $args, $publishDir)
}

if ($vsLocation)
{
    Write-Verbose ('adding VisualStudioVersion: {0}' -f $vsVersion)
    $args = ('{0} /p:VisualStudioVersion="{1}"' -f $args, $vsVersion)
}

Write-Verbose "args = $args"

if ($cleanBuild)
{
    foreach ($pf in $projectFiles)  
    {
        Invoke-MSBuild $pf -Targets Clean -LogFile "$pf-clean.log" -ToolLocation $msBuildLocation -CommandLineArgs $args -NoTimelineLogger:$noTimelineLogger
    }
}

foreach ($pf in $projectFiles)
{
    Invoke-MSBuild $pf -LogFile "$pf.log" -ToolLocation $msBuildLocation -CommandLineArgs $args  -NoTimelineLogger:$noTimelineLogger
}

Write-Verbose "Leaving script SharePointAddInBuild.ps1"

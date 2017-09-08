function Get-VSPath($Version) {
    Write-Host "Searching for $Version..."
    try {
        # Search for a 15.0 instance.
        if ($Version -eq "15.0") {
            # Use vswhere.exe to determine the Visual Studio Path.
            $homeDirectory = $env:AGENT_HOMEDIRECTORY
            $combinedVsWhereDirectory = Join-Path $homeDirectory "externals\vswhere\vswhere.exe"
            $output = [string](& $combinedVsWhereDirectory -format json)
            $vs15Object = (ConvertFrom-Json -InputObject $output.ToString()) | Select-Object -First 1
            return $vs15Object.installationPath
        }

        # Fallback to searching for an older install.
        if ($path = (Get-ItemProperty -LiteralPath "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\$Version" -Name 'ShellFolder' -ErrorAction Ignore).ShellFolder) {
            return $path
        }
    } finally {
    }
}

function Get-MSBuildPath($msBuildVersion, $msBuildArchitecture) {
    if ($msBuildVersion -eq "15.0") {
        $vsPath = Get-VSPath $msBuildVersion
        if ($msBuildArchitecture -eq "x86") {
            return "$vsPath\MSBuild\$msBuildVersion\bin"
        }
        if ($msBuildArchitecture -eq "x64") {
            return "$vsPath\MSBuild\$msBuildVersion\bin\amd64"
        }
    } else {
        Get-MSBuildLocation -Version $msBuildVersion -Architecture $msBuildArchitecture
    }
}

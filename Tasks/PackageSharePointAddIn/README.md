# Package SharePoint Add-In
Build and package SharePoint Add-In solutions or projects.

## Parameters
### Package SharePoint Add-In
**Solution**: Relative path from repo root of the solution or SharePoint Add-In project to build and package. Wildcards can be used. For example, `**\\*.sln` for all solution files in all sub folders or `**\\*.csproj` for all project files in all sub folders."

Solution files (`*.sln`) are build setting the `IsPackaging` property (`p:IsPackaging=true`). Project files (`*.csproj` or `*.vbproj`) are build calling the `Package` target (`/t:Package`). 

Due to the implementation of the Sonar Task in Visual Studio Team Services packaging a SharePoint Solution is not possible while running Sonar Analysis. In this case the SharePoint Add-In Project should be entered instead of the solution.

**Platform:** Platform for which the Add-In should be build.

**Configuration:** Build configuration to use. 

**Publish Profile:** Publish profile which should be used to package the Add-In.

**Publish Directory:** Path into which the SharePoint Add-In should be deployed. Relative to the path of the SharePoint Add-In project.

**Clean:** Flag if the build should be cleanded first.

**Restore NuGet Packages:** Flag if NuGet packages should be restored.

**Visual Studio Version:** If the preferred version cannot be found, the latest version found will be used instead.

### Advanced

**MSBuild Arguments:** Additional arguments passed to MSBuild.

**MSBuild Architecture:** Optionally supply the architecture (x86, x64) of MSBuild to run.

**Record Project Details:** Flag if project details should be logged.

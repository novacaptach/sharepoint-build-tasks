# SharePoint Add-In Patching
Allows to change the URL and Client ID of SharePoint Add-Ins.

## Parameters
**File pattern:** Relative path from repo root to the SharePoint AppManifest or Add-In file which should be updated. Wildcards can be used. For example `**\\AppManifest.xml` for all AppManifests or `**\\*.app` for all Add-In files in all sub folders.

**Url:** Url of the website which should be set in the Add-In files.

**ClientId:** Client ID which should be set in the Add-In files.

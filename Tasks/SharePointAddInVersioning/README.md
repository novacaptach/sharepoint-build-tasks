# SharePoint Add-In Versioning
Allows to change the version of SharePoint Add-Ins. Supports changing the version before compile time (in AppManifest.xml files) or after compile time (in packaged .app files).

## Parameters
**File pattern:** Relative path from repo root to the SharePoint AppManifest or Add-In file which should be updated. Wildcards can be used. For example `**\\AppManifest.xml` for all AppManifests or `**\\*.app` for all Add-In files in all sub folders.

**Version:** Version which should be set in the Add-In files.

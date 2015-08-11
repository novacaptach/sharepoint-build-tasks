# sharepoint-build-tasks
Build task for building SharePoint Add-Ins and Solutions with TFS Build 2015 (vNext)

## Installation
* Make sure to have [node.js](https://nodejs.org/) installed.
* Install TFS Extensions Command Line Utility
 
    `npm install -g tfx-cli`
     
* Download SharePoint build tasks
* Upload build task to Visual Studio Online

    `tfx build tasks upload --taskPath \Tasks\SharePointAddInBuild`
    
    * Enter the url of your Visual Studio Online collection
    * Enter the personal access token to access Visual Studio Online
    
## Usage
* Add the "SharePoint Add-In Build" custom build step to your build definition.
* Configure the custom build step
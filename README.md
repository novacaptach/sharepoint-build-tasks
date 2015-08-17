# sharepoint-build-tasks
Build task for building SharePoint Add-Ins and Solutions with TFS Build 2015 (vNext)

## Installation
* Make sure to have [node.js](https://nodejs.org/) installed.
* Install TFS Extensions Command Line Utility

    ```bash
        npm install -g tfx-cli
    ```
    
* Download SharePoint build tasks
* Run `tfx login` and pass your Visual Studio Online collection url (`https://<myserver>.visualstudio.com/<mycollection>`) and a personal access token. 
* Upload build task to Visual Studio Online

    ```bash
    tfx build tasks upload --taskPath \Tasks\SharePointAddInBuild`
    ```
    
## Usage
* Add the "SharePoint Add-In Build" custom build step to your build definition.
* Configure the custom build step
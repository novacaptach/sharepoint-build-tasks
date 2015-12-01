# sharepoint-build-tasks
Build task for building SharePoint Add-Ins and Solutions with [Team Foundation Build 2015](http://go.microsoft.com/fwlink/?LinkId=619385).

## Installation
* Make sure to have [node.js](https://nodejs.org/) installed.
* Install TFS Extensions Command Line Utility:

    ```bash
        npm install -g tfx-cli
    ```
    
* [Download SharePoint build task](https://github.com/iozag/sharepoint-build-tasks/releases).
* Run `tfx login` and pass your Visual Studio Online collection url (`https://<myserver>.visualstudio.com/<mycollection>`) and a personal access token. 
* Upload build task to Visual Studio Online:

    ```bash
    tfx build tasks upload --taskPath \Tasks\SharePointAddInBuild
    ```
    
## Usage
See the [Wiki](https://github.com/iozag/sharepoint-build-tasks/wiki) for documentation.

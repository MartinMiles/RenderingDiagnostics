# Rendering Diagnostics

Drop this DLL into `\bin` folder and it will wrap all the components with the diagnostics info of the component name, UID, and view path (for both view and controller renderings). 

No config patch even needed!

Tested on **Habitat** above **Sitecore 9.2**

## Output example

```
<!-- start-component='{ name: "Metadata", uid: "e6ca18d8-321d-4105-9c38-0622e94be400", path: "~/Views/Metadata/Metadata.cshtml" }' -->
    <title>Flexibility, Simplicity, Extensibility - Sitecore Example Site</title>
    <meta name="keywords" content="sitecore"/>
<!-- end-component='{ name: "Metadata", uid: "e6ca18d8-321d-4105-9c38-0622e94be400", path: "~/Views/Metadata/Metadata.cshtml" }' -->
```

# Rendering Diagnostics

Drop this DLL into `\bin` folder and it will wrap all the components with the diagnostics info of the component name, UID, and view path (for both view and controller renderings). 

No config patch even needed!

Tested on **Habitat** above **Sitecore 9.2**

## Output example

```
<!-- start-component='{ name: "HTML Metadata", id: "{E7AE3F87-CF66-40F2-A9F5-33ECF08BC777}", uid: "e6ca18d8-321d-4105-9c38-0622e94be400", placeholder: "head", path: "~/Views/Metadata/PageMetadata.cshtml" }' -->

    <title>About Habitat - Habitat Sitecore Example Site</title>

<!-- end-component='{ name: "HTML Metadata", id: "{E7AE3F87-CF66-40F2-A9F5-33ECF08BC777}", uid: "e6ca18d8-321d-4105-9c38-0622e94be400", placeholder: "head", path: "~/Views/Metadata/PageMetadata.cshtml" }' -->
```

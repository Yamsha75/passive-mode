local function importedResourceRestart(resourceNamme)
    if resourceName == "realdriveby" then
        triggerServerEvent("onPassivePlayerDrivebyResourceStart", localPlayer)
    end
end
addEventHandler("onClientImportedResourceStart", root, importedResourceRestart)
addEventHandler("onClientImportedResourceRestart", root, importedResourceRestart)

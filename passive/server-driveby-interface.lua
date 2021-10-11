local DRIVEBY_RESOURCE_NAME = "realdriveby"
local thisResource = getThisResource()
local drivebyResource = getResourceFromName(DRIVEBY_RESOURCE_NAME)

local function setPlayerDrivebyEnabled(player, enabled)
    assertArgumentType(player, "player", 1)
    assertArgumentType(enabled, "boolean", 2)

    if imports.driveby then imports.driveby.setDrivebyEnabled(player, enabled) end
end

local function elementPassiveModeChangeHandler(enabled)
    if getElementType(source) ~= "player" then return end

    setPlayerDrivebyEnabled(source, not enabled)
end

local function playerDrivebyResourceStartHandler()
    if isElementPassive(client) then
        -- passive player reporting realdriveby resource (re)start
        setPlayerDrivebyEnabled(client, false)
    end
end
addEventHandler(
    "onPassivePlayerDrivebyResourceStart", root, playerDrivebyResourceStartHandler
)

local function importedResourceStartHandler(resourceName)
    if resourceName == "realdriveby" then
        addEventHandler(
            "onElementPassiveModeChange", root, elementPassiveModeChangeHandler
        )
    end
end
addEventHandler("onImportedResourceStart", resourceRoot, importedResourceStartHandler)
addEventHandler("onImportedResourceRestart", resourceRoot, importedResourceStartHandler)

local function resourceStartHandler()
    if imports.driveby then
        addEventHandler(
            "onElementPassiveModeChange", root, elementPassiveModeChangeHandler
        )
    end
end
addEventHandler("onResourceStart", resourceRoot, resourceStartHandler)

local function resourceStopHandler(resource)
    if getResourceName(resource) ~= "realdriveby" then
        removeEventHandler(
            "onElementPassiveModeChange", root, elementPassiveModeChangeHandler
        )
    end
end
addEventHandler("onResourceStop", resourceRoot, resourceStopHandler)

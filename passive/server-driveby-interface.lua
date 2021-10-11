local DRIVEBY_RESOURCE_NAME = "realdriveby"
local drivebyResource = getResourceFromName(DRIVEBY_RESOURCE_NAME)

local thisResource = getThisResource()

local function setPlayerDrivebyEnabled(player, enabled)
    assertArgumentType(player, "player", 1)
    assertArgumentType(enabled, "boolean", 2)

    call(drivebyResource, "setDrivebyEnabled", player, enabled)
end

local function elementPassiveModeChangeHandler(enabled)
    if getElementType(source) ~= "player" then return end

    setPlayerDrivebyEnabled(source, not enabled)
end

local function resourceStartHandler(startingResource)
    if startingResource == thisResource then
        if drivebyResource and getResourceState(drivebyResource) == "running" then
            addEventHandler(
                "onElementPassiveModeChange", root, elementPassiveModeChangeHandler
            )
        end
    elseif getResourceName(startingResource) == DRIVEBY_RESOURCE_NAME then
        drivebyResource = startingResource
        addEventHandler(
            "onElementPassiveModeChange", root, elementPassiveModeChangeHandler
        )
    end
end
addEventHandler("onResourceStart", root, resourceStartHandler)

local function resourceStopHandler(stoppingResource)
    if stoppingResource == drivebyResource then
        removeEventHandler(
            "onElementPassiveModeChange", root, elementPassiveModeChangeHandler
        )
    end
end
addEventHandler("onResourceStop", root, resourceStopHandler)

local function passivePlayerDrivebyResourceStartHandler()
    if isElementPassive(client) then
        -- passive player reporting realdriveby resource (re)start
        setPlayerDrivebyEnabled(client, false)
    end
end
addEventHandler(
    "onPassivePlayerDrivebyResourceStart", root,
        passivePlayerDrivebyResourceStartHandler
)

local PASSIVE_RESOURCE_NAME = "passive"
local passiveResource = nil
local thisResource = getThisResource()

local PASSIVE_REQUEST_KEY = "manual-command"

-- passivePlayers[<player>] = <true>
local passivePlayers = createElementKeyedTable()

function isPlayerPassiveEnabled(player)
    assertArgumentType(player, "player")

    return passivePlayers[player] == true
end

function trySetPlayerPassiveEnabled(player, enabled)
    assertArgumentType(player, "player", 1)
    assertArgumentType(enabled, "boolean", 2)

    passivePlayers[player] = enabled or nil

    if passiveResource then
        if enabled then
            call(passiveResource, "createPassiveRequest", player, PASSIVE_REQUEST_KEY)
        else
            call(passiveResource, "removePassiveRequest", player, PASSIVE_REQUEST_KEY)
        end
    end
end

local function resourceStartHandler(startingResource)
    if startingResource == thisResource then
        local resource = getResourceFromName(PASSIVE_RESOURCE_NAME)
        if resource and getResourceState(resource) == "running" then
            passiveResource = resource
        end
    elseif getResourceName(startingResource) == PASSIVE_RESOURCE_NAME then
        passiveResource = startingResource

        for player, _ in pairs(passivePlayers) do
            trySetPlayerPassiveEnabled(player, true)
        end
    end

end
addEventHandler("onResourceStart", root, resourceStartHandler)

local function resourceStopHandler(stoppingResource)
    if stoppingResource == thisResource then
        if passiveResource then
            for player, _ in pairs(passivePlayers) do
                call(
                    passiveResource, "removePassiveRequest", player, PASSIVE_REQUEST_KEY
                )
            end
        end
    elseif stoppingResource == passiveResource then
        passiveResource = nil
    end
end
addEventHandler("onResourceStop", root, resourceStopHandler)

local function sendIsElementPassive()
    local passiveMode = isElementPassive(source)
    triggerClientEvent(client, "onClientElementPassiveModeChange", source, passiveMode)
end
addEventHandler("onRequestIsElementPassive", root, sendIsElementPassive)

local function sendPassiveElements()
    for element, _ in pairs(passiveElements) do
        triggerLatentClientEvent(client, "onClientElementPassiveModeChange", element,
            true)
    end
end
addEventHandler("onRequestPassiveElements", root, sendPassiveElements)

local function sendCanObjectBePassive()
    assertSourceType(source, "object")

    local passiveModeToggleEnabled = canElementBePassive(source)
    triggerClientEvent(client, "onClientObjectPassiveModeToggleChange", source,
        passiveModeToggleEnabled)
end
addEventHandler("onRequestCanObjectBePassive", root, sendCanObjectBePassive)

local function sendPassiveToggleEnabledObjects()
    for object, _ in pairs(passiveModeObjects) do
        triggerClientEvent(client, "onClientObjectPassiveModeToggleChange", object, true)
        -- if isElementPassive(object) then
        --     triggerClientEvent(client, "onClientElementPassiveModeChange", object, true)
        -- end
    end
end
addEventHandler("onRequestPassiveToggleEnabledObjects", root,
    sendPassiveToggleEnabledObjects)

-- passiveElements[<element>] = true
local passiveElements = {}

local loadedClients = {}

function canElementTypeBePassive(elementType)
    assertArgumentType(elementType, "string")

    return PASSIVE_ELEMENT_TYPES[elementType]
end

function setElementPassive(element, enabled)
    assertArgumentIsElement(element, 1)
    assertArgumentType(enabled, "boolean", 2)

    passiveElements[element] = enabled or nil

    if not triggerEvent("onElementPassiveModePreChange", element, enabled) then
        return false
    end

    triggerEvent("onElementPassiveModeChange", element, enabled)
    triggerClientEvent(
        loadedClients, "onClientElementPassiveModePreChange", element, enabled
    )

    return true
end

function isElementPassive(element)
    assertArgumentIsElement(element)

    return passiveElements[element] == true
end

-- sync
local function sendElementPassiveModeStatus()
    local enabled = isElementPassive(source)

    triggerClientEvent(client, "onClientElementPassiveModePreChange", element, enabled)
end
addEventHandler("onRequestElementPassiveModeStatus", root, sendElementPassiveModeStatus)

local function sendAllPassiveElements()
    for index, player in ipairs(loadedClients) do
        if player == source then return false end
    end

    table.insert(loadedClients, client)

    for element, _ in pairs(passiveElements) do
        local enabled = isElementPassive(element)

        triggerClientEvent(
            client, "onClientElementPassiveModePreChange", element, enabled
        )
    end
end
addEventHandler("onRequestAllPassiveElements", root, sendAllPassiveElements)

-- cleanup
local function playerQuitHandler()
    for index, player in ipairs(loadedClients) do
        if player == source then
            table.remove(loadedClients, index)
            break
        end
    end

    if isElementPassive(source) then
        -- skip triggering "onElementPassiveModePreChange"
        passiveElements[source] = nil
        triggerEvent("onElementPassiveModeChange", source, false)
    end
end
addEventHandler("onPlayerQuit", root, playerQuitHandler)

local function elementDestroyHandler()
    if isElementPassive(source) then
        -- skip triggering "onElementPassiveModePreChange"
        passiveElements[source] = nil
        triggerEvent("onElementPassiveModeChange", source, false)
    end
end
addEventHandler("onElementDestroy", root, elementDestroyHandler)

local function resourceStopHandler()
    -- clear passiveElements table so isElementPassive returns false
    local tempPassiveElements = passiveElements
    passiveElements = {}

    -- trigger onElementPassiveModeChange for other resources
    for element, _ in pairs(tempPassiveElements) do
        triggerEvent("onElementPassiveModeChange", element, false)
    end
end
addEventHandler("onResourceStop", resourceRoot, resourceStopHandler)

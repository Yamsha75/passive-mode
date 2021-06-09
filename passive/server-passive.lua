-- passiveElements[<element>] = true
local passiveElements = {}

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
    triggerClientEvent("onClientElementPassiveModePreChange", element, enabled)

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
    for element, _ in pairs(passiveElements) do
        triggerClientEvent(client, "onClientElementPassiveModePreChange", element, enabled)
    end
end
addEventHandler("onRequestAllPassiveElements", root, sendAllPassiveElements)

-- cleanup
local function disableDestroyedElementPassiveMode()
    if isElementPassive(source) then
        -- skip triggering "onElementPassiveModePreChange"
        passiveElements[source] = nil

        triggerEvent("onElementPassiveModeChange", source, false)
    end
end
addEventHandler("onElementDestroy", root, disableDestroyedElementPassiveMode)
addEventHandler("onPlayerQuit", root, disableDestroyedElementPassiveMode)

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
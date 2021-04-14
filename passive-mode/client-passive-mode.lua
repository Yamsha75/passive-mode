local passiveEnabled = false -- for localPlayer

function isLocalPlayerPassive()
    return passiveEnabled
end

function setObjectPassiveModeToggleEnabled(object, enabled)
    assertArgumentType(object, "object", 1)
    assertArgumentType(enabled, "boolean", 2)

    if enabled then
        if passiveModeObjects[object] then return false end
        passiveModeObjects[object] = true
    else
        if not passiveModeObjects[object] then return false end
        if isElementPassive(object) then setElementPassive(object, false) end
        passiveModeObjects[object] = nil
    end
end

function setElementPassive(element, enabled)
    assertArgumentIsElement(element, 1)
    assertArgumentType(enabled, "boolean", 2)

    if enabled then
        if passiveElements[element] --[[or not canElementBePassive(element)]] then
            return false
        end
        passiveElements[element] = true
    else
        if not passiveElements[element] then return false end
        passiveElements[element] = nil
    end

    triggerEvent("onClientElementPassiveModeChange", element, enabled)
end

local function passiveModeChangeHandler(enabled)
    local elementType = getElementType(source)
    if elementType == "vehicle" then
        setVehiclePassiveEnabled(source, enabled)
    elseif elementType == "object" then
        setObjectPassiveEnabled(source, enabled)
    end
end
addEventHandler("onClientElementPassiveModeChange", root, passiveModeChangeHandler)


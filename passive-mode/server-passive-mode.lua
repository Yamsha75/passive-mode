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

    triggerLatentClientEvent("onObjectPassiveModeToggleChange", object, enabled)
    triggerLatentClientEvent("onClientObjectPassiveModeToggleChange", object, enabled)
end

function setElementPassive(element, enabled, propagateToClients)
    assertArgumentIsElement(element, 1)
    assertArgumentType(enabled, "boolean", 2)
    if propagateToClients ~= nil then
        assertArgumentType(propagateToClients, "boolean", 3)
    end

    if enabled then
        if passiveElements[element] --[[or not canElementBePassive(element)]] then
            return false
        end
        passiveElements[element] = true
    else
        if not passiveElements[element] then return false end
        passiveElements[element] = nil
    end

    local elementType = getElementType(element)
    if elementType == "vehicle" then
        setVehiclePassiveEnabled(element, enabled)
    elseif elementType == "object" then
        setObjectPassiveEnabled(element, enabled)
    end

    triggerEvent("onElementPassiveModeChange", element, enabled)
    if propagateToClients then
        triggerClientEvent("onClientElementPassiveModeChange", element, enabled)
    end
end

function setElementPassive(element, enabled)
    assertArgumentIsElement(element, 1)
    assertArgumentType(enabled, "boolean", 2)

    if isElementPassive(element) == enabled then return false end

    if enabled then
        if not canElementBePassive(element) then return false end
    else
        if not canElementBeNotPassive(element) then return false end
    end

    setElementData(element, "isPassive", enabled)
    triggerEvent("onElementPassiveModeChange", element, enabled)
    triggerClientEvent("onClientElementPassiveModeChange", element, enabled)
end

local function resourceStopHandler()
    for _, elementType in ipairs(COLLISION_ELEMENT_TYPES) do
        for _, element in ipairs(getElementsByType(elementType)) do
            if isElementPassive(element) then
                removeElementData(element, "isPassive")
            end
        end
    end
end
addEventHandler("onResourceStop", resourceRoot, resourceStopHandler)

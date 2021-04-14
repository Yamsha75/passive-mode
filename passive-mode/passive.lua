passiveElements = createElementKeyedTable()
passiveModeObjects = createElementKeyedTable()

function canElementBePassive(element)
    assertArgumentIsElement(element)

    local elementType = getElementType(element)
    if elementType == "object" then
        return canObjectBePassive(element)
    else
        return PASSIVE_ELEMENT_TYPES[elementType] == true
    end
end

function isElementPassive(element)
    assertArgumentIsElement(element)

    return passiveElements[element] == true
end

function canObjectBePassive(object)
    assertArgumentType(object, "object")

    return passiveModeObjects[object] == true
end

function setVehiclePassiveEnabled(vehicle, enabled)
    assertArgumentType(vehicle, "vehicle")

    setVehicleDamageProof(vehicle, enabled)
end

function setObjectPassiveEnabled(object, enabled)
    assertArgumentType(object, "object")

    setObjectBreakable(object, not enabled)
    setElementCollisionsEnabled(object, not enabled)
    if not isElementAttached(object) then setElementFrozen(object, enabled) end
end

local function thisResourceStopHandler()
    for element, _ in pairs(passiveElements) do setElementPassive(element, false) end
end

if SERVERSIDE then
    addEventHandler("onResourceStop", resourceRoot, thisResourceStopHandler)
else
    addEventHandler("onClientResourceStop", resourceRoot, thisResourceStopHandler)
end

function createSafeZone(colshape)
    assertArgumentType(colshape, "colshape")
    local existingSafeZone = next(getElementsByType(SAFEZONE_ELEMENT_TYPE, colshape))
    if existingSafeZone then
        -- given colshape already has an existing safezone element
        return existingSafeZone
    end

    local safezone = createElement(SAFEZONE_ELEMENT_TYPE)
    setElementParent(safezone, colshape)
    setElementInterior(safezone, getElementInterior(colshape))
    setElementDimension(safezone, getElementDimension(colshape))

    if triggerEvent("onClientCreateSafeZone", safezone, colshape) then
        return safezone
    else
        return false
    end
end

local function createSafeZoneHandler(colshape)
    addEventHandler("onClientColShapeHit", source, safeZoneColshapeHitHandler)
    addEventHandler("onClientColShapeLeave", source, safeZoneColshapeLeaveHandler)
    addEventHandler("onClientElementDestroy", source, safeZoneDestroyHandler, false)

    -- trigger safezone enter events for elements initially within colshape
    local colshapeDimension = getElementDimension(colshape)
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        local matchingDimension = (getElementDimension(element) == colshapeDimension)
        triggerEvent("onClientSafeZoneEnter", source, element, matchingDimension)
        triggerEvent("onClientElementSafeZoneEnter", element, source, matchingDimension)
    end
end
addEventHandler("onClientCreateSafeZone", root, createSafeZoneHandler)

-- triggering safezone exit events for elements within colshape on safezone destroy
function safeZoneDestroyHandler()
    if not isElement(source) then return end

    local colshape = getElementParent(source)
    if not colshape or getElementType(colshape) ~= "colshape" then return end

    local colshapeDimension = getElementDimension(colshape)
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        local matchingDimension = (getElementDimension(element) == colshapeDimension)
        triggerEvent("onClientSafeZoneExit", source, element, matchingDimension)
        triggerEvent("onClientElementSafeZoneExit", element, source, matchingDimension)
    end
end

function safeZoneColshapeHitHandler(element, matchingDimension)
    triggerEvent("onClientSafeZoneEnter", this, element, matchingDimension)
    triggerEvent("onClientElementSafeZoneEnter", element, this, matchingDimension)
end

function safeZoneColshapeLeaveHandler(element, matchingDimension)
    triggerEvent("onClientSafeZoneExit", this, element, matchingDimension)
    triggerEvent("onClientElementSafeZoneExit", element, this, matchingDimension)
end

function isPositionInsideAnySafeZone(x, y, z, interior, dimension)
    assertArgumentType(x, "number", 1)
    assertArgumentType(y, "number", 2)
    assertArgumentType(z, "number", 3)
    if interior ~= nil then assertArgumentType(interior, "number", 4) end
    if dimension ~= nil then assertArgumentType(dimension, "number", 5) end

    for _, safezone in ipairs(getElementsByType(SAFEZONE_ELEMENT_TYPE)) do
        if (not interior or interior == getElementInterior(safezone)) and
            (not dimension or dimension == getElementDimension(safezone)) and
            isInsideColShape(getElementParent(safezone), x, y, z) then

            return true
        end
    end

    return false
end

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

    triggerClientEvent("onClientCreateSafeZone", safezone, colshape)

    addEventHandler("onColShapeHit", safezone, safeZoneColshapeHitHandler)
    addEventHandler("onColShapeLeave", safezone, safeZoneColshapeLeaveHandler)
    addEventHandler("onElementDestroy", safezone, safeZoneDestroyHandler)

    -- trigger safezone enter events for elements initially within colshape
    local colshapeDimension = getElementDimension(colshape)
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        local matchingDimension = (getElementDimension(element) == colshapeDimension)
        triggerEvent("onSafeZoneEnter", safezone, element, matchingDimension)
        triggerEvent("onElementSafeZoneEnter", element, safezone, matchingDimension)
    end

    return safezone
end

-- triggering safezone exit events for elements within colshape on safezone destroy
function safeZoneDestroyHandler()
    local colshape = getElementParent(source)
    if not colshape or getElementType(colshape) ~= "colshape" then return end

    local colshapeDimension = getElementDimension(colshape)
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        local matchingDimension = (getElementDimension(element) == colshapeDimension)
        triggerEvent("onSafeZoneExit", source, element, matchingDimension)
        triggerEvent("onElementSafeZoneExit", element, source, matchingDimension)
    end
end

function safeZoneColshapeHitHandler(element, matchingDimension)
    triggerEvent("onSafeZoneEnter", this, element, matchingDimension)
    triggerEvent("onElementSafeZoneEnter", element, this, matchingDimension)
end

function safeZoneColshapeLeaveHandler(element, matchingDimension)
    triggerEvent("onSafeZoneExit", this, element, matchingDimension)
    triggerEvent("onElementSafeZoneExit", element, this, matchingDimension)
end

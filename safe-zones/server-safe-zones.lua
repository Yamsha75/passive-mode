local function colShapeHitHandler(element, matchingDimension)
    if matchingDimension then triggerEvent("onSafeZoneEnter", this, element) end
end

local function colShapeLeaveHandler(element, matchingDimension)
    if matchingDimension then triggerEvent("onSafeZoneExit", this, element) end
end

local function safeZoneDestroyHandler()
    local colShapeDimension = getElementDimension(source)
    for _, element in ipairs(getElementsWithinColShape(source)) do
        if getElementDimension(element) == colShapeDimension then
            triggerEvent("onSafeZoneExit", source, element)
        end
    end
end

function createSafeZone(colshape)
    assertArgumentType(colshape, "colshape")
    if next(getElementsByType(SAFEZONE, colshape)) then return false end

    local safezone = createElement(SAFEZONE)
    setElementParent(safezone, colshape)

    addEventHandler("onColShapeHit", safezone, colShapeHitHandler)
    addEventHandler("onColShapeLeave", safezone, colShapeLeaveHandler)
    addEventHandler("onElementDestroy", safezone, safeZoneDestroyHandler)

    -- trigger "onSafeZoneEnter" event for elements initially within colshape
    local colShapeDimension = getElementDimension(colshape)
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        if getElementDimension(element) == colShapeDimension then
            triggerEvent("onSafeZoneEnter", safezone, element)
        end
    end

    triggerLatentClientEvent("onClientCreateSafeZone", safezone, colshape)

    return safezone
end

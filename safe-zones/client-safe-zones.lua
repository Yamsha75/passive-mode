local function colShapeHitHandler(element, matchingDimension)
    if matchingDimension then
        triggerEvent("onClientSafeZoneEnter", this, element)
        triggerEvent("onClientElementSafeZoneEnter", element, this)
    end
end

local function colShapeLeaveHandler(element, matchingDimension)
    if matchingDimension then triggerEvent("onClientSafeZoneExit", this, element) end
end

local function safeZoneDestroyHandler()
    local colshape = getElementParent(source)
    if not colshape or getElementType(colshape) ~= "colshape" then return false end

    local colShapeDimension = getElementDimension(colshape)
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        if getElementDimension(element) == colShapeDimension then
            triggerEvent("onClientSafeZoneExit", source, element)
        end
    end
end

function createSafeZone(colshape)
    assertArgumentType(colshape, "colshape")
    if next(getElementsByType(SAFEZONE, colshape)) then return false end

    local safezone = createElement(SAFEZONE)
    setElementParent(safezone, colshape)

    triggerEvent("onClientCreateSafeZone", safezone, colshape)

    return safezone
end

local function createSafeZoneHandler(colshape)
    if colshape == nil then
        colshape = getElementParent(source)
        if getElementType(colshape) ~= "colshape" then return false end
    end

    addEventHandler("onClientColShapeHit", source, colShapeHitHandler)
    addEventHandler("onClientColShapeLeave", source, colShapeLeaveHandler)
    addEventHandler("onClientElementDestroy", source, safeZoneDestroyHandler)

    -- trigger "onSafeZoneEnter" event for elements initially within colshape
    local colShapeDimension = getElementDimension(colshape)
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        if getElementDimension(element) == colShapeDimension then
            triggerEvent("onClientSafeZoneEnter", source, element)
        end
    end
end
addEventHandler("onClientCreateSafeZone", root, createSafeZoneHandler)

local PASSIVE_ELEMENT_TYPES = getSetFromList(COLLISION_ELEMENT_TYPES)

local function canElementTypeBePassive(elementType)
    return PASSIVE_ELEMENT_TYPES[elementType]
end

local function colShapeHitEventHandler(element, matchingDimension)
    if matchingDimension and canElementTypeBePassive(getElementType(element)) then
        triggerEvent("onSafeZoneEnter", this, element)
    end
end

local function colShapeLeaveEventHandler(element, matchingDimension)
    if matchingDimension and canElementTypeBePassive(getElementType(element)) then
        triggerEvent("onSafeZoneExit", this, element)
    end
end

local function colShapeDestroyHandler()
    local colshape = getElementParent(source)
    if not colshape or getElementType(colshape) ~= "colshape" then return false end

    local colDimension = getElementDimension(colshape)
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        if canElementBePassive(getElementType(element)) and
                getElementDimension(element) == colDimension then
            triggerEvent("onSafeZoneExit", source, element)
        end
    end
end

function createSafeZone(colshape)
    if next(getElementsByType(SAFEZONE, colshape)) then return false end

    local safezone = createElement(SAFEZONE)
    setElementParent(safezone, colshape)

    addEventHandler("onColShapeHit", safezone, colShapeHitEventHandler)
    addEventHandler("onColShapeLeave", safezone, colShapeLeaveEventHandler)
    addEventHandler("onElementDestroy", safezone, colShapeDestroyHandler)

    -- trigger "onSafeZoneEnter" event for elements initially within colshape
    local colDimension = getElementDimension(colshape)
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        if canElementBePassive(getElementType(element)) and
                getElementDimension(element) == colDimension then
            triggerEvent("onSafeZoneEnter", safezone, element)
        end
    end

    -- triggerLatentClientEvent("onClientCreateSafeZone", safezone)

    return safezone
end

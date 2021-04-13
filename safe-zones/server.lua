local PASSIVE_ELEMENT_TYPES = getSetFromList(COLLISION_ELEMENT_TYPES)

local function canElementTypeBePassive(elementType)
    return PASSIVE_ELEMENT_TYPES[elementType]
end

local function colShapeHitEventHandler(element, matchingDimension)
    if matchingDimension and canElementTypeBePassive(element.type) then
        triggerEvent("onSafeZoneEnter", this, element)
    end
end

local function colShapeLeaveEventHandler(element, matchingDimension)
    if matchingDimension and canElementTypeBePassive(element.type) then
        triggerEvent("onSafeZoneExit", this, element)
    end
end

local function colShapeDestroyHandler()
    local colshape = source.parent
    if not colshape or getElementType(colshape) ~= "colshape" then return false end

    local colDimension = colshape.dimension
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        if canElementBePassive(element.type) and element.dimension == colDimension then
            triggerEvent("onSafeZoneExit", source, element)
        end
    end
end

function createSafeZone(colshape)
    if next(getElementsByType(SAFEZONE, colshape)) then return false end

    local safezone = createElement(SAFEZONE)
    safezone.parent = colshape

    addEventHandler("onColShapeHit", safezone, colShapeHitEventHandler)
    addEventHandler("onColShapeLeave", safezone, colShapeLeaveEventHandler)
    addEventHandler("onElementDestroy", safezone, colShapeDestroyHandler)

    -- trigger "onSafeZoneEnter" event for elements initially within colshape
    local colDimension = colshape.dimension
    for _, element in ipairs(getElementsWithinColShape(colshape)) do
        if canElementTypeBePassive(element.type) and element.dimension == colDimension then
            triggerEvent("onSafeZoneEnter", safezone, element)
        end
    end

    -- triggerLatentClientEvent("onClientCreateSafeZone", safezone)

    return safezone
end

-------------------------
-- SAFEZONE ENTER/EXIT --
-------------------------

local elementSafeZoneCount = {}

function updateElementSafeZone(element, n)
    local currentCount = elementSafeZoneCount[element] or 0
    local newCount = currentCount + n
    elementSafeZoneCount[element] = newCount

    if currentCount == 0 and newCount > 0 then
        if not isElementPassive(element) and canElementBePassive(element) then
            setElementPassive(element, true)
        end
    elseif newCount == 0 and currentCount > 0 then
        if isElementPassive(element) and canElementBeNotPassive(element) then
            setElementPassive(element, false)
        end
    end
end

function safeZoneHitHandler(element, matchingDimension)
    updateElementSafeZone(element, 1)
end
addEventHandler("onSafeZoneEnter", root, safeZoneHitHandler)

function safeZoneLeaveHandler(element, matchingDimension)
    updateElementSafeZone(element, -1)
end
addEventHandler("onSafeZoneExit", root, safeZoneLeaveHandler)

function elementDestroyHandler()
    if canElementTypeBePassive(source.type) then elementSafeZoneCount[source] = nil end
end
addEventHandler("onElementDestroy", root, elementDestroyHandler)

function playerQuitHandler()
    elementSafeZoneCount[source] = nil
end
addEventHandler("onPlayerQuit", root, playerQuitHandler)

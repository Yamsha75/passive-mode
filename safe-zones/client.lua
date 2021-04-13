local function colShapeDestroyHandler()
    if source.type ~= "colshape" then return end

    local colshapeDimension = source.dimension
    for _, element in ipairs(getElementsWithinColShape(source)) do
        local matchingDimension = (colshapeDimension == element.dimension)
        triggerEvent("onClientColShapeLeave", source, element, matchingDimension)
    end
end
addEventHandler("onClientElementDestroy", root, colShapeDestroyHandler)

-- local function colShapeHitEventHandler(element, matchingDimension)
--     print(inspect(element), matchingDimension)
--     if matchingDimension then triggerEvent("onClientSafeZoneEnter", this, element) end
-- end

-- local function colShapeLeaveEventHandler(element, matchingDimension)
--     if matchingDimension then triggerEvent("onClientSafeZoneExit", this, element) end
-- end

-- local function createSafeZoneHandler()
--     assert(addEventHandler("onClientColShapeHit", source, colShapeHitEventHandler))
--     assert(addEventHandler("onClientColShapeLeave", source, colShapeLeaveEventHandler))
-- end
-- addEventHandler("onClientCreateSafeZone", root, createSafeZoneHandler)

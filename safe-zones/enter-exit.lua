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

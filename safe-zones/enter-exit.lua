local elementSafeZoneCount = createElementKeyedTable()

local function safeZoneHitHandler(element)
    if not canElementBePassive(element) then return end

    local oldCount = elementSafeZoneCount[element] or 0
    local newCount = oldCount + 1
    elementSafeZoneCount[element] = newCount

    if oldCount == 0 then setElementPassive(element, true) end
end

local function safeZoneLeaveHandler(element)
    if not canElementBePassive(element) then return end

    local oldCount = elementSafeZoneCount[element] or 0
    local newCount = oldCount - 1

    if newCount == 0 then setElementPassive(element, false) end
end

if SERVERSIDE then
    addEventHandler("onSafeZoneEnter", root, safeZoneHitHandler)
    addEventHandler("onSafeZoneExit", root, safeZoneLeaveHandler)
else
    addEventHandler("onClientSafeZoneEnter", root, safeZoneHitHandler)
    addEventHandler("onClientSafeZoneExit", root, safeZoneLeaveHandler)
end

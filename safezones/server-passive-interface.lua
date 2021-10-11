local PASSIVE_RESOURCE_NAME = "passive"
local passiveResource = nil
local thisResource = getThisResource()

local PASSIVE_REQUEST_KEY = "in-safezone"

local PASSIVE_ELEMENT_TYPES = {vehicle = true, ped = true, player = true}

-- elementSafeZoneCount[<element>] = <integer>
local elementSafeZoneCount = createElementKeyedTable()

local function canElementTypeBePassive(elementType)
    assertArgumentType(elementType, "string")

    return PASSIVE_ELEMENT_TYPES[elementType] == true
end

local function trySetElementPassiveEnabled(element, enabled)
    assertArgumentIsElement(element, 1)
    assertArgumentType(enabled, "boolean", 2)

    if passiveResource then
        if enabled then
            call(passiveResource, "createPassiveRequest", element, PASSIVE_REQUEST_KEY)
        else
            call(passiveResource, "removePassiveRequest", element, PASSIVE_REQUEST_KEY)
        end
    end
end

local function safeZoneEnterHandler(element, matchingDimension)
    if not canElementTypeBePassive(getElementType(element)) then return end

    if matchingDimension then
        local oldCount = elementSafeZoneCount[element] or 0
        local newCount = oldCount + 1
        elementSafeZoneCount[element] = newCount

        if oldCount == 0 then trySetElementPassiveEnabled(element, true) end
    end
end
addEventHandler("onSafeZoneEnter", root, safeZoneEnterHandler)

local function safeZoneExitHandler(element, matchingDimension)
    if not canElementTypeBePassive(getElementType(element)) then return end

    if matchingDimension then
        local oldCount = elementSafeZoneCount[element]
        local newCount = oldCount - 1

        if newCount == 0 then
            elementSafeZoneCount[element] = nil
            trySetElementPassiveEnabled(element, false)
        else
            elementSafeZoneCount[element] = newCount
        end
    end
end
addEventHandler("onSafeZoneExit", root, safeZoneExitHandler)

local function resourceStartHandler(startingResource)
    if startingResource == thisResource then
        local resource = getResourceFromName(PASSIVE_RESOURCE_NAME)
        if resource and getResourceState(resource) == "running" then
            passiveResource = resource
        end
    elseif getResourceName(startingResource) == PASSIVE_RESOURCE_NAME then
        passiveResource = startingResource

        for element, _ in pairs(elementSafeZoneCount) do
            trySetElementPassiveEnabled(element, true)
        end
    end
end
addEventHandler("onResourceStart", root, resourceStartHandler)

local function resourceStopHandler(stoppingResource)
    if stoppingResource == thisResource then
        if passiveResource then
            for element, _ in pairs(elementSafeZoneCount) do
                call(
                    passiveResource, "removePassiveRequest", element,
                        PASSIVE_REQUEST_KEY
                )
            end
        end
    elseif stoppingResource == passiveResource then
        passiveResource = nil
    end
end
addEventHandler("onResourceStop", root, resourceStopHandler)

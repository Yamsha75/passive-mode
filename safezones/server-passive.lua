local PASSIVE_ELEMENT_TYPES = {vehicle = true, ped = true, player = true}
local PASSIVE_REQUEST_KEY = "in-safezone"

-- elementSafeZoneCount[<element>] = <integer>
local elementSafeZoneCount = createElementKeyedTable()

local function canElementTypeBePassive(elementType)
    assertArgumentType(elementType, "string")

    return PASSIVE_ELEMENT_TYPES[elementType] == true
end

local function safeZoneEnterHandler(element, matchingDimension)
    if not canElementTypeBePassive(getElementType(element)) then return end

    if matchingDimension then
        local oldCount = elementSafeZoneCount[element] or 0
        local newCount = oldCount + 1
        elementSafeZoneCount[element] = newCount

        if oldCount == 0 and imports.passive then
            imports.passive.createPassiveRequest(element, PASSIVE_REQUEST_KEY)
        end
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
            print(imports.passive)
            if imports.passive then
                imports.passive.removePassiveRequest(element, PASSIVE_REQUEST_KEY)
            end
        else
            elementSafeZoneCount[element] = newCount
        end
    end
end
addEventHandler("onSafeZoneExit", root, safeZoneExitHandler)

local function importedResourceStartHandler(resourceName)
    if resourceName == "passive" then
        for element, _ in pairs(elementSafeZoneCount) do
            imports.passive.createPassiveRequest(element, PASSIVE_REQUEST_KEY)
        end
    end
end
addEventHandler("onImportedResourceStart", resourceRoot, importedResourceStartHandler)
addEventHandler("onImportedResourceRestart", resourceRoot, importedResourceStartHandler)

local function resourceStopHandler()
    if imports.passive then
        for element, _ in pairs(elementSafeZoneCount) do
            imports.passive.removePassiveRequest(element, PASSIVE_REQUEST_KEY)
        end
    end
end
addEventHandler("onResourceStop", resourceRoot, resourceStopHandler)

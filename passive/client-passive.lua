-- passiveElements[<element>] = true
local passiveElements = createElementKeyedTable()
-- localPlayer's passive mode
local localPlayerPassive = false

function updateElementAlpha(element, passiveEnabled)
    assertArgumentIsElement(element, 1)
    if passiveEnabled ~= nil then
        assertArgumentType(passiveEnabled, "boolean", 2)
    else
        passiveEnabled = isElementPassive(element)
    end

    if passiveEnabled == isLocalPlayerPassive() then
        setElementAlpha(element, 255)
    else
        setElementAlpha(element, 127)
    end
end

function updateElementCollisions(element, passiveEnabled)
    assertArgumentIsElement(element, 1)
    if passiveEnabled ~= nil then
        assertArgumentType(passiveEnabled, "boolean", 2)
    else
        passiveEnabled = isElementPassive(element)
    end

    if passiveEnabled then
        -- disable collisions between element and every other streamed-in element of
        -- supported types
        for elementType, _ in pairs(PASSIVE_ELEMENT_TYPES) do
            for _, otherElement in ipairs(getElementsByType(elementType, root, true)) do
                setElementCollidableWith(element, otherElement, false)
            end
        end
    else
        -- update collisions between element and every other streamed-in element of
        -- supported types; depends on other elements' passive mode status
        for elementType, _ in pairs(PASSIVE_ELEMENT_TYPES) do
            for _, otherElement in ipairs(getElementsByType(elementType, root, true)) do
                local collisionsEnabled = not isElementPassive(element)
                setElementCollidableWith(element, otherElement, collisionsEnabled)
            end
        end
    end
end

function canElementTypeBePassive(elementType)
    assertArgumentType(elementType, "string")

    return PASSIVE_ELEMENT_TYPES[elementType]
end

function isElementPassive(element)
    assertArgumentIsElement(element)

    return passiveElements[element] == true
end

function isLocalPlayerPassive()
    return localPlayerPassive
end

local function elementPassiveModePreChangeHandler(enabled)
    passiveElements[source] = enabled or nil

    if source == localPlayer then
        localPlayerPassive = enabled

        -- update alpha for every element of supported types
        for elementType, _ in pairs(PASSIVE_ELEMENT_TYPES) do
            for _, element in ipairs(getElementsByType(elementType)) do
                updateElementAlpha(element)
            end
        end
    else
        updateElementAlpha(source, enabled)
    end

    if isElementStreamedIn(source) then updateElementCollisions(source) end

    triggerEvent("onClientElementPassiveModeChange", source, enabled)
end
addEventHandler(
    "onClientElementPassiveModePreChange", root, elementPassiveModePreChangeHandler
)

local function elementStreamInHandler()
    updateElementAlpha(source)
    updateElementCollisions(source)
end
addEventHandler("onClientElementStreamIn", root, elementStreamInHandler)

-- sync
local function resourceStartHandler()
    triggerServerEvent("onRequestAllPassiveElements", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStartHandler)

-- cleanup
local function disableDestroyedElementPassiveMode()
    if not isElement(source) then return end

    if isElementPassive(source) then
        passiveElements[source] = nil

        triggerClientEvent("onClientElementPassiveModeChange", source, false)
    end
end
addEventHandler("onClientElementDestroy", root, disableDestroyedElementPassiveMode)
addEventHandler("onClientPlayerQuit", root, disableDestroyedElementPassiveMode)

local function resourceStopHandler()
    -- clear local player's passive variable
    localPlayerPassive = false

    -- clear passiveElements table so isElementPassive returns false
    local passiveElementsTemp = passiveElements
    passiveElements = {}

    -- revert changes to alpha and collisions; the way it's done below reduces calls
    -- to setElementCollidableWith, because for each pair of elements it only needs to
    -- be called once and without a specific order; in other words: "f(a, b)" does the
    -- same as "f(b, a)", so we can skip about half of calls to the function

    -- streamedInElements[<elementType>] = <list>
    local streamedInElements = {}
    local elementTypesCount = 0
    for elementType, _ in pairs(PASSIVE_ELEMENT_TYPES) do
        -- reset alpha for each element of supported type
        for _, element in ipairs(getElementsByType(elementType)) do
            setElementAlpha(element, 255)
        end

        -- remember the list of streamed-in elements of supported type
        elementTypesCount = elementTypesCount + 1
        streamedInElements[elementTypesCount] = getElementsByType(
            elementType, root, true
        )
    end

    for i = 1, elementTypesCount do
        -- for each supported element type
        local elements = streamedInElements[i]
        local elementsCount = #elements

        for a = 1, elementsCount do
            -- for each streamed-in element of that type
            local element = elements[a]

            -- reset collisions between elements of the same type
            for b = a + 1, elementsCount do
                -- starting from "a + 1" halves the number of loop executions
                setElementCollidableWith(element, elements[b], true)
            end

            -- reset collisions between element and streamed-in elements of different
            -- supported type
            for j = i + 1, elementTypesCount do
                -- starting from "i + 1" halves the number of loop executions
                local otherElements = streamedInElements[j]
                local otherElementsCount = #otherElements
                for b = 1, otherElementsCount do
                    setElementCollidableWith(element, otherElements[b], true)
                end
            end
        end
    end

    -- trigger onClientElementPassiveModeChange for other resources
    for element, _ in pairs(passiveElementsTemp) do
        triggerEvent("onClientElementPassiveModeChange", element, false)
    end
end
addEventHandler("onClientResourceStop", resourceRoot, resourceStopHandler)

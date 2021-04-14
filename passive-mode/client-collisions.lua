function updatePassiveElementCollisions(theElement)
    for _, elementType in ipairs(COLLISION_ELEMENT_TYPES) do
        for _, element in ipairs(getElementsByType(elementType, root, true)) do
            setElementCollidableWith(theElement, element, false)
        end
    end
end

function updateElementCollisionsWithPassiveElements(theElement)
    for _, elementType in ipairs(COLLISION_ELEMENT_TYPES) do
        for _, element in ipairs(getElementsByType(elementType, root, true)) do
            local passiveEnabled = isElementPassive(element)
            setElementCollidableWith(theElement, element, not passiveEnabled)
        end
    end
end

function elementPassiveModeChangeHandler(enabled, tailCall)
    if isElementStreamedIn(source) then
        if enabled then
            updatePassiveElementCollisions(source)
        else
            updateElementCollisionsWithPassiveElements(source)
        end
    -- elseif enabled and not tailCall then
    --     setTimer(triggerEvent, 100, 1, "onClientElementPassiveModeChange", source, true,
    --         true)
    end
end
addEventHandler("onClientElementPassiveModeChange", root,
    elementPassiveModeChangeHandler)

function updateStreamedInElementCollisions()
    if isElementPassive(source) then
        updatePassiveElementCollisions(source)
    else
        updateElementCollisionsWithPassiveElements(source)
    end
end
addEventHandler("onClientElementStreamIn", root, updateStreamedInElementCollisions)

function updateCollisionsOnResoureStart()
    local elementLists = {}
    for index, elementType in ipairs(COLLISION_ELEMENT_TYPES) do
        elementLists[index] = getElementsByType(elementType, root, true)
    end

    local E = #elementLists
    for index, elementList in ipairs(elementLists) do
        -- firstly, update collisions between elements from the same list
        local N = #elementList
        for a, element in ifilter(elementList, isElementPassive) do
            for b = a + 1, N do -- this avoids doing the same pair again
                local otherElement = elementList[b]
                setElementCollidableWith(element, otherElement, false)
            end
        end
        -- secondly, update collisions between elements from different lists
        for otherIndex = index + 1, E do
            local otherElementList = elementLists[otherIndex]
            for _, element in ipairs(elementList) do
                if isElementPassive(element) then
                    for _, otherElement in ipairs(otherElementList) do
                        setElementCollidableWith(element, otherElement, false)
                    end
                else
                    for _, otherElement in ipairs(otherElementList) do
                        local collisionsEnabled = not isElementPassive(otherElement)
                        setElementCollidableWith(element, otherElement,
                            collisionsEnabled)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientResourceStart", resourceRoot, updateCollisionsOnResoureStart)

function updateCollisionsOnResourceStop()
    local elementLists = {}
    for index, elementType in ipairs(COLLISION_ELEMENT_TYPES) do
        elementLists[index] = getElementsByType(elementType, root, true)
    end

    local E = #elementLists
    for index, elementList in ipairs(elementLists) do
        -- firstly, update collisions between elements from the same list
        local N = #elementList
        for a, element in ifilter(elementList, isElementPassive) do
            for b = a + 1, N do -- this avoids doing the same pair again
                local otherElement = elementList[b]
                setElementCollidableWith(element, otherElement, true)
            end
        end
        -- secondly, update collisions between elements from different lists
        for otherIndex = index + 1, E do
            local otherElementList = elementLists[otherIndex]
            for _, element in ipairs(elementList) do
                if isElementPassive(element) then
                    for _, otherElement in ipairs(otherElementList) do
                        setElementCollidableWith(element, otherElement, true)
                    end
                else
                    for _, otherElement in ipairs(otherElementList) do
                        local collisionsEnabled = isElementPassive(otherElement)
                        setElementCollidableWith(element, otherElement,
                            collisionsEnabled)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientResourceStop", resourceRoot, updateCollisionsOnResourceStop)

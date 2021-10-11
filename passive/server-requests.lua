-- passiveRequests[<element>] = <elementPassiveRequests:table>
-- elementPassiveRequests[<key>] = true/nil
local passiveRequests = createElementKeyedTable()

-- exported function
function createPassiveRequest(element, key)
    assertArgumentIsElement(element, 1)
    assertArgumentType(key, "string", 2)

    -- get all requests for element
    local elementPassiveRequests = passiveRequests[element]

    if elementPassiveRequests then
        -- one or more requests for element already exist
        if elementPassiveRequests[key] then
            -- request for element with given key already exists
            return false
        end

        elementPassiveRequests[key] = true
    else
        -- first request for element
        passiveRequests[element] = {[key] = true}
        if not isElementPassive(element) then setElementPassive(element, true) end
    end

    return true
end

-- exported function
function getPassiveRequests(element)
    assertArgumentIsElement(element)

    return passiveRequests[element]
end

-- exported function
function doesPassiveRequestExist(element, key)
    assertArgumentIsElement(element, 1)
    assertArgumentType(key, "string", 2)

    return (passiveRequests[element] or {})[key] == true
end

-- exported function
function removePassiveRequest(element, key)
    assertArgumentIsElement(element, 1)
    assertArgumentType(key, "string", 2)

    -- get all requests for element
    local elementPassiveRequests = passiveRequests[element]
    if not elementPassiveRequests or not elementPassiveRequests[key] then
        -- request for element with given key doesn't exist
        return false
    end

    -- remove request for given element and key
    elementPassiveRequests[key] = nil

    if not next(elementPassiveRequests) then
        -- removed last request for given element and key
        passiveRequests[element] = nil
        if isElementPassive(element) then setElementPassive(element, false) end
    end

    return true
end

-- cleanup
local function resourceStopHandler()
    -- clear passiveRequests table
    passiveRequests = {}
end
addEventHandler("onResourceStop", resourceRoot, resourceStopHandler)

function getVariableType(variable)
    local variableType = type(variable)
    if variableType ~= "userdata" then return variableType end

    local variableType = getUserdataType(variable)
    if variableType ~= "element" then return variableType end

    return getElementType(variable)
end

-- wrappers for a table with elements as keys and automatic cleanup
function createElementKeyedTable()
    local table = {}

    local function cleanupFunction()
        if source ~= nil then table[source] = nil end
    end

    if localPlayer == nil then
        addEventHandler("onElementDestroy", root, cleanupFunction)
        addEventHandler("onPlayerQuit", root, cleanupFunction)
    else
        addEventHandler("onClientElementDestroy", root, cleanupFunction)
        addEventHandler("onClientPlayerQuit", root, cleanupFunction)
    end

    return table
end

function getPedDrivenVehicle(ped)
    local variableType = getVariableType(ped)
    if variableType ~= "ped" and variableType ~= "player" then
        error(string.format("expected ped or player as argument, got %s", variableType))
    end

    local vehicle = getPedOccupiedVehicle(ped)
    if vehicle and getPedOccupiedVehicleSeat(ped) == 0 then return vehicle end

    return false
end


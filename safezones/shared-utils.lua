function getVariableType(variable)
    local variableType = type(variable)
    if variableType ~= "userdata" then return variableType end

    local variableType = getUserdataType(variable)
    if variableType ~= "element" then return variableType end

    return getElementType(variable)
end

-- wrapper for a table with elements as keys and automatic cleanup
function createElementKeyedTable()
    local table = {}

    local function clearElementFromTable()
        if source ~= nil then table[source] = nil end
    end

    if localPlayer == nil then
        addEventHandler("onElementDestroy", root, clearElementFromTable)
        addEventHandler("onPlayerQuit", root, clearElementFromTable)
    else
        addEventHandler("onClientElementDestroy", root, clearElementFromTable)
        addEventHandler("onClientPlayerQuit", root, clearElementFromTable)
    end

    return table
end

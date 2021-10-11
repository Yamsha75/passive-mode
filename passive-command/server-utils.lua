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

function getNowTimestamp()
    return getRealTime()["timestamp"]
end

-- formatting number of seconds for Polish language
function formatSeconds(seconds)
    assertArgumentType(seconds, "number")

    if seconds == 1 then return "1 sekundę" end

    local singlesDigit = seconds % 10
    local tensDigit = (seconds % 100 - singlesDigit) / 10

    if tensDigit ~= 1 and singlesDigit >= 2 and singlesDigit <= 4 then
        return seconds .. " sekundy"
    end

    return seconds .. " sekund"
end

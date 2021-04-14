function ifilter(list, condition)
    local inext = function(list, index)
        index = index + 1
        local value = list[index]
        while value ~= nil and not condition(value) do
            index = index + 1
            value = list[index]
        end

        if value ~= nil then
            return index, value
        else
            return nil, nil
        end
    end

    return inext, list, 0
end

function getSetFromList(list)
    local set = {}
    for _, value in ipairs(list) do set[value] = true end

    return set
end

function createElementKeyedTable()
    local table = {}

    local function clearElementFromTable()
        if source ~= nil then
            table[source] = nil
        end
    end

    if CLIENTSIDE then
        addEventHandler("onClientElementDestroy", root, clearElementFromTable)
        addEventHandler("onClientPlayerQuit", root, clearElementFromTable)
    else
        addEventHandler("onElementDestroy", root, clearElementFromTable)
        addEventHandler("onPlayerQuit", root, clearElementFromTable)
    end

    return table
end

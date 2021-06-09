IMPORTS = {realdriveby = {alias = "driveby", required = false}}

thisResource = getThisResource()
thisResourceName = getResourceName(thisResource)

-- imports[<alias:string>] = <metatable>
imports = {}

-- accepted time between stopping and restarting of an imported resource in milliseconds
RESOURCE_STOP_DELAY = 1000
-- resourceRestartTimers[<resourceName:string>] = <timer>
resourceRestartTimers = {}

local importMetaTable = {
    __index = function(self, key)
        return function(...)
            return call(self["resource"], key, ...)
        end
    end,
}

function isResourceImported(resourceName)
    return IMPORTS[resourceName] ~= nil
end

function isResourceRequired(resourceName)
    return (IMPORTS[resourceName] or {})["required"] == true
end

function getResourceAlias(resourceName)
    return (IMPORTS[resourceName] or {})["alias"]
end

function createResourceInterface(resourceName)
    local resource = getResourceFromName(resourceName)
    local resourceAlias = getResourceAlias(resourceName)

    imports[resourceAlias] = setmetatable({resource = resource}, importMetaTable)
end

function clearResourceInterface(resourceAlias)
    imports[resourceAlias] = nil
end

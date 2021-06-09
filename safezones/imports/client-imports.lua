addEvent("onClientImportedResourceStart")
addEvent("onClientImportedResourceStop")
addEvent("onClientImportedResourceRestart")

local function checkImportedResource(resourceName)
    local resource = getResourceFromName(resourceName)
    local required = isResourceRequired(resourceName)

    if not required then
        return true
    else
        return resource and getResourceState(resource) == "running"
    end
end

local function resourceStartHandler(resource)
    if resource == thisResource then
        local success = true
        for resourceName, _ in pairs(IMPORTS) do
            success = checkImportedResource(resourceName) and success
        end

        if success then
            for resourceName, _ in pairs(IMPORTS) do
                createResourceInterface(resourceName)
            end
        end
    else
        local resourceName = getResourceName(resource)
        if isResourceImported(resourceName) then
            local required = isResourceRequired(resourceName)
            createResourceInterface(resourceName)

            local timer = resourceRestartTimers[resourceName]
            if timer then
                if isTimer(timer) then killTimer(timer) end
                resourceRestartTimers[resourceName] = nil

                triggerEvent(
                    "onClientImportedResourceRestart", resourceRoot, resourceName,
                        required
                )
            else
                triggerEvent(
                    "onClientImportedResourceStart", resourceRoot, resourceName,
                        required
                )
            end
        end
    end
end
addEventHandler("onResourceStart", root, resourceStartHandler, true, "high")

local function resourceStopHandler(resource)
    if isResourceImported(resource) then
        local resourceName = getResourceName(resource)
        local resourceAlias = getResourceAlias(resourceName)
        local required = isResourceRequired(resourceName)

        clearResourceInterface(resourceAlias)

        setTimer(
            triggerEvent, RESOURCE_STOP_DELAY, 1, "onClientImportedResourceStop",
                resourceRoot, resourceName, required
        )
    end
end
addEventHandler("onResourceStop", root, resourceStopHandler, true, "high")

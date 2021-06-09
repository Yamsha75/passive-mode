addEvent("onImportedResourceStart")
addEvent("onImportedResourceStop")
addEvent("onImportedResourceRestart")

local function checkImportedResource(resourceName)
    local resource = getResourceFromName(resourceName)
    local required = isResourceRequired(resourceName)

    if resource then
        if getResourceState(resource) ~= "running" then
            if required then
                outputDebugString(
                    string.format(
                        "Required resource %s is not running!", resourceName
                    ), 1
                )
                return false
            else
                outputDebugString(
                    string.format(
                        "Optional resource %s is not running!", resourceName
                    ), 2
                )
            end
        end
    else
        if required then
            outputDebugString(
                string.format(
                    "Required resource %s is missing!", resourceName
                ), 1
            )
            return false
        else
            outputDebugString(
                string.format(
                    "Optional resource %s is missing!", resourceName
                ), 2
            )
        end
    end

    return true
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
        else
            outputDebugString(
                string.format(
                    "Resource %s cannot start, because required resource(s) aren't running!",
                        thisResourceName
                ), 1
            )
            cancelEvent()
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
                    "onImportedResourceRestart", resourceRoot, resourceName, required
                )
            else
                triggerEvent(
                    "onImportedResourceStart", resourceRoot, resourceName, required
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
            triggerEvent, RESOURCE_STOP_DELAY, 1, "onImportedResourceStop",
                resourceRoot, resourceName, required
        )
    end
end
addEventHandler("onResourceStop", root, resourceStopHandler, true, "high")

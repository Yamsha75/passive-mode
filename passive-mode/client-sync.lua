local function elementStreamInHandler()
    if isElementLocal(source) then return end

    local elementType = getElementType(source)
    local canBePassive = canElementBePassive(source)

    if elementType == "object" and not canBePassive then
        triggerServerEvent("onRequestCanObjectBePassive", source)
    elseif canBePassive and not isElementPassive(source) then
        triggerServerEvent("onRequestIsElementPassive", source)
    end
end
addEventHandler("onClientElementStreamIn", root, elementStreamInHandler)

local function elementStreamOutHandler()
    if isElementLocal(source) then return end

    -- nothing for now
end
-- addEventHandler("onClientElementStreamIn", root, elementStreamOutHandler)

local function thisResourceStartHandler()
    triggerLatentServerEvent("onRequestPassiveElements", localPlayer)
    triggerLatentServerEvent("onRequestPassiveToggleEnabledObjects", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, thisResourceStartHandler)

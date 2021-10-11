local jackedPed

local function vehicleStartEnter(ped, seat)
    if ped ~= localPlayer then return end

    jackedPed = getVehicleOccupant(source, seat)
end
addEventHandler("onClientVehicleStartEnter", root, vehicleStartEnter)

local function localPlayerVehiclEnterHandler(vehicle, seat)
    if not jackedPed then return end

    triggerServerEvent("onPlayerReportAggression", localPlayer, 1)
    jackedPed = nil
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, localPlayerVehiclEnterHandler)

local function vehicleDamageHandler(responsibleElement)
    if not responsibleElement then return end

    local elementType = getElementType(responsibleElement)

    if elementType == "vehicle" then
        local driver = getVehicleOccupant(responsibleElement)
        if driver and getElementType(driver) == "player" then
            triggerServerEvent("onPlayerReportAggression", localPlayer, 0)
        end
    elseif elementType == "player" then
        triggerServerEvent("onPlayerReportAggression", responsibleElement, 1)
    end
end
addEventHandler("onClientVehicleDamage", root, vehicleDamageHandler)

local function pedHitByWaterCannon()
    local driver = getVehicleOccupant(source)

    if driver and getElementType(driver) == "player" then
        triggerServerEvent("onPlayerReportAggression", driver, 0)
    end
end
addEventHandler("onClientPedHitByWaterCannon", root, pedHitByWaterCannon)
addEventHandler("onClientPlayerHitByWaterCannon", root, pedHitByWaterCannon)

local function pedDamageHandler(attacker)
    if attacker and getElementType(attacker) == "player" then
        triggerServerEvent("onPlayerReportAggression", attacker, 1)
    end
end
addEventHandler("onClientPedDamage", root, pedDamageHandler)

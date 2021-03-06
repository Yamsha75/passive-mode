local function updateVehicleFireControl(enabled)
    toggleControl(VEHICLE_FIRE_CONTROL_NAME, enabled)
end

local function elementStreamInHandler()
    if getElementType(source) == "vehicle" and source ==
        getPedDrivenVehicle(localPlayer) and isLocalPlayerPassive() then
        -- most likely localPlayer's vehicle model changed
        local enabled = not isVehicleArmed(source)
        updateVehicleFireControl(enabled)
    end
end
addEventHandler("onClientElementStreamIn", root, elementStreamInHandler)

local function localPlayerVehicleEnter(vehicle, seat)
    if seat == 0 and isLocalPlayerPassive() then
        local enabled = not isVehicleArmed(vehicle)
        updateVehicleFireControl(enabled)
    end
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, localPlayerVehicleEnter)

local function localPlayerPassiveModeChangeHandler(enabled)
    for _, controlName in ipairs(AGGRESSIVE_CONTROLS_NAMES) do
        toggleControl(controlName, not enabled)
    end

    local vehicle = getPedDrivenVehicle(localPlayer)
    if enabled and vehicle and not isVehicleArmed(vehicle) then
        -- player is in an unarmed vehicle and is enabling passive; do nothing
    else
        updateVehicleFireControl(not enabled)
    end
end
addEventHandler(
    "onClientElementPassiveModeChange", localPlayer, localPlayerPassiveModeChangeHandler
)

local function localPlayerInteriorChangeHandler()
    if isLocalPlayerPassive() then
        -- workaround for interiors resource re-enabling player controls
        setTimer(localPlayerPassiveModeChangeHandler, 500, 1, true)
    end
end
addEventHandler(
    "onClientElementInteriorChange", localPlayer, localPlayerInteriorChangeHandler
)

local function pedDamageHandler(attacker)
    if isElementPassive(source) or (attacker and isElementPassive(attacker)) then
        -- passive peds/players can't damage any peds/players;
        -- passive peds/players can't be damaged
        cancelEvent()
    end
end
addEventHandler("onClientPedDamage", root, pedDamageHandler)
addEventHandler("onClientPlayerDamage", root, pedDamageHandler)

local function clientPlayerChokeHandler()
    if isLocalPlayerPassive() then
        -- passive players can't be choked
        cancelEvent()
    end
end
-- this event is only ever triggered for source == localPlayer
addEventHandler("onClientPlayerChoke", localPlayer, clientPlayerChokeHandler)

local function clientPlayerStealthKillHandler(victim)
    if isLocalPlayerPassive() or isElementPassive(victim) then
        -- passive players can't stealth kill any players;
        -- passive peds/players can't be stealth killed
        cancelEvent()
    end
end
-- this event is only ever triggered for source == localPlayer
addEventHandler("onClientPlayerStealthKill", localPlayer, clientPlayerStealthKillHandler)

local function pedHeliKilledHandler(victim)
    if isElementPassive(source) or isElementPassive(victim) then
        -- passive helis' blades can't kill any peds/players;
        -- passive peds/players can't be killed by heli blades
        cancelEvent()
    end
end
addEventHandler("onClientPedHeliKilled", root, pedHeliKilledHandler)
addEventHandler("onClientPlayerHeliKilled", root, pedHeliKilledHandler)

local function pedHitByWaterCannon(victim)
    if isElementPassive(source) or isElementPassive(victim) then
        -- passive vehicles can't hit any peds/players with their water cannons;
        -- passive peds/players can't be hit by any water cannons
        cancelEvent()
    end
end
addEventHandler("onClientPedHitByWaterCannon", root, pedHitByWaterCannon)
addEventHandler("onClientPlayerHitByWaterCannon", root, pedHitByWaterCannon)

local function vehicleDamageHandler(attacker)
    if isElementPassive(source) or (attacker and isElementPassive(attacker)) then
        -- passive peds/players can't damage any vehicles;
        -- passive vehicles can't be damaged (setVehicleDamageProof should take care of
        -- that, but just in case)
        cancelEvent()
    end
end
addEventHandler("onClientVehicleDamage", root, vehicleDamageHandler)

local function vehicleStartEnterHandler(ped, seat)
    local jackedPed = getVehicleOccupant(source, seat)

    if jackedPed and (isElementPassive(ped) or isElementPassive(jackedPed)) then
        -- passive peds/players can't jack any peds/players;
        -- passive peds/players can't be jacked
        cancelEvent()
    end
end
addEventHandler("onClientVehicleStartEnter", root, vehicleStartEnterHandler)

local function explosionHandler(x, y, z)
    if isLocalPlayerPassive() then
        local explosionDistance = getDistanceBetweenPoints3D(
            x, y, z, getElementPosition(localPlayer)
        )
        if explosionDistance < EXPLOSION_CANCEL_PROXIMITY then
            local explosionDimension = getElementDimension(source)
            local explosionInterior = getElementInterior(source)

            if explosionDimension == getElementDimension(localPlayer) and
                explosionInterior == getElementInterior(localPlayer) then
                -- explosion close to passive localPlayer
                cancelEvent()
            end
        end
    end
end
addEventHandler("onClientExplosion", root, explosionHandler)

local function resourceStartHandler(resource)
    if getResourceName(resource) == DRIVEBY_RESOURCE_NAME then
        triggerServerEvent("onPassivePlayerDrivebyResourceStart", localPlayer)
    end
end
addEventHandler("onClientResourceStart", root, resourceStartHandler)

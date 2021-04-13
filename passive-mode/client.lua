local passiveEnabled = false

local function toggleAggressionControls(enabled)
    for _, controlName in ipairs(AGGRESSION_CONTROLS) do
        toggleControl(controlName, enabled)
    end
end

local function setPlayerPassiveEnabled(player, enabled)
    if player == localPlayer then
        passiveEnabled = enabled
        print("CLIENT: now " .. (passiveEnabled and "" or "not ") .. "passive")
        toggleAggressionControls(not enabled)
    else
        -- pass
    end
end

local function setVehiclePassiveEnabled(vehicle, enabled)
    setVehicleDamageProof(vehicle, enabled)
end

local function setObjectPassiveEnabled(object, enabled)
    setObjectBreakable(object, not enabled)
    setElementCollisionsEnabled(object, not enabled)
end

local function passiveModeChangeHandler(enabled)
    if isElementStreamedIn(source) then
        local elementType = getElementType(source)
        if elementType == "player" then
            setPlayerPassiveEnabled(source, enabled)
        elseif elementType == "vehicle" then
            setVehiclePassiveEnabled(source, enabled)
        elseif elementType == "object" then
            setObjectPassiveEnabled(source, enabled)
        end
    end
end
addEventHandler("onClientElementPassiveModeChange", root, passiveModeChangeHandler)

local function elementStreamInHandler()
    -- nothing for now
end
addEventHandler("onClientElementStreamIn", root, elementStreamInHandler)

local function resourceStopHandler()
    if passiveEnabled then setPlayerPassiveEnabled(localPlayer, false) end
end
addEventHandler("onClientResourceStop", resourceRoot, resourceStopHandler)

-------------------------------
-- DISABLING AGGRESSION ACTS --
-------------------------------

function cancelEventHandler()
    cancelEvent()
end

if DISABLE_STEALTH_KILL then
    addEventHandler("onClientPlayerStealthKill", localPlayer, cancelEventHandler)
else
    local function handler(target)
        if passiveEnabled or isElementPassive(target) then cancelEvent() end
    end
    addEventHandler("onClientPlayerStealthKill", localPlayer, handler)
end

if DISABLE_HIT_BY_WATER_CANNON then
    addEventHandler("onClientPlayerHitByWaterCannon", root, cancelEventHandler)
else
    local function handler(target)
        if passiveEnabled or isElementPassive(target) then cancelEvent() end
    end
    addEventHandler("onClientPlayerHitByWaterCannon", root, handler)
end

if DISABLE_CHOKE then
    addEventHandler("onClientPlayerChoke", localPlayer, cancelEventHandler)
else
    local function handler(target)
        if passiveEnabled then cancelEvent() end
    end
    addEventHandler("onClientPlayerChoke", localPlayer, handler)
end

if DISABLE_HELI_KILLED then
    addEventHandler("onClientPlayerHeliKilled", root, cancelEventHandler)
else
    local function handler(killerVehicle)
        local driver = getVehicleOccupant(killerVehicle)
        if isElementPassive(source) or isElementPassive(killerVehicle) or
            isElementPassive(driver) then
            -- any element being passive dictates a cancelEvent
            cancelEvent()
        end
    end
    addEventHandler("onClientPlayerHeliKilled", root, handler)
end

local function localPlayerDamageHandler(attacker)
    if passiveEnabled then cancelEvent() end
end
addEventHandler("onClientPlayerDamage", localPlayer, localPlayerDamageHandler)

local function vehicleStartEnterHandler(ped, seat, door)
    if ped ~= localPlayer or not passiveEnabled then return false end

    local currentOccupant = getVehicleOccupant(source, seat)
    if currentOccupant then cancelEvent() end
end
addEventHandler("onClientPlayerVehicleStartEnter", root, vehicleStartEnterHandler)

local function explosionHandler(x, y, z, explosionType)
    -- case 1: explosion is from a vehicle, source is the player who syncs the vehicle;
    -- case 2: explosion was created directly by a player, source is that player
    if isExplosionVehicleType(explosionType) then
        -- case 1.
        if isPositionInASafeZone(x, y, z) then cancelEvent() end
    else
        -- case 2.
        if isElementPassive(source) or isPositionInASafeZone(x, y, z) then
            cancelEvent()
        end
    end
end
addEventHandler("onClientExplosion", root, explosionHandler)

function safelyDetonateProjectile(projectile)
    assertArgumentType(projectile, "projectile")

    setElementPosition(projectile, PROJECTILE_DETONATION_POSITION)
    setProjectileCounter(projectile, 0)
    destroyElement(projectile)

    return true
end

local function projectileCreationHandler(creator)
    if isElementPassive(creator) then safelyDetonateProjectile(source) end
end
addEventHandler("onClientProjectileCreation", root, projectileCreationHandler)

-- local function safeZoneEnterHandler(element)
--     print(inspect(element))
--     if getElementType(element) ~= "projectile" then return false end

--     safelyDetonateProjectile(element)
-- end
-- addEventHandler("onClientSafeZoneEnter", root, safeZoneEnterHandler)

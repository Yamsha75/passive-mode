local function cancelEventHandler()
    cancelEvent()
end

local function isExplosionVehicleType(explosionType)
    assertArgumentType(explosionType, "number")

    return VEHICLE_EXPLOSION_TYPES[explosionType] ~= nil
end

local function isPositionInASafeZone(x, y, z)
    assertArgumentType(x, "number", 1)
    assertArgumentType(y, "number", 2)
    assertArgumentType(z, "number", 3)

    for _, safezone in ipairs(getElementsByType(SAFEZONE)) do
        if isInsideColShape(getElementParent(safezone), x, y, z) then return true end
    end

    return false
end

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

    setElementPosition(projectile, unpack(PROJECTILE_DETONATION_POSITION))
    setProjectileCounter(projectile, 0)
    destroyElement(projectile)

    return true
end

local function projectileCreationHandler(creator)
    if isElementPassive(creator) then safelyDetonateProjectile(source) end
end
addEventHandler("onClientProjectileCreation", root, projectileCreationHandler)

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

local function localPlayerPassiveModeChangeHandler(enabled)
    for _, controlName in ipairs(AGGRESSION_CONTROLS) do
        toggleControl(controlName, not enabled)
    end
end
addEventHandler("onClientElementPassiveModeChange", localPlayer,
    localPlayerPassiveModeChangeHandler)

local function resourceStopHandler()
    if isLocalPlayerPassive() then localPlayerPassiveModeChangeHandler(false) end
end
addEventHandler("onClientResourceStop", resourceRoot, resourceStopHandler)

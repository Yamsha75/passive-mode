local VEHICLE_EXPLOSION_TYPES = {
    [4] = "Car",
    [5] = "Car Quick",
    [6] = "Boat",
    [7] = "Heli",
}

local function isExplosionVehicleType(explosionType)
    assertArgumentType(explosionType, "number")

    return VEHICLE_EXPLOSION_TYPES[explosionType] ~= nil
end

local function explosionHandler(x, y, z, explosionType)
    local interior = getElementInterior(source)
    local dimension = getElementDimension(source)

    if isExplosionVehicleType(explosionType) then
        -- explosion is from a vehicle, source is the player who syncs the vehicle
        if isPositionInsideAnySafezone(x, y, z, interior, dimension) then
            cancelEvent()
        end
    else
        -- explosion was created directly by a player, source is that player
        if isElementPassive(source) or
            isPositionInsideAnySafezone(x, y, z, interior, dimension) then

            cancelEvent()
        end
    end
end
addEventHandler("onClientExplosion", root, explosionHandler)

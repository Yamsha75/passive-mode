function isElementPassive(element)
    return getElementData(element, "isPassive") == true
end

function canElementBePassive(element)
    return getElementData(element, "passiveDisabled") ~= true
end

function canElementBeNotPassive(element)
    return getElementData(element, "passiveForced") ~= true
end

function isExplosionVehicleType(explosionType)
    assertArgumentType(explosionType, "number")

    return VEHICLE_EXPLOSION_TYPES[explosionType] ~= nil
end

function isPositionInASafeZone(x, y, z)
    assertArgumentType(x, "number", 1)
    assertArgumentType(y, "number", 2)
    assertArgumentType(z, "number", 3)

    for _, safezone in ipairs(getElementsByType(SAFEZONE)) do
        if isInsideColShape(getElementParent(safezone), x, y, z) then return true end
    end

    return false
end

local function playerDamageHandler(attacker)
    if not attacker then return end

    updatePlayerCooldown(attacker, getAggressionCooldown(1))
end
addEventHandler("onPlayerDamage", root, playerDamageHandler)

local function pedWastedHandler(_, responsibleElement, damageType)
    if not responsibleElement then return end

    local elementType = getElementType(responsibleElement)

    if elementType == "player" then
        updatePlayerCooldown(killer, getAggressionCooldown(2))
    elseif elementType == "vehicle" then
        local driver = getVehicleOccupant(responsibleElement)
        if driver and getElementType(driver) == "player" and damageType ~= 54 then
            -- damageType == 54 means a player has died by falling onto a vehicle,
            -- which is not considered an aggressive act by the driver
            updatePlayerCooldown(killer, getAggressionCooldown(2))
        end
    end
end
addEventHandler("onPedWasted", root, pedWastedHandler)
addEventHandler("onPlayerWasted", root, pedWastedHandler)

local function playerWeaponFireHandler()
    updatePlayerCooldown(source, getAggressionCooldown(0))
end
addEventHandler("onPlayerWeaponFire", root, playerWeaponFireHandler)

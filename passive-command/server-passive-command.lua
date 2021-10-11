local PASSIVE_MODE_COMMAND = "pasywny"
local COMMAND_COOLDOWN = 5 -- seconds

local AGGRESSION_LEVEL_COOLDOWNS = {[0] = 10, [1] = 30, [2] = 60}

-- timestamps at which each player can use the command
-- passiveCooldownTimestamps[<player>] = <timestamp:integer>
local passiveCooldownTimestamps = createElementKeyedTable()

function getCooldownTimeLeft(player)
    assertArgumentType(player, "player")

    local cooldownTimestamp = passiveCooldownTimestamps[player] or 0

    return cooldownTimestamp - getNowTimestamp()
end

function hasPlayerCooldownExpired(player)
    assertArgumentType(player, "player")

    return getCooldownTimeLeft(player) <= 0
end

function getAggressionCooldown(aggressionLevel)
    assertArgumentType(aggressionLevel, "number")

    return AGGRESSION_LEVEL_COOLDOWNS[aggressionLevel]
end

function updatePlayerCooldown(player, cooldownSeconds)
    assertArgumentType(player, "player", 1)
    assertArgumentType(cooldownSeconds, "number", 2)

    local oldTimestamp = passiveCooldownTimestamps[player] or 0
    local newTimestamp = getNowTimestamp() + cooldownSeconds

    if newTimestamp > oldTimestamp then
        passiveCooldownTimestamps[player] = newTimestamp
        return true
    end

    return false
end

local function passiveCommandHandler(player)
    if hasPlayerCooldownExpired(player) then
        local enabled = not isPlayerPassiveEnabled(player)

        if enabled then
            outputChatBox("Włączono tryb pasywny", player)
        else
            outputChatBox("Wyłączono tryb pasywny", player)
        end

        trySetPlayerPassiveEnabled(player, enabled)
        updatePlayerCooldown(player, COMMAND_COOLDOWN)
    else
        local timeLeft = getCooldownTimeLeft(player)
        local message = string.format(
            "Musisz zaczekać %s, żeby przełączyć tryb pasywny!",
                formatSeconds(timeLeft)
        )
        outputChatBox(message, player, 255, 0, 0)
    end
end
addCommandHandler(PASSIVE_MODE_COMMAND, passiveCommandHandler)

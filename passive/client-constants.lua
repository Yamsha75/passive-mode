-- distance from passive localPlayer below which explosions are cancelled
EXPLOSION_CANCEL_PROXIMITY = 7.0

-- player controls which are disabled in passive mode
AGGRESSIVE_CONTROLS_NAMES = {
    "action",
    "aim_weapon",
    "fire",
    "vehicle_secondary_fire",
}

-- this control is handled separately to enable bike jumping and nitro while passive
VEHICLE_FIRE_CONTROL_NAME = "vehicle_fire"

-- vehicles with weapons or water cannons
ARMED_VEHICLES = {
    [407] = true, -- Fire Truck
    [425] = true, -- Hunter
    [430] = true, -- Predator
    [432] = true, -- Rhino
    [447] = true, -- Seasparrow
    [464] = true, -- RC Baron
    [476] = true, -- Rustler
    [601] = true, -- S.W.A.T.
}

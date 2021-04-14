CLIENTSIDE = isElement(localPlayer)
SERVERSIDE = not CLIENTSIDE

SAFEZONE = "safe-zone"

COLLISION_ELEMENT_TYPES = {"vehicle", "ped", "player"}
PASSIVE_ELEMENT_TYPES = getSetFromList(COLLISION_ELEMENT_TYPES)

AGGRESSION_CONTROLS = {
    "action",
    "aim_weapon",
    "fire",
    "vehicle_fire",
    "vehicle_secondary_fire",
}

VEHICLE_EXPLOSION_TYPES = {[4] = "Car", [5] = "Car Quick", [6] = "Boat", [7] = "Heli"}
PROJECTILE_DETONATION_POSITION = {0, 0, -9000}
PROJECTILE_DUMMY_OBJECT_MODEL = 2709

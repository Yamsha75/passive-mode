function isVehicleArmed(vehicle)
    assertArgumentType(vehicle, "vehicle")

    return ARMED_VEHICLES[getElementModel(vehicle)] == true
end

local ATTACH_REQUEST_KEY = "attached-to-passive-element"
local DRIVER_REQUEST_KEY = "driven-by-passive-element"
local OCCUPANT_REQUEST_KEY = "occupying-passive-vehicle"
local TOWING_REQUEST_KEY = "towed-by-passive-element"

local function elementPassiveModePreChangeHandler(enabled)
    if enabled then
        -- no special cases for enabling passive mode
        return
    end

    local elementType = getElementType(source)

    if elementType == "vehicle" then
        local driver = getVehicleOccupant(source)
        if driver and doesPassiveRequestExist(driver, OCCUPANT_REQUEST_KEY) then
            for key, _ in pairs(getPassiveRequests(driver)) do
                if key ~= OCCUPANT_REQUEST_KEY then
                    -- the driver will lose passive mode request inherited from the
                    -- vehicle, but they also have other passive mode requests, so they
                    -- will remain passive and now the vehicle will inherit passive from
                    -- the driver
                    cancelEvent()
                    removePassiveRequest(driver, OCCUPANT_REQUEST_KEY)
                    createPassiveRequest(source, DRIVER_REQUEST_KEY)
                    break
                end
            end
        end
    elseif elementType == "ped" or elementType == "player" then
        local vehicle = getPedDrivenVehicle(source)
        if vehicle and doesPassiveRequestExist(vehicle, DRIVER_REQUEST_KEY) then
            for key, _ in pairs(getPassiveRequests(vehicle)) do
                if key ~= DRIVER_REQUEST_KEY then
                    -- the vehicle will lose passive mode request inherited from the
                    -- driver, but it also has other passive mode requests, so it
                    -- will remain passive and now the driver will inherit passive
                    -- from the vehicle
                    cancelEvent()
                    removePassiveRequest(vehicle, DRIVER_REQUEST_KEY)
                    createPassiveRequest(source, OCCUPANT_REQUEST_KEY)
                    break
                end
            end
        end
    end
end
addEventHandler(
    "onElementPassiveModePreChange", root, elementPassiveModePreChangeHandler
)

local function elementPassiveModeChangeHandler(enabled)
    local elementType = getElementType(source)

    -- attached elements inheritance
    if enabled then
        for _, element in ipairs(getAttachedElements(source)) do
            if canElementTypeBePassive(getElementType(element)) then
                createPassiveRequest(element, ATTACH_REQUEST_KEY)
            end
        end
    else
        for _, element in ipairs(getAttachedElements(source)) do
            if doesPassiveRequestExist(element, ATTACH_REQUEST_KEY) then
                removePassiveRequest(element, ATTACH_REQUEST_KEY)
            end
        end
    end

    if elementType == "vehicle" then
        -- vehicle occupant inheritance
        local occupants = getVehicleOccupants(source)
        if occupants then
            if enabled then
                -- occupants should now inherit passive from the vehicle
                for seat, occupant in pairs(occupants) do
                    if seat == 0 and doesPassiveRequestExist(source, DRIVER_REQUEST_KEY) then
                        -- skip the driver from whom the vehicle is inheriting passive
                    else
                        createPassiveRequest(occupant, OCCUPANT_REQUEST_KEY)
                    end
                end
            else
                -- occupants should now stop inheriting passive from the vehicle
                for seat, occupant in pairs(occupants) do
                    if doesPassiveRequestExist(occupant, OCCUPANT_REQUEST_KEY) then
                        removePassiveRequesst(occupant, OCCUPANT_REQUEST_KEY)
                    end
                end
            end
        end

        -- towed vehicle inheritance
        local towedVehicle = getVehicleTowedByVehicle(source)
        if towedVehicle then
            if enabled then
                createPassiveRequest(towedVehicle, TOWING_REQUEST_KEY)
            elseif doesPassiveRequestExist(towedVehicle, TOWING_REQUEST_KEY) then
                removePassiveRequest(towedVehicle, TOWING_REQUEST_KEY)
            end
        end
    elseif elementType == "ped" or elementType == "player" then
        -- vehicle driver inheritance
        local vehicle = getPedDrivenVehicle(source)
        if vehicle then
            if enabled then
                -- the vehicle should now inherit passive from the driver, unless the
                -- driver is inheriting passive mode from the vehicle
                if not doesPassiveRequestExist(source, OCCUPANT_REQUEST_KEY) then
                    createPassiveRequest(vehicle, DRIVER_REQUEST_KEY)
                end
            else
                -- the vehicle should now stop inheriting passive from the driver
                if doesPassiveRequestExist(vehicle, DRIVER_REQUEST_KEY) then
                    removePassiveRequest(vehicle, DRIVER_REQUEST_KEY)
                end
            end
        end
    end
end
addEventHandler("onElementPassiveModeChange", root, elementPassiveModeChangeHandler)

local function vehicleEnterHandler(ped, seat)
    if seat == 0 and isElementPassive(ped) then
        -- passive ped/player entering driver seat - vehicle inherits passive mode
        createPassiveRequest(source, DRIVER_REQUEST_KEY)
    elseif isElementPassive(source) then
        -- ped/player entering a passive vehicle - ped/player inherits passive mode
        createPassiveRequest(ped, OCCUPANT_REQUEST_KEY)
    end
end
addEventHandler("onVehicleEnter", root, vehicleEnterHandler)

local function vehicleExitHandler(ped, seat)
    if seat == 0 and doesPassiveRequestExist(source, DRIVER_REQUEST_KEY) then
        -- vehicle stops inheriting passive mode from passive driver
        removePassiveRequest(source, DRIVER_REQUEST_KEY)
    elseif doesPassiveRequestExist(ped, OCCUPANT_REQUEST_KEY) then
        -- ped/player stops inheriting passive mode from passive vehicle
        removePassiveRequest(ped, OCCUPANT_REQUEST_KEY)
    end
end
addEventHandler("onVehicleExit", root, vehicleExitHandler)

local function pedWastedHandler()
    local vehicle = getPedOccupiedVehicle(source)

    if not vehicle then return end

    if getPedOccupiedVehicleSeat(source) == 0 and
        doesPassiveRequestExist(vehicle, DRIVER_REQUEST_KEY) then
        -- vehicle stops inheriting passive mode from passive driver
        removePassiveRequest(vehicle, DRIVER_REQUEST_KEY)
    elseif doesPassiveRequestExist(source, OCCUPANT_REQUEST_KEY) then
        -- ped/player stops inheriting passive mode from passive vehicle
        removePassiveRequest(source, OCCUPANT_REQUEST_KEY)
    end
end
addEventHandler("onPedWasted", root, pedWastedHandler)
addEventHandler("onPlayerWasted", root, pedWastedHandler)

local function trailerAttachHandler(towingVehicle)
    -- source is towed by towingVehicle
    if isElementPassive(towingVehicle) then
        createPassiveRequest(source, TOWING_REQUEST_KEY)
    end
end
addEventHandler("onTrailerAttach", root, trailerAttachHandler)

local function trailerDetachHandler(towingVehicle)
    -- source is towed by towingVehicle
    if doesPassiveRequestExist(source, TOWING_REQUEST_KEY) then
        removePassiveRequest(source, TOWING_REQUEST_KEY)
    end
end
addEventHandler("onTrailerDetach", root, trailerDetachHandler)

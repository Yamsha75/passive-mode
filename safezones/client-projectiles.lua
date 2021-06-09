-- projectiles don't trigger onClientColShapeHit, so we're using dummy objects
local PROJECTILE_DUMMY_OBJECT_MODEL = 2709

-- projectileDummies[<dummy:object>] = <projectile>
local projectileDummies = {}

local function safelyDetonateProjectile(projectile)
    assertArgumentType(projectile, "projectile")

    setElementPosition(projectile, 0, 0, -9001)
    destroyElement(projectile)

    return true
end

local function projectileDummySafezoneEnterHandler(safezone, matchingDimension)
    if not matchingDimension then return end

    local projectile = projectileDummies[source]
    if isElement(projectile) then safelyDetonateProjectile(projectile) end
end

local function projectileCreationHandler(creator)
    if isPlayerPassiveModeEnabled(creator) then
        safelyDetonateProjectile(source)
    else
        local dummyObject = createObject(PROJECTILE_DUMMY_OBJECT_MODEL, 0, 0, 0)

        projectileDummies[dummyObject] = source

        setElementParent(dummyObject, source)
        setElementInterior(dummyObject, getElementInterior(source))
        setElementDimension(dummyObject, getElementDimension(source))

        setElementAlpha(dummyObject, 0)
        setElementCollisionsEnabled(dummyObject, false)

        addEventHandler(
            "onClientElementSafezoneEnter", dummyObject,
                projectileDummySafezoneEnterHandler
        )
    end
end
addEventHandler("onClientProjectileCreation", root, projectileCreationHandler)

local function moveProjectileDummyObjects()
    -- temp list for dummy objects to delete
    local dummiesToDestroy = {}
    local count = 0

    -- move each dummy object to its projectile's position, because attaching to
    -- projectiles doesn't work
    for dummyObject, projectile in pairs(projectileDummies) do
        if isElement(projectile) then
            setElementPosition(dummyObject, getElementPosition(projectile))
        else
            -- projectile is destroyed; flag dummy object for deletion
            count = count + 1
            dummiesToDestroy[count] = dummyObject
        end
    end

    -- destroy flagged dummy objects
    for i = 1, count do
        local dummyObject = dummiesToDestroy[i]
        projectileDummies[dummyObject] = nil
        destroyElement(dummyObject)
    end
end
addEventHandler("onClientRender", root, moveProjectileDummyObjects)

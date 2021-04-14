local projectileDummies = createElementKeyedTable()

local function projectileDummySafeZoneEnterHandler(safezone)
    local projectile = projectileDummies[source]
    if projectile then safelyDetonateProjectile(projectile) end
end

function safelyDetonateProjectile(projectile)
    assertArgumentType(projectile, "projectile")

    setElementPosition(projectile, unpack(PROJECTILE_DETONATION_POSITION))
    destroyElement(projectile)

    return true
end

local function projectileCreationHandler(creator)
    if isElementPassive(creator) then
        safelyDetonateProjectile(source)
    else
        local dummyObject = createObject(PROJECTILE_DUMMY_OBJECT_MODEL, 0, 0, 0)
        setElementCollisionsEnabled(dummyObject, false)
        setElementAlpha(dummyObject, 0)
        setElementParent(dummyObject, source)

        projectileDummies[dummyObject] = source

        addEventHandler("onClientElementSafeZoneEnter", dummyObject,
            projectileDummySafeZoneEnterHandler)
    end
end
addEventHandler("onClientProjectileCreation", root, projectileCreationHandler)

local function moveDummyObjects()
    for dummyObject, projectile in pairs(projectileDummies) do
        if isElement(dummyObject) and isElement(projectile) then
            setElementPosition(dummyObject, getElementPosition(projectile))
        else
            destroyElement(dummyObject)
        end
    end
end
addEventHandler("onClientRender", root, moveDummyObjects)

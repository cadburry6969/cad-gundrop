local pilot, aircraft, parachute, crate, soundID

function OpenCrate(netId)
    if lib.progressBar({
        duration = math.random(4000, 6000),
        label = Config.Lang["collect_items"],
        useWhileDead = false,
        canCancel = true,
        disable = {
            combat = true,
            move = true,
            car = true,
        }
    }) then
        TriggerServerEvent("cad-gundrop:server:openCrate", netId)
    end
end

function CrateDrop(planeSpawnDistance, dropCoords)
    CreateThread(function()
        Notify(Config.Lang["pilot_dropping_soon"], "success") -- Notify the pilot that we are preparing the crate with the plane
        SetTimeout(Config.TimeUntilDrop * 60 * 1000, function()
            for i = 1, #Config.LoadModels do
                RequestModel(GetHashKey(Config.LoadModels[i]))
                while not HasModelLoaded(GetHashKey(Config.LoadModels[i])) do
                    Wait(0)
                end
            end
            RequestAnimDict(Config.ParachuteModel)
            while not HasAnimDictLoaded(Config.ParachuteModel) do
                Wait(0)
            end
            RequestWeaponAsset(GetHashKey(Config.FlareName))
            while not HasWeaponAssetLoaded(GetHashKey(Config.FlareName)) do
                Wait(0)
            end
            local rHeading = math.random(0, 360) + 0.0
            planeSpawnDistance = (planeSpawnDistance and tonumber(planeSpawnDistance) + 0.0) or 400.0
            local theta = (rHeading / 180.0) * 3.14
            local rPlaneSpawn = vector3(dropCoords.x, dropCoords.y, dropCoords.z) - vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance, -500.0)
            local dx = dropCoords.x - rPlaneSpawn.x
            local dy = dropCoords.y - rPlaneSpawn.y
            local heading = GetHeadingFromVector_2d(dx, dy)
            aircraft = CreateVehicle(GetHashKey(Config.PlaneModel), rPlaneSpawn.x, rPlaneSpawn.y, rPlaneSpawn.z, heading, true, true)
            SetEntityHeading(aircraft, heading)
            SetVehicleDoorsLocked(aircraft, 2)
            SetEntityDynamic(aircraft, true)
            ActivatePhysics(aircraft)
            SetVehicleForwardSpeed(aircraft, 60.0)
            SetHeliBladesFullSpeed(aircraft)
            SetVehicleEngineOn(aircraft, true, true, false)
            ControlLandingGear(aircraft, 3)
            OpenBombBayDoors(aircraft)
            SetEntityProofs(aircraft, true, false, true, false, false, false, false, false)
            pilot = CreatePedInsideVehicle(aircraft, 1, GetHashKey(Config.PlanePilotModel), -1, true, true)
            SetBlockingOfNonTemporaryEvents(pilot, true)
            SetPedRandomComponentVariation(pilot, false)
            SetPedKeepTask(pilot, true)
            SetPlaneMinHeightAboveTerrain(aircraft, 50)
            TaskVehicleDriveToCoord(pilot, aircraft, vector3(dropCoords.x, dropCoords.y, dropCoords.z) + vector3(0.0, 0.0, 500.0), 60.0, 0, GetHashKey(Config.PlaneModel), 262144, 15.0, -1.0) -- to the dropsite, could be replaced with a task sequence
            local droparea = vector2(dropCoords.x, dropCoords.y)
            local planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y)
            while not IsEntityDead(pilot) and #(planeLocation - droparea) > 5.0 do
                Wait(100)
                planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y)
            end
            if IsEntityDead(pilot) then
                Notify(Config.Lang["pilot_crashed"], "error") -- Notify the pilot that the plane has crashed
                return
            end
            TaskVehicleDriveToCoord(pilot, aircraft, 0.0, 0.0, 500.0, 60.0, 0, GetHashKey(Config.PlaneModel), 262144, -1.0, -1.0)
            SetEntityAsNoLongerNeeded(pilot)
            SetEntityAsNoLongerNeeded(aircraft)
            Notify(Config.Lang["crate_dropping"], "success") -- Notify the pilot that we are preparing the crate with the plane
            local crateSpawn = vector3(dropCoords.x, dropCoords.y, GetEntityCoords(aircraft).z - 5.0)
            crate = CreateObject(GetHashKey(Config.CrateModel), crateSpawn, true, true, true)
            SetEntityLodDist(crate, 1000)
            ActivatePhysics(crate)
            SetDamping(crate, 2, 0.1)
            SetEntityVelocity(crate, 0.0, 0.0, -0.2)
            parachute = CreateObject(GetHashKey(Config.ParachuteModel), crateSpawn, true, true, true)
            SetEntityLodDist(parachute, 1000)
            SetEntityVelocity(parachute, 0.0, 0.0, -0.2)
            AttachEntityToEntity(parachute, crate, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            -- Sound
            soundID = GetSoundId()
            PlaySoundFromEntity(soundID, "Crate_Beeps", parachute, "MP_CRATE_DROP_SOUNDS", true, 0)
            -- Checks when the crate is at the dropsite and delete the parachute
            local parachuteCoords = vector3(GetEntityCoords(parachute))
            while #(parachuteCoords - dropCoords) > 5.0 do
                Wait(100)
                parachuteCoords = vector3(GetEntityCoords(parachute))
            end
            ShootSingleBulletBetweenCoords(dropCoords, dropCoords - vector3(0.0001, 0.0001, 0.0001), 0, false, GetHashKey(Config.FlareName), 0, true, false, -1.0)
            DetachEntity(parachute, true, true)
            DeleteEntity(parachute)
            StopSound(soundID)
            ReleaseSoundId(soundID)
            for i = 1, #Config.LoadModels do
                Wait(0)
                SetModelAsNoLongerNeeded(GetHashKey(Config.LoadModels[i]))
            end
            RemoveWeaponAsset(GetHashKey(Config.FlareName))
            TriggerServerEvent("cad-gundrop:server:showTarget", NetworkGetNetworkIdFromEntity(crate))
        end)
    end)
end

RegisterNetEvent("cad-gundrop:client:showTarget", function(netId)
    if Config.Target == 'ox_target' then
        exports.ox_target:addEntity(netId, {
            {
                name = 'cad:drops:opencrate',
                label = Config.TargetLabel,
                icon = Config.TargetIcon,
                distance = 1.5,
                onSelect = function()
                    OpenCrate(netId)
                end,
            }
        })
    else
        local _crate = NetworkGetEntityFromNetworkId(netId)
        exports[Config.Target]:AddTargetEntity(_crate, {
            options = {
                {
                    icon = Config.TargetIcon,
                    label = Config.TargetLabel,
                    action = function()
                        OpenCrate(netId)
                    end,
                }
            },
            distance = 1.5,
        })
    end
end)

RegisterNetEvent("cad-gundrop:client:removeTarget", function(netId)
    if Config.Target == 'ox_target' then
        exports.ox_target:removeEntity(netId, 'cad:drops:opencrate')
    else
        local _crate = NetworkGetEntityFromNetworkId(netId)
        exports[Config.Target]:RemoveTargetEntity(_crate, Config.TargetLabel)
    end
end)

RegisterNetEvent("cad-gundrop:client:startDrop", function(planeSpawnDistance, dropCoords)
    CreateThread(function()
        if dropCoords.x and dropCoords.y and dropCoords.z and tonumber(dropCoords.x) and tonumber(dropCoords.y) and tonumber(dropCoords.z) then
        else
            dropCoords = { 0.0, 0.0, 72.0 }
        end
        RequestWeaponAsset(GetHashKey(Config.FlareName))
        while not HasWeaponAssetLoaded(GetHashKey(Config.FlareName)) do
            Wait(0)
        end
        ShootSingleBulletBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(PlayerPedId()) - vector3(0.0001, 0.0001, 0.0001), 0, false, GetHashKey(Config.FlareName), 0, true, false, -1.0)
        local ray = StartShapeTestRay(vector3(dropCoords.x, dropCoords.y, dropCoords.z) + vector3(0.0, 0.0, 500.0), vector3(dropCoords.x, dropCoords.y, dropCoords.z), -1, -1, 0)
        local _, hit, impactCoords = GetShapeTestResult(ray)
        if hit == 0 or (hit == 1 and #(vector3(dropCoords.x, dropCoords.y, dropCoords.z) - vector3(impactCoords)) < 10.0) then
            CrateDrop(planeSpawnDistance, dropCoords)
        else
            return
        end
    end)
end)

RegisterNetEvent("cad-gundrop:client:createDrop", function()
    local playerCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 10.0, 0.0)
    Notify(Config.Lang["contacted_mafia"], "success")
    Notify(Config.Lang["pilot_contact"], "success")
    PoliceAlert()
    TriggerEvent("cad-gundrop:client:startDrop", Config.PlaneSpawnDistance, vector3(playerCoords.x, playerCoords.y, playerCoords.z))
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        SetEntityAsMissionEntity(pilot, false, true)
        DeleteEntity(pilot)
        SetEntityAsMissionEntity(aircraft, false, true)
        DeleteEntity(aircraft)
        DeleteEntity(parachute)
        DeleteEntity(crate)
        StopSound(soundID)
        ReleaseSoundId(soundID)
        for i = 1, #Config.LoadModels do
            Wait(0)
            SetModelAsNoLongerNeeded(GetHashKey(Config.LoadModels[i]))
        end
    end
end)

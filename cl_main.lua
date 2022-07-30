local QBCore = exports[Config.CoreName]:GetCoreObject()

local pilot, aircraft, parachute, crate, soundID

-- reward on open crate
function OpenCrate(crate, item, amount)
    TriggerServerEvent("cad-gundrop:server:ItemHandler", "add", item, amount)                           
    exports[Config.TargetName]:RemoveTargetEntity(crate, Config.TargetLabel)
    DeleteEntity(crate)  
    QBCore.Functions.Notify(Config.Lang["item_recieved"].." "..amount..'x '..item)
end

-- Crate Drop function
function CrateDrop(item, amount, planeSpawnDistance, dropCoords)
    CreateThread(function()
        QBCore.Functions.Notify(Config.Lang["pilot_dropping_soon"], "success")   -- Notify the pilot that we are preparing the crate with the plane
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
            local planeSpawnDistance = (planeSpawnDistance and tonumber(planeSpawnDistance) + 0.0) or 400.0
            local theta = (rHeading / 180.0) * 3.14
            local rPlaneSpawn = vector3(dropCoords.x, dropCoords.y, dropCoords.z) - vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance, -500.0)
            local dx = dropCoords.x - rPlaneSpawn.x
            local dy = dropCoords.y - rPlaneSpawn.y
            local heading = GetHeadingFromVector_2d(dx, dy)
            aircraft = CreateVehicle(GetHashKey(Config.PlaneModel), rPlaneSpawn, heading, true, true)
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
                QBCore.Functions.Notify(Config.Lang["pilot_crashed"], "error") -- Notify the pilot that the plane has crashed
                return
            end
            TaskVehicleDriveToCoord(pilot, aircraft, 0.0, 0.0, 500.0, 60.0, 0, GetHashKey(Config.PlaneModel), 262144, -1.0, -1.0)
            SetEntityAsNoLongerNeeded(pilot) 
            SetEntityAsNoLongerNeeded(aircraft)      
            QBCore.Functions.Notify(Config.Lang["crate_dropping"], "success")   -- Notify the pilot that we are preparing the crate with the plane
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
            exports[Config.TargetName]:AddTargetEntity(crate, {
                options = {
                {           
                    icon = Config.TargetIcon,
                    label = Config.TargetLabel,
                    action = function(entity)                      
                        OpenCrate(crate, item, amount)                 
                    end,      
                }
                },
                distance = 2.5,
            })
        end)  
    end)
end

-- notify police functions
function PoliceAlert()
    -- put your own dispatch here and comment the below event
    TriggerServerEvent('police:server:policeAlert', 'Suspicious activity')
end

-- Give random item from given list of the item used
function GetRandomItemData(item)
    if Config.ItemDrops[item] then
        local Items = Config.ItemDrops[item]
        local randomItem = Items[math.random(#Items)]
        return randomItem["name"], randomItem["amount"]
    end    
end

-- Start the AirDrop
RegisterNetEvent("cad-gundrop:client:StartDrop", function(item, amount, roofCheck, planeSpawnDistance, dropCoords)
    CreateThread(function()          
        if dropCoords.x and dropCoords.y and dropCoords.z and tonumber(dropCoords.x) and tonumber(dropCoords.y) and tonumber(dropCoords.z) then            
        else
            dropCoords = {0.0, 0.0, 72.0}            
        end
        RequestWeaponAsset(GetHashKey(Config.FlareName))
        while not HasWeaponAssetLoaded(GetHashKey(Config.FlareName)) do
            Wait(0)
        end
        ShootSingleBulletBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(PlayerPedId()) - vector3(0.0001, 0.0001, 0.0001), 0, false, GetHashKey(Config.FlareName), 0, true, false, -1.0)
        if roofCheck and roofCheck ~= "false" then
            local ray = StartShapeTestRay(vector3(dropCoords.x, dropCoords.y, dropCoords.z) + vector3(0.0, 0.0, 500.0), vector3(dropCoords.x, dropCoords.y, dropCoords.z), -1, -1, 0)
            local _, hit, impactCoords = GetShapeTestResult(ray)
            if hit == 0 or (hit == 1 and #(vector3(dropCoords.x, dropCoords.y, dropCoords.z) - vector3(impactCoords)) < 10.0) then             
                CrateDrop(item, amount, planeSpawnDistance, dropCoords)
            else            
                return
            end
        else            
            CrateDrop(item, amount, planeSpawnDistance, dropCoords)
        end

    end)
end)

-- Create the AirDrop
RegisterNetEvent("cad-gundrop:client:CreateDrop", function(useditem, roofCheck, planeSpawnDistance)
    local playerCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 10.0, 0.0)        
    local item, amount = GetRandomItemData(useditem)
    QBCore.Functions.TriggerCallback("cad-gundrop:server:getCops", function(CurrentCops)
        if CurrentCops >= Config.RequiredCops then            
            QBCore.Functions.Notify(Config.Lang["contacted_mafia"], "success")
            QBCore.Functions.Notify(Config.Lang["pilot_contact"], "success")
            PoliceAlert()    
            TriggerServerEvent("cad-gundrop:server:ItemHandler", "remove", useditem, 1)
            TriggerEvent("cad-gundrop:client:StartDrop", item, amount, roofCheck or false, planeSpawnDistance or 400.0, vector3(playerCoords.x, playerCoords.y, playerCoords.z))                
        else
            QBCore.Functions.Notify(Config.Lang["no_cops"], "error")
        end    
    end)
end)

-- On resource stop do things
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        SetEntityAsMissionEntity(pilot, false, true)
        DeleteEntity(pilot)
        SetEntityAsMissionEntity(aircraft, false, true)
        DeleteEntity(aircraft)
        DeleteEntity(parachute)
        DeleteEntity(crate)
        RemovePickup(pickup)
        RemoveBlip(blip)
        StopSound(soundID)
        ReleaseSoundId(soundID)
        for i = 1, #Config.LoadModels do
            Wait(0)
            SetModelAsNoLongerNeeded(GetHashKey(Config.LoadModels[i]))
        end
    end
end)

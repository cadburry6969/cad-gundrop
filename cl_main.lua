local QBCore = exports['qb-core']:GetCoreObject()
local pilot, aircraft, parachute, crate, pickup, blip, soundID
local requiredModels = {"p_cargo_chute_s", "ex_prop_adv_case_sm", "cuban800", "s_m_m_pilot_02", "prop_box_wood02a_pu"}
local RequiredCops = 4

-- Create the AirDrop
RegisterNetEvent("cad-gundrop:client:CreateDrop")
AddEventHandler("cad-gundrop:client:CreateDrop", function(weapon, ammo, roofCheck, planeSpawnDistance)
    local playerCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 10.0, 0.0)        
    QBCore.Functions.TriggerCallback("cad-gundrop:server:getCops", function(CurrentCops)
        if CurrentCops >= RequiredCops then
            TriggerEvent("cad-gundrop:client:StartDrop", weapon, tonumber(ammo), roofCheck or false, planeSpawnDistance or 400.0, {["x"] = playerCoords.x, ["y"] = playerCoords.y, ["z"] = playerCoords.z})    
            QBCore.Functions.Notify("You Have Contacted With Russian Mafia")
            QBCore.Functions.Notify("After few minutes pilot will contact you")
            NotifyPoliceFunction()    
            if weapon == "WEAPON_CARBINERIFLE" or weapon == "WEAPON_ADVANCEDRIFLE" then
                TriggerServerEvent("cad-gundrop:server:RemoveItem", "goldenphone", 1)
            elseif weapon == "WEAPON_ASSAULTRIFLE" then
                TriggerServerEvent("cad-gundrop:server:RemoveItem", "redphone", 1)
            elseif weapon == "WEAPON_ASSAULTSMG" then
                TriggerServerEvent("cad-gundrop:server:RemoveItem", "greenphone", 1)
            end
        else
            QBCore.Functions.Notify("Not enough cops")
        end    
    end)
end)

-- Start the AirDrop
RegisterNetEvent("cad-gundrop:client:StartDrop")
AddEventHandler("cad-gundrop:client:StartDrop", function(weapon, ammo, roofCheck, planeSpawnDistance, dropCoords)
    Citizen.CreateThread(function()          
        local ammo = (ammo and tonumber(ammo)) or 250
        if ammo > 9999 then
            ammo = 9999
        elseif ammo < -1 then
            ammo = -1
        end
        if dropCoords.x and dropCoords.y and dropCoords.z and tonumber(dropCoords.x) and tonumber(dropCoords.y) and tonumber(dropCoords.z) then            
        else
            dropCoords = {0.0, 0.0, 72.0}            
        end
        RequestWeaponAsset(GetHashKey("weapon_flare"))
        while not HasWeaponAssetLoaded(GetHashKey("weapon_flare")) do
            Wait(0)
        end
        ShootSingleBulletBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(PlayerPedId()) - vector3(0.0001, 0.0001, 0.0001), 0, false, GetHashKey("weapon_flare"), 0, true, false, -1.0)

        if roofCheck and roofCheck ~= "false" then
            local ray = StartShapeTestRay(vector3(dropCoords.x, dropCoords.y, dropCoords.z) + vector3(0.0, 0.0, 500.0), vector3(dropCoords.x, dropCoords.y, dropCoords.z), -1, -1, 0)
            local _, hit, impactCoords = GetShapeTestResult(ray)
            if hit == 0 or (hit == 1 and #(vector3(dropCoords.x, dropCoords.y, dropCoords.z) - vector3(impactCoords)) < 10.0) then             
                CrateDrop(weapon, ammo, planeSpawnDistance, dropCoords)
            else            
                return
            end
        else            
            CrateDrop(weapon, ammo, planeSpawnDistance, dropCoords)
        end

    end)
end)

-- Crate Drop function
function CrateDrop(weapon, ammo, planeSpawnDistance, dropCoords)
    Citizen.CreateThread(function()
        Citizen.SetTimeout(2 * 60 * 1000, function()            
	        QBCore.Functions.Notify("Pilot: We are preparing the crate with the plane")					        
        Citizen.SetTimeout(7 * 60 * 1000, function()            
	        QBCore.Functions.Notify("Pilot: We are on the way to the flare signal")                 
        Citizen.SetTimeout(1 * 60 * 1000, function()
            for i = 1, #requiredModels do
                RequestModel(GetHashKey(requiredModels[i]))
                while not HasModelLoaded(GetHashKey(requiredModels[i])) do
                    Wait(0)
                end
            end
            RequestAnimDict("p_cargo_chute_s")
            while not HasAnimDictLoaded("p_cargo_chute_s") do
                Wait(0)
            end            
            RequestWeaponAsset(GetHashKey("weapon_flare"))
            while not HasWeaponAssetLoaded(GetHashKey("weapon_flare")) do
                Wait(0)
            end                   
            local rHeading = math.random(0, 360) + 0.0
            local planeSpawnDistance = (planeSpawnDistance and tonumber(planeSpawnDistance) + 0.0) or 400.0
            local theta = (rHeading / 180.0) * 3.14
            local rPlaneSpawn = vector3(dropCoords.x, dropCoords.y, dropCoords.z) - vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance, -500.0)
            local dx = dropCoords.x - rPlaneSpawn.x
            local dy = dropCoords.y - rPlaneSpawn.y
            local heading = GetHeadingFromVector_2d(dx, dy)
            aircraft = CreateVehicle(GetHashKey("cuban800"), rPlaneSpawn, heading, true, true)
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
            pilot = CreatePedInsideVehicle(aircraft, 1, GetHashKey("s_m_m_pilot_02"), -1, true, true)
            SetBlockingOfNonTemporaryEvents(pilot, true)
            SetPedRandomComponentVariation(pilot, false)
            SetPedKeepTask(pilot, true)
            SetPlaneMinHeightAboveTerrain(aircraft, 50)
            TaskVehicleDriveToCoord(pilot, aircraft, vector3(dropCoords.x, dropCoords.y, dropCoords.z) + vector3(0.0, 0.0, 500.0), 60.0, 0, GetHashKey("cuban800"), 262144, 15.0, -1.0) -- to the dropsite, could be replaced with a task sequence
            local droparea = vector2(dropCoords.x, dropCoords.y)
            local planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y)
            while not IsEntityDead(pilot) and #(planeLocation - droparea) > 5.0 do
                Wait(100)
                planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y)
            end
            if IsEntityDead(pilot) then 
                QBCore.Functions.Notify("The plane has crashed delivery failed")                
                return
            end
            TaskVehicleDriveToCoord(pilot, aircraft, 0.0, 0.0, 500.0, 60.0, 0, GetHashKey("cuban800"), 262144, -1.0, -1.0)
            SetEntityAsNoLongerNeeded(pilot) 
            SetEntityAsNoLongerNeeded(aircraft)      
            local crateSpawn = vector3(dropCoords.x, dropCoords.y, GetEntityCoords(aircraft).z - 5.0)
            
            QBCore.Functions.Notify("Pilot: keep the eye on sky the crate is droping")   

            crate = CreateObject(GetHashKey("prop_box_wood02a_pu"), crateSpawn, true, true, true)
            SetEntityLodDist(crate, 1000)
            ActivatePhysics(crate)
            SetDamping(crate, 2, 0.1)
            SetEntityVelocity(crate, 0.0, 0.0, -0.2)
            parachute = CreateObject(GetHashKey("p_cargo_chute_s"), crateSpawn, true, true, true)
            SetEntityLodDist(parachute, 1000)
            SetEntityVelocity(parachute, 0.0, 0.0, -0.2)            
            pickup = CreateAmbientPickup(GetHashKey("pickup_"..weapon), crateSpawn, 0, ammo, GetHashKey("ex_prop_adv_case_sm"), true, true)
            ActivatePhysics(pickup)
            SetDamping(pickup, 2, 0.0245)
            SetEntityVelocity(pickup, 0.0, 0.0, -0.2)
            soundID = GetSoundId()
            PlaySoundFromEntity(soundID, "Crate_Beeps", pickup, "MP_CRATE_DROP_SOUNDS", true, 0)
            blip = AddBlipForEntity(pickup)
            SetBlipSprite(blip, 408)
            SetBlipNameFromTextFile(blip, "AMD_BLIPN")
            SetBlipScale(blip, 0.7)
            SetBlipColour(blip, 2)
            SetBlipAlpha(blip, 120)
            local crateBeacon = StartParticleFxLoopedOnEntity_2("scr_crate_drop_beacon", pickup, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0, 1065353216, 0, 0, 0, 1065353216, 1065353216, 1065353216, 0)
            SetParticleFxLoopedColour(crateBeacon, 0.8, 0.18, 0.19, false)
            AttachEntityToEntity(parachute, pickup, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            AttachEntityToEntity(pickup, crate, 0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
            while HasObjectBeenBroken(crate) == false do
                Wait(0)
            end
            local parachuteCoords = vector3(GetEntityCoords(parachute))
            ShootSingleBulletBetweenCoords(parachuteCoords, parachuteCoords - vector3(0.0001, 0.0001, 0.0001), 0, false, GetHashKey("weapon_flare"), 0, true, false, -1.0)
            DetachEntity(parachute, true, true)            
            DeleteEntity(parachute)
            DetachEntity(pickup)
            SetBlipAlpha(blip, 255)
            while DoesEntityExist(pickup) do
                Wait(0)
            end
            while DoesObjectOfTypeExistAtCoords(parachuteCoords, 10.0, GetHashKey("w_am_flare"), true) do
                Wait(0)
                local prop = GetClosestObjectOfType(parachuteCoords, 10.0, GetHashKey("w_am_flare"), false, false, false)
                RemoveParticleFxFromEntity(prop)
                SetEntityAsMissionEntity(prop, true, true)
                DeleteObject(prop)
            end
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
            StopSound(soundID)
            ReleaseSoundId(soundID)
            for i = 1, #requiredModels do
                Wait(0)
                SetModelAsNoLongerNeeded(GetHashKey(requiredModels[i]))
            end
            RemoveWeaponAsset(GetHashKey("weapon_flare"))            
            TriggerServerEvent("cad-gundrop:server:AddItem", weapon, 1)            
        end)
        end)
        end)  
    end)
end

-- notify police functions
function NotifyPoliceFunction()
	local pos = GetEntityCoords(PlayerPedId())
	local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
	local streetLabel = GetStreetNameFromHashKey(s1)
	local street2 = GetStreetNameFromHashKey(s2)
	if street2 ~= nil and street2 ~= "" then 
		streetLabel = streetLabel .. " " .. street2
	end	
    --------------------------------------
    -- NOTE: put your own dispatch here --
    --------------------------------------
	--TriggerServerEvent('police:server:SuspiciousCall', GetEntityCoords(PlayerPedId()), "Suspicious Activity near "..streetLabel, "unknown", streetLabel)
end

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
        for i = 1, #requiredModels do
            Wait(0)
            SetModelAsNoLongerNeeded(GetHashKey(requiredModels[i]))
        end
    end
end)

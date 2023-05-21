local QBCore = exports[Config.CoreName]:GetCoreObject()

-- cooldown
local cooldown = nil
local function checkTime()
    if cooldown then
        local curTime = os.time()
        if cooldown < curTime then
            cooldown = nil
            return true
        else
            return false
        end
    end
    return true
end

-- Item Handler
RegisterNetEvent("cad-gundrop:server:ItemHandler", function(kind, item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if kind == 'add' then
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
    elseif kind == 'remove' then
        cooldown = os.time() + (Config.Cooldown * 60)
        Player.Functions.RemoveItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
    end
end)

RegisterNetEvent("cad-gundrop:server:showTarget", function(obj, item, amount)
    TriggerClientEvent('cad-gundrop:client:showTarget', -1, obj, item, amount)
end)

RegisterNetEvent("cad-gundrop:server:removeTarget", function(obj)
    TriggerClientEvent('cad-gundrop:client:removeTarget', -1, obj)
end)

-- get amount of cops online and on duty
QBCore.Functions.CreateCallback('cad-gundrop:server:getCops', function(source, cb)
    local count = 0
    for _, job in pairs(Config.PoliceJobs) do
        local amount = QBCore.Functions.GetDutyCount(job)
        count += amount
    end	
    Wait(100)
    cb(count)
end)

-- Golden Satalite Phone
QBCore.Functions.CreateUseableItem("goldenphone", function(source, item)
    local src = source
    local time = os.time()
    if checkTime() then
        TriggerClientEvent("cad-gundrop:client:CreateDrop", src, tostring(item.name), true, 400)
    else
        TriggerClientEvent("QBCore:Notify", src, 'Please wait for sometime before you use again!')
    end
end)

-- Red Satellite Phone
QBCore.Functions.CreateUseableItem("redphone", function(source, item)
    local src = source
    if checkTime() then
        TriggerClientEvent("cad-gundrop:client:CreateDrop", src, tostring(item.name), true, 400)
    else
        TriggerClientEvent("QBCore:Notify", src, 'Please wait for sometime before you use again!')
    end
end)

-- Green Satellite Phone
QBCore.Functions.CreateUseableItem("greenphone", function(source, item)
    local src = source
    if checkTime() then
        TriggerClientEvent("cad-gundrop:client:CreateDrop", src, tostring(item.name), true, 400)
    else
        TriggerClientEvent("QBCore:Notify", src, 'Please wait for sometime before you use again!')
    end
end)

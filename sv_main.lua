local QBCore = exports[Config.CoreName]:GetCoreObject()

-- Item Handler
RegisterNetEvent("cad-gundrop:server:ItemHandler", function(kind, item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if kind == 'add' then
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
    elseif kind == 'remove' then
        Player.Functions.RemoveItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
    end    
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
    TriggerClientEvent("cad-gundrop:client:CreateDrop", src, tostring(item.name), true, 400)            
end)

-- Red Satellite Phone
QBCore.Functions.CreateUseableItem("redphone", function(source, item)
    local src = source    
    TriggerClientEvent("cad-gundrop:client:CreateDrop", src, tostring(item.name), true, 400)            
end)

-- Green Satellite Phone
QBCore.Functions.CreateUseableItem("greenphone", function(source, item)
    local src = source    
    TriggerClientEvent("cad-gundrop:client:CreateDrop", src, tostring(item.name), true, 400)            
end)

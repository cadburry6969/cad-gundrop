local QBCore = exports['qb-core']:GetCoreObject()
--==============================
--         EVENTS
--==============================
-- Add Item From server side
RegisterServerEvent("cad-gundrop:server:AddItem")
AddEventHandler("cad-gundrop:server:AddItem", function(item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add')
end)

-- Remove Item From server side
RegisterServerEvent("cad-gundrop:server:RemoveItem")
AddEventHandler("cad-gundrop:server:RemoveItem", function(item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove')
end)

QBCore.Functions.CreateCallback('cad-gundrop:server:getCops', function(source, cb)
	local amount = 0
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
	end
	cb(amount)
end)
--==============================
--         ITEMS
--==============================
-- Golden Satalite Phone
QBCore.Functions.CreateUseableItem("goldenphone", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    local weapon
    if math.random(1, 100) > 50 then
        weapon = "WEAPON_CARBINERIFLE"
    else
        weapon = "WEAPON_ADVANCEDRIFLE"
    end
	if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent("cad-gundrop:client:CreateDrop", source, weapon, 2, true, 400)        
    end
end)

-- Red Satellite Phone
QBCore.Functions.CreateUseableItem("redphone", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent("cad-gundrop:client:CreateDrop", source, "WEAPON_ASSAULTRIFLE", 2, true, 400)        
    end
end)

-- Green Satellite Phone
QBCore.Functions.CreateUseableItem("greenphone", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent("cad-gundrop:client:CreateDrop", source, "WEAPON_ASSAULTSMG", 2, true, 400)        
    end
end)

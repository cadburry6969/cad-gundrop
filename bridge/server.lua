local QBCore = exports['qb-core']:GetCoreObject()
local cooldown = nil

function Notify(src, msg, type, duration)
    TriggerClientEvent('ox_lib:notify', src, { description = msg, type = type, duration = duration or 10000 })
end

function GetCopCount()
    local count = 0
    for _, job in pairs(Config.PoliceJobs) do
        local amount = QBCore.Functions.GetDutyCount(job)
        count += amount
    end
    return count
end

function CheckCooldown()
    if cooldown then
        local curTime = os.time()
        if cooldown > curTime then
            return true
        else
            cooldown = nil
        end
    end
    return false
end

function AddItem(src, item, amount, metadata)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:AddItem(src, item, amount, metadata)
    else
        if exports[Config.Inventory]:AddItem(src, item, amount, nil, metadata) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
            return true
        end
    end
    return false
end

function RemoveItem(src, item, amount)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(src, item, amount)
    else
        if exports[Config.Inventory]:RemoveItem(src, item, amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
            return true
        end
    end
    return false
end

function GetRandomItemData()
    local Items = Config.ItemDrops
    if Items then
        return Items[math.random(#Items)]
    end
end

if Config.Inventory == 'ox_inventory' then
    exports('useItems', function(event, item, inv, slot, data)
        if event == 'usingItem' then
            if item.name == 'drop_radio' then
                local src = inv.id
                if GetCopCount() < Config.RequiredCops then
                    Notify(src, Config.Lang["no_cops"], "error")
                    return false
                end
                if CheckCooldown() then
                    Notify(src, Config.Lang["cooldown_active"])
                    return false
                end
                cooldown = os.time() + (Config.Cooldown * 60)
                TriggerClientEvent("cad-gundrop:client:createDrop", src)
                return true
            end
            return false
        end
    end)
else
    QBCore.Functions.CreateUseableItem("drop_radio", function(source, item)
        local src = source
        if GetCopCount() < Config.RequiredCops then
            Notify(src, Config.Lang["no_cops"], "error")
            return
        end
        if CheckCooldown() then
            Notify(src, Config.Lang["cooldown_active"])
            return
        end
        if RemoveItem(src, 'drop_radio', 1) then
            cooldown = os.time() + (Config.Cooldown * 60)
            TriggerClientEvent("cad-gundrop:client:createDrop", src)
        end
    end)
end
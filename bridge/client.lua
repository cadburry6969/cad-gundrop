function Notify(msg, type, duration)
    lib.notify({ description = msg, type = type, duration = duration or 10000 })
end

function PoliceAlert()
    -- put your own dispatch here and comment the below event
    TriggerServerEvent('police:server:policeAlert', 'Suspicious activity')
end
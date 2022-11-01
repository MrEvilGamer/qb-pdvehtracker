QBCore = exports['qb-core']:GetCoreObject()
local time_out = {}

RegisterServerEvent("qb-pdvehtracker", function(plate) 

    local xPlayers = QBCore.Functions.GetPlayers()

    for i=1, #xPlayers, 1 do
        local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])


        if xPlayer.PlayerData.job.name == 'police' then
            TriggerClientEvent("qb-pdvehtracker:plate", xPlayers[i], plate)

        end

    end
end)

RegisterServerEvent("qb-pdvehtracker:setActivePlates", function(plate)
    time_out[plate] = false
end)

RegisterServerEvent("qb-pdvehtracker:removeActivePlate", function(plate)
    time_out[plate] = time_out[nil]
    local xPlayers = QBCore.Functions.GetPlayers()

    for i=1, #xPlayers, 1 do
        local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])


        if xPlayer.PlayerData.job.name == 'police' then
            TriggerClientEvent("qb-pdvehtracker:updateActivePlate", xPlayers[i], plate)
        end

    end

end)

RegisterServerEvent("qb-pdvehtracker:getActivePlates", function()
    TriggerClientEvent("qb-pdvehtracker:getActivePlates", source, time_out)
end)


RegisterServerEvent("qb-pdvehtracker:triggerTimer", function(plate)
    local xPlayers = QBCore.Functions.GetPlayers()
    local startTimer = os.time() + Config.removeTimer
    CreateThread(function()
        while os.time() < startTimer and time_out[plate] ~= nil do 
            Wait(5)
        end

        for i=1, #xPlayers, 1 do
            local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
    
    
            if xPlayer.PlayerData.job.name == 'police' then
                TriggerClientEvent("qb-pdvehtracker:updateTimer", xPlayers[i], plate)
            end
    
        end
    
    end)
end)


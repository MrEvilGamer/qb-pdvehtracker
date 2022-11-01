QBCore = exports['qb-core']:GetCoreObject()
local display = false 
local blips_pos = {}
local prev_pos = {}
local time_out = {}


CreateThread(function()
    while true do
      Wait(5)
      
      if (IsControlJustPressed(1, Config.openKey)) then
            local playerData = QBCore.Functions.GetPlayerData()

            if isInVehicle() and playerData.job.name == "police" then 
                SetNuiFocus(true, true)
                SendNUIMessage({type = 'ui', display = true})
            end
      end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function ()
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData.job.name == 'police' then
        print("Police vehicle tracker loaded.")
        TriggerServerEvent("qb-pdvehtracker:getActivePlates")
    end
end)

RegisterNetEvent("qb-pdvehtracker:updateTimer", function(plate)
    time_out[plate] = time_out[nil]
end)

RegisterNetEvent("qb-pdvehtracker:updateActivePlate", function(plate)

    for v,k in pairs(time_out) do 
        if time_out[v] == plate then 
            time_out[plate] = true 
        end
    end
   
end)



RegisterNetEvent("qb-pdvehtracker:getActivePlates", function(plates)
    time_out = plates
    for v,k in pairs(time_out) do
        checkVehicle(v)
    end
end)

RegisterNetEvent('qb-pdvehtracker:plate', function(plate)
    checkVehicle(plate)
end)

RegisterNUICallback('searchPlate', function(data, cb)
    local vehicle = QBCore.Functions.GetVehicles()
    local miss = 0

    for i=1, #vehicle, 1 do 
        local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle[i])
        
        if vehicleProps.plate == data.plate then 
            local nCheck = 0
            for _ in pairs(time_out) do 
                nCheck=nCheck + 1
            end

            if nCheck >= Config.maxTracker then 
                SendNUIMessage({type = "maxPlate"})
            else
                SendNUIMessage({
                    type = "ui",
                    display = false
                  })
            
                SetNuiFocus(false)
                TriggerServerEvent("qb-pdvehtracker", data.plate)
            end
        else 
            miss = miss + 1 
        end 
    end

    if #vehicle == miss then 
        SendNUIMessage({type = "noPlate"})
    end
end)

RegisterNUICallback("removeSearch", function(data, cb)
    local vehicle = QBCore.Functions.GetVehicles()
    local miss = 0

    for i=1, #vehicle, 1 do 
        local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle[i])
        
        if vehicleProps.plate == data.plate then 
            TriggerServerEvent("qb-pdvehtracker:removeActivePlate", data.plate)
            SendNUIMessage({
                type = "ui",
                display = false
              })
        
            SetNuiFocus(false)
        else 
            miss = miss + 1 
        end 
    end

    if #vehicle == miss then 
        SendNUIMessage({type = "noPlate"})
    end
end)


RegisterNUICallback("close", function(data, cb)
    SendNUIMessage({
        type = "ui",
        display = false
      })

    SetNuiFocus(false)
end)


function checkVehicle(plate)
    local vehicle = QBCore.Functions.GetVehicles()
    local trackevehicle = plate
    if not trackevehicle then
        for i=1, #vehicle, 1 do 
            local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle[i])
            
            if vehicleProps.plate == plate then 
                TriggerServerEvent("qb-pdvehtracker:setActivePlates", plate)
                time_out[plate] = false
                createVehicleTracker(vehicle[i], plate) 
            end 
        end
    else
        QBCore.Functions.Notify('Can not Track the Same Vehicle')
    end
end

function triggerTimer(plate)
    TriggerServerEvent("qb-pdvehtracker:triggerTimer", plate)
end

function isInVehicle()
    if Config.inVehicle then 
        return IsPedInAnyVehicle(PlayerPedId(), false)
    else
        return true 
    end 
end

function createVehicleTracker(vehicle, plate) 
    triggerTimer(plate)
        QBCore.Functions.Notify('Tracker Activated')
        CreateThread(function()
            while time_out[plate] == false do
                Wait(50)

                if DoesEntityExist(vehicle) then 
           

                    local x, y, z = table.unpack(GetEntityCoords(vehicle))
         

                    if prev_pos == table.unpack(GetEntityCoords(vehicle)) then 
                
                    else 


                        RemoveBlip(blips_pos[plate])
 
                        local new_pos_blip = AddBlipForCoord(x,y,z)
      
                        SetBlipSprite(new_pos_blip, 432)
                        SetBlipDisplay(new_pos_blip, 4)
                        SetBlipColour(new_pos_blip, 75)
                        SetBlipScale(new_pos_blip, 1.0)


                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString('Plate: ' ..plate)
                        EndTextCommandSetBlipName(new_pos_blip)

    
                        blips_pos[plate] = new_pos_blip
                        prev_pos = table.unpack(GetEntityCoords(vehicle))
                    end

                else
                    time_out[plate] = time_out[nil]
                    TriggerServerEvent("qb-pdvehtracker:removeActivePlate", plate)
                    QBCore.Functions.Notify('Tracker Lost', 'error')
                end
            end 
            RemoveBlip(blips_pos[plate])
            time_out[plate] = time_out[nil]
            TriggerServerEvent("qb-pdvehtracker:removeActivePlate", plate)
        QBCore.Functions.Notify('Tracker Lost'.. plate, 'error')
    end)
end 


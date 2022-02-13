local QBCore = exports['qb-core']:GetCoreObject()


Doors = {
    ["F1"] = {{loc = vector3(310.93, -284.44, 54.16), txtloc = vector3(310.93, -284.44, 54.16), state = nil, locked = true}},
    ["F2"] = {{loc = vector3(146.61, -1046.02, 29.37), txtloc = vector3(146.61, -1046.02, 29.37), state = nil, locked = true}},
    ["F3"] = {{loc = vector3(-1211.07, -336.68, 37.78), txtloc = vector3(-1211.07, -336.68, 37.78), state = nil, locked = true}},
    ["F4"] = {{loc = vector3(-2956.68, 481.34, 15.70), txtloc = vector3(-2956.68, 481.34, 15.7), state = nil, locked = true}},
    ["F5"] = {{loc = vector3(-354.15, -55.11, 49.04), txtloc = vector3(-354.15, -55.11, 49.04), state = nil, locked = true}},
    ["F6"] = {{loc = vector3(1176.40, 2712.75, 38.09), txtloc = vector3(1176.40, 2712.75, 38.09), state = nil, locked = true}},
}

RegisterServerEvent("qb-fleeca:startcheck")
AddEventHandler("qb-fleeca:startcheck", function(bank)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Fleeca.Banks[bank].onaction == true then
        if (os.time() - 10) > Fleeca.Banks[bank].lastrobbed then
            Fleeca.Banks[bank].onaction = true
            TriggerClientEvent("qb-fleeca:outcome", src, true, bank)
        else
            TriggerClientEvent("qb-fleeca:outcome", src, false, "This bank recently robbed. You need to wait "..math.floor((60 - (os.time() - Fleeca.Banks[bank].lastrobbed)) / 60)..":"..math.fmod((60 - (os.time() - Fleeca.Banks[bank].lastrobbed)), 60))
        end
    else
        TriggerClientEvent("qb-fleeca:outcome", src, false, "This bank is currently being robbed.")
    end
end)

RegisterServerEvent("qb-fleeca:lootup")
AddEventHandler("qb-fleeca:lootup", function(var, var2)
    TriggerClientEvent("qb-fleeca:lootup_c", -1, var, var2)
end)

RegisterServerEvent("qb-fleeca:toggleVault")
AddEventHandler("qb-fleeca:toggleVault", function(key, state)
    Doors[key][1].locked = state
    TriggerClientEvent("qb-fleeca:toggleVault", -1, key, state)
end)

RegisterServerEvent("qb-fleeca:updateVaultState")
AddEventHandler("qb-fleeca:updateVaultState", function(key, state)
    Doors[key][1].state = state
end)

RegisterServerEvent("qb-fleeca:startLoot")
AddEventHandler("qb-fleeca:startLoot", function(data, name, players)
    local src = source

    for i = 1, #players, 1 do
        TriggerClientEvent("qb-fleeca:startLoot_c", players[i], data, name)
    end
    TriggerClientEvent("qb-fleeca:startLoot_c", src, data, name)
end)

RegisterServerEvent("qb-fleeca:stopHeist")
AddEventHandler("qb-fleeca:stopHeist", function(name)
    TriggerClientEvent("qb-fleeca:stopHeist_c", -1, name)
end)

RegisterServerEvent("qb-fleeca:rewardCash")
AddEventHandler("qb-fleeca:rewardCash", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local markedbills = math.random(15, 19)
	
    Player.Functions.AddItem('markedbills', markedbills, false, {worth = math.random(5000, 10000)})
    TriggerEvent('nn-logs:server:createLog', 'fleecarob', 'Got ' .. markedbills .. ".", "", src)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['markedbills'], "add")
end)

RegisterServerEvent("qb-fleeca:setCooldown")
AddEventHandler("qb-fleeca:setCooldown", function(name)
    Fleeca.Banks[name].lastrobbed = os.time()
    Fleeca.Banks[name].onaction = false
    TriggerClientEvent("qb-fleeca:resetDoorState", -1, name)
end)

QBCore.Functions.CreateCallback("qb-fleeca:getBanks", function(source, cb)
    cb(Fleeca.Banks, Doors)
end)

QBCore.Functions.CreateCallback('qb-fleeca:server:HasItem', function(source, cb, ItemName)
    local Player = QBCore.Functions.GetPlayer(source)
    local Item = Player.Functions.GetItemByName(ItemName)
    if Player ~= nil then
       if Item ~= nil then
         cb(true)
       else
         cb(false)
       end
    end
end)

QBCore.Functions.CreateUseableItem("heistlaptop3", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent('qb-fleeca:uselaptop3', source, item)
    end
end)

QBCore.Functions.CreateCallback('qb-fleeca:server:getCops', function(source, cb)
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
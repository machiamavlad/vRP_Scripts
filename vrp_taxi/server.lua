local Tunnel = module('vrp','lib/Tunnel')
local Proxy = module('vrp','lib/Proxy')

local vRP = Proxy.getInterface('vRP')
local vRPclient = Tunnel.getInterface("vRP","vRP_taxi")
local vRPCtaxi = Tunnel.getInterface("vRP_taxi","vRP_taxi")

local taxiState = {}
local taxAmount = 500

RegisterCommand('fare', function(player,args,rawCommand)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
        vRPCtaxi.isInTaxiVeh(player,{},function(taxiId)
            if taxiId then
                local amount = parseInt(args[1])
                if amount ~= nil and amount > 0 and amount <= 1500 then
                    if not taxiState[user_id] then
                        TriggerClientEvent('chatMessage',-1,'^2Soferul de taxi ^0'..GetPlayerName(player)..'^2 este acum disponibil, tarif per km: ^0'..vRP.formatMoney({amount}).."$")
                        vRPCtaxi.onTaxiDuty(player,{taxiId,amount})
                        taxiState[user_id] = {
                            driverId = user_id,
                            fare = amount,
                            taxiId = taxiId
                        }
                    else
                        vRPclient.notify(player,{"~r~Deja ai pornit aparatul!"})
                    end
                else
                    vRPclient.notify(player,{"~r~Tariful specificat este invalid!"})
                end
            else
                vRPclient.notify(player,{"~r~Nu te afli intr-un taxi!"})
            end
        end)
    end
end)

RegisterServerEvent('taxi:setFirstPasager')
AddEventHandler('taxi:setFirstPasager',function(nplayer)
    local player = source
    local user_id = vRP.getUserId({player})
    local ped = GetPlayerPed(player)

    local nplayer = nplayer
    local nuser_id = vRP.getUserId({nplayer})

    if taxiState[user_id] then
        taxiState[user_id].earnings = 0
        taxiState[user_id].passager = {nplayer,nuser_id}
        taxiState[user_id].coords = GetEntityCoords(ped)

        vRPclient.notify(nplayer,{"Te-ai urcat in taxi!~n~Sofer:~g~ "..GetPlayerName(player).."~w~!~n~Tarif per km: ~g~"..vRP.formatMoney({taxiState[user_id].fare})})

        vRPCtaxi.updateNameAndEarnings(player,{
            GetPlayerName(nplayer),
            taxiState[user_id].earnings
        })
        
        vRPCtaxi.showOnScreenHud(nplayer,{
            GetPlayerName(player),
            taxiState[user_id].earnings,
            taxiState[user_id].fare,
            taxiState[user_id].taxiId,
            user_id        
        })
        vRPCtaxi.startClock(player,{})
    end
end)

RegisterServerEvent('taxi:checkPosition')
AddEventHandler('taxi:checkPosition',function()
    local player = source
    local user_id = vRP.getUserId({player})

    local ped = GetPlayerPed(player)
    local coords = GetEntityCoords(ped)
    if taxiState[user_id] then
        if taxiState[user_id].passager ~= nil then
            if type(taxiState[user_id].passager) == 'table' then
                local nplayer = taxiState[user_id].passager[1]
                local nuser_id = taxiState[user_id].passager[2]
                local nmoney = (vRP.getMoney({nuser_id}) + vRP.getBankMoney({nuser_id}))

                if #(coords - taxiState[user_id].coords) > 100.0 then
                    taxiState[user_id].earnings = math.floor(((taxiState[user_id].earnings or 0) + (taxiState[user_id].fare / 10)))
                    taxiState[user_id].coords = coords
                    if (nmoney - taxiState[user_id].earnings) < 1000 then
                        vRPclient.notify(player,{"~r~Pasagerul aproape a ramas fara bani!"})
                    end
                end
                vRPCtaxi.updateNameAndPaid(nplayer,{GetPlayerName(player),taxiState[user_id].earnings})
                vRPCtaxi.updateNameAndEarnings(player,{GetPlayerName(nplayer),taxiState[user_id].earnings})
            end
        end
    end
end)

RegisterServerEvent('taxi:passagerLeft')
AddEventHandler('taxi:passagerLeft',function(driverId)
    local player = source
    local user_id = vRP.getUserId({player})
    if taxiState[driverId] then
        local nuser_id = driverId
        local nplayer = vRP.getUserSource({nuser_id})
        local payOut = taxiState[nuser_id].earnings
        if nplayer then
            if payOut > 0 then
                if vRP.tryFullPayment({user_id,payOut}) then
                    vRP.giveMoney({nuser_id,payOut})
                    vRPclient.notify(player,{"Ai platit ~g~"..vRP.formatMoney({payOut}).."$~w~ pentru cursa de ~y~Taxi~w~!"})
                    vRPclient.notify(nplayer,{"Ai primit ~g~"..vRP.formatMoney({payOut}).."$~w~ pentru cursa de ~y~Taxi~w~!"})
                end
            end
            taxiState[nuser_id].passager = nil
            taxiState[nuser_id].earnings = 0
            taxiState[nuser_id].coords = nil
            vRPCtaxi.passagerLeft(nplayer,{})
        end
    end
end)

RegisterServerEvent('taxi:setState')
AddEventHandler('taxi:setState',function(state)
    local player = source
    local user_id = vRP.getUserId({player})
    if not state then
        if type(taxiState[user_id].passager) == 'table' then
            local nplayer = taxiState[user_id].passager[1]
            local nuser_id = taxiState[user_id].passager[2]
            if nplayer then
                vRPclient.notify(nplayer,{"Cursa a fost anulata, soferul a parasit masina!"})
                if player then
                    if vRP.tryFullPayment({user_id,taxAmount}) then
                        vRPclient.notify(player,{"~r~Ai parasit masina in timpul cursei! Ai fost taxat cu ~y~"..vRP.formatMoney({taxAmount}).."$"})
                    end
                end
            end
        end
        taxiState[user_id] = nil
    end
end)

AddEventHandler("playerDropped",function(reason)
    local player = source
    local user_id = vRP.getUserId({player})
    if taxiState[user_id] then
        if type(taxiState[user_id].passager) == 'table' then
            local nplayer = taxiState[user_id].passager[1]
            local nuser_id = taxiState[user_id].passager[2]
            if nplayer then
                vRPclient.notify(nplayer,{"Soferul de taxi s-a deconectat, cursa a fost anulata!"})
            end
        end
        taxiState[user_id] = nil
    end
end)
local Tunnel, Proxy = module('vrp', 'lib/Tunnel'), module('vrp', 'lib/Proxy')
local vRP, vRPclient = Proxy.getInterface('vRP'), Tunnel.getInterface('vRP', 'Paintball')

local duelConfig = cfg.duelConfig
local paintPosition = vec3(242.54988098145, -44.549835205078, 69.896492004395);
local availableWeapons = cfg.weapons
local duelPlayers = {}
local activeDuelRequests = {}

local ffa_game = {players={}}
local paintball_duel_games = {}

GlobalState["ffaPlayers"] = 0
GlobalState["ffaLobbyTimer"] = 0
GlobalState["ffa_gameTimer"] = "00:00"

-- Duels
local function send_duel_request(user_id, nuser_id, wname)
    local player, nplayer = vRP.getUserSource({user_id}), vRP.getUserSource({nuser_id})
    -- print(user_id, nuser_id, player, nplayer)
    if availableWeapons[wname] then
        if player ~= nil and nplayer ~= nil then
            
            local playerName = GetPlayerName(player).."("..user_id..")" or "Unknown("..user_id..")"
            local nplayerName = GetPlayerName(nplayer).."("..nuser_id..")" or "Unknown("..nuser_id..")"

            local weaponName = availableWeapons[wname]

            if duelPlayers[user_id] ~= nil then
                vRPclient.notify(player, {"Deja te aflii intr-un ^3duel^0."})
                return
            end

            if duelPlayers[nuser_id] ~= nil then
                vRPclient.notify(player, {"Acest jucator deja se afla intr-un ^3duel^0."})
                return
            end

            activeDuelRequests[user_id] = {challengedId = nuser_id, weapon = wname}
            activeDuelRequests[nuser_id] = {challengerId = user_id, weapon = wname}
            TriggerClientEvent("chatMessage", player, "^7[^6DUEL^7]: Cererea de duel a fost trimisa catre ^6"..nplayerName.."^7.")

            vRP.closeMenu({player})
            vRP.request({nplayer, "<b>Invitatie duel</b><br/><br/>Jucatorul <font style='color: var(--color-chat-1);'>"..playerName.."</font> te-a invitat la un duel folosind arma <font style='color: var(--color-chat-1);'>"..weaponName.."</font>.<br/>Doresti sa accepti invitatia?", 60, function(nplayer, response)
                if response then
                    if activeDuelRequests[user_id] == nil then
                        vRPclient.notify(player, {"Acest jucator nu mai este conectat."})
                        activeDuelRequests[nuser_id] = nil
                        return
                    end

                    if activeDuelRequests[nuser_id] == nil then
                        vRPclient.notify(player, {"Acest jucator si-a anulat cererea de duel."})
                        if activeDuelRequests[user_id].challengedId == nuser_id then
                            activeDuelRequests[user_id] = nil
                        end 
                        return
                    end

                    TriggerClientEvent("chatMessage", player, "^7[^6DUEL^7]: ^6"..nplayerName.."^7 ti-a acceptat cererea de duel, vei fi teleportat in cateva momente.")
                    TriggerClientEvent("chatMessage", nplayer, "^7[^6DUEL^7]: Ai acceptat duelul cu ^6"..playerName.."^7, vei fi teleportat in cateva momente.")
                    activeDuelRequests[user_id] = nil
                    activeDuelRequests[nuser_id] = nil
                    
                    local data, ndata = vRP.getUserDataTable({user_id}), vRP.getUserDataTable({nuser_id})
                    if data and ndata then
                        local duelGameId = user_id
                        local duelMapId = math.random(1, #duelConfig)
                        local virtualWorldId = user_id + 65
                        local duelData = {
                            ally = user_id,
                            enemy = nuser_id,
                            weapon = tostring(wname),
                            mapId = duelMapId
                        }

                        paintball_duel_games[duelGameId] = duelData
                        duelPlayers[user_id] = {member = "ally", gameId = duelGameId, gameType = "duel", oldWeapons = data.weapons}
                        duelPlayers[nuser_id] = {member = "enemy", gameId = duelGameId, gameType = "duel", oldWeapons = ndata.weapons}
                        vRPclient.removeWeapons(player, {})
                        data.weapons = {}
                        vRPclient.removeWeapons(nplayer, {})
                        ndata.weapons = {}

                        Player(player).state.inDuel = true
                        Player(nplayer).state.inDuel = true

                        SetPlayerRoutingBucket(player, virtualWorldId)
                        SetPlayerRoutingBucket(nplayer, virtualWorldId)

                        TriggerClientEvent("machiamavlad:setPlayerInDuel", player, {
                            duel_arena = duelConfig[duelMapId],
                            players = {player, nplayer},
                            weapon = wname
                        }, "ally")

                        TriggerClientEvent("machiamavlad:setPlayerInDuel", nplayer, {
                            duel_arena = duelConfig[duelMapId],
                            players = {player, nplayer},
                            weapon = wname
                        }, "enemy")

                        Citizen.SetTimeout(5000, function()
                            if duelPlayers[user_id] and duelPlayers[nuser_id] then
                                vRPclient.giveWeapon(player, {wname, 250})
                                vRPclient.giveWeapon(nplayer, {wname, 250})

                                vRPclient.notify(player, {"Ai primit ~y~"..availableWeapons[wname].."~w~ cu ~r~250 de gloante~w~.\nArmele tale anterioare au fost stocate."})
                                vRPclient.notify(nplayer, {"Ai primit ~y~"..availableWeapons[wname].."~w~ cu ~r~250 de gloante~w~.\nArmele tale anterioare au fost stocate."})
                            end
                        end)
                    end
                else
                    vRPclient.sendMessage(nplayer, {"Ai refuzat cererea de duel a jucatorului ^1"..playerName.."^7."})
                    vRPclient.sendMessage(nplayer, {"^1"..nplayerName.."^7 a refuzat cererea trimisa de duel."})
                    activeDuelRequests[user_id] = nil
                    activeDuelRequests[nuser_id] = nil
                end
            end})                
        end
    end
end

AddEventHandler("vRP:playerLeave", function(user_id, player, reason)
    local game = getPlayerPaintGameIsIn(user_id)

    if game == "none" then return end
    if game == "duel" then
        if duelPlayers[user_id] then
        
            local memberPos = duelPlayers[user_id].member
            local duelGameId = duelPlayers[user_id].gameId
            if paintball_duel_games[duelGameId] then
                local duelGameData = paintball_duel_games[duelGameId]
                local weapons = duelPlayers[user_id].oldWeapons
                local nuser_id = nil
    
                if memberPos == "ally" then
                    nuser_id = paintball_duel_games[duelGameId]["enemy"]
                else
                    nuser_id = paintball_duel_games[duelGameId]["ally"]
                end
                
                if nuser_id ~= nil then
                    local nplayer = vRP.getUserSource({nuser_id})
                    if nplayer then
                        local data = vRP.getPlayerData({user_id})
                        if data then
                            if duelPlayers[nuser_id] then
                                if duelPlayers[nuser_id].gameId == duelGameId then
                                    local oldWeapons = duelPlayers[nuser_id].oldWeapons
                                    data.weapons = oldWeapons
                                    TriggerClientEvent("chatMessage", nplayer, "^7[^6FFA^7]: ^7Inamicul tau s-a deconectat in timpul jocului, meciul a fost anulat.")
    
                                    Player(nplayer).state.inDuel = false
                                    vRPclient.removeWeapons(nplayer, {})
                                    vRPclient.teleport(nplayer, {paintPosition.x, paintPosition.y, paintPosition.z})
                                    SetPlayerRoutingBucket(nplayer, 0)
                                    TriggerClientEvent("machiamavlad:setOutOfDuelGame", nplayer)
    
                                    Citizen.SetTimeout(1000, function()
                                        vRPclient.notify(nplayer, {"Armele ti-au fost restituite."})
                                        vRPclient.giveWeapons(nplayer, {oldWeapons})
                                        
                                        duelPlayers[nuser_id] = nil
                                    end)
                                end
                            end
                        end
                    end
                end
                
                vRPclient.removeWeapons(player, {})
                paintball_duel_games[duelGameId] = nil;
                duelPlayers[user_id] = nil
            end
    
            Player(player).state.inDuel = false
        end
    elseif game == "ffa" then
        if ffa_game.started then
            if ffa_game.players[user_id] then
                local weapons = ffa_game.players[user_id].oldWeapons
                vRPclient.removeWeapons(player, {})
                Player(player).state.inFFA = false

                Player(player).state.paint_kills = 0
                Player(player).state.paint_deaths = 0

                ffa_game.players[user_id] = nil
                GlobalState["ffaPlayers"] = table.count(ffa_game.players)
            end
        end
    end
end)

function getPlayerPaintGameIsIn(user_id)
    local player = vRP.getUserSource({user_id})
    if player then
        if Player(player).state.inDuel then
            return "duel"
        elseif Player(player).state.inFFA then
            return "ffa"
        end
    end
    return "none"
end

AddEventHandler("paintball:onPlayerDied", function(user_id, nuser_id, weapon) 
    -- print(user_id, nuser_id, weapon)
    local player = vRP.getUserSource({user_id})
    local nplayer = vRP.getUserSource({nuser_id})
    if (player) ~= nil and (nplayer) ~= nil then
        local game = getPlayerPaintGameIsIn(user_id)

        if game ~= "none" then
            if game == "duel" then
                local ngame = getPlayerPaintGameIsIn(nuser_id)
                if ngame == "duel" then
                    local user_id, nuser_id = nuser_id, user_id
                    local player, nplayer = vRP.getUserSource({user_id}), vRP.getUserSource({nuser_id})

                    if player ~= nil and nplayer ~= nil then
                        -- print('yes4')
                        local gameId = duelPlayers[user_id].gameId
                        if paintball_duel_games[gameId] then
                            local weapons_player = duelPlayers[user_id].oldWeapons
                            local weapons_nplayer = duelPlayers[nuser_id].oldWeapons

                            local weapon = paintball_duel_games[gameId].weapon

                            vRPclient.removeWeapons(player, {})
                            vRPclient.removeWeapons(nplayer, {})
                            

                            TriggerClientEvent("machiamavlad:setOutOfDuelGame", player)
                            TriggerClientEvent("machiamavlad:setOutOfDuelGame", nplayer)

                            Citizen.Wait(2000)

                            vRPclient.teleport(player, {paintPosition.x, paintPosition.y, paintPosition.z})
                            vRPclient.teleport(nplayer, {paintPosition.x, paintPosition.y, paintPosition.z})

                           --TriggerClientEvent("chatMessage", -1, "^7[^6DUEL^7]:^6"..GetPlayerName(player).."("..user_id..")^7 l-a invins pe ^6"..GetPlayerName(nplayer).."("..nuser_id..")^7.")
                            --TriggerClientEvent("chatMessage", -1, "^6Arma duel: ^7"..availableWeapons[weapon])

                            TriggerClientEvent("chatMessage", player, "^7[^6DUEL^7]: ^7Felicitari, ^6ai castigat^7 duelul!")
                            TriggerClientEvent("chatMessage", nplayer, "^7[^6DUEL^7]: ^1Ai pierdut^7 duelul!")

                            SetPlayerRoutingBucket(player, 0)
                            SetPlayerRoutingBucket(nplayer, 0)

                            local tmp, ntmp = vRP.getUserDataTable({user_id}), vRP.getUserDataTable({nuser_id})
                            if tmp then
                                tmp.weapons = weapons_player
                                vRPclient.giveWeapons(player, {weapons_player})
                                vRPclient.notify(player, {"Armele ti-au fost restituite."})
                            end

                            if ntmp then
                                ntmp.weapons = weapons_nplayer
                                vRPclient.giveWeapons(nplayer, {weapons_nplayer})
                                vRPclient.notify(nplayer, {"Armele ti-au fost restituite."})
                            end

                            paintball_duel_games[gameId] = nil
                            duelPlayers[user_id] = nil
                            duelPlayers[nuser_id] = nil
                            
                            Player(player).state.inDuel = false
                            Player(nplayer).state.inDuel = false

                            Citizen.CreateThread(function()
                                vRPclient.revive(nplayer, {})
                                TriggerClientEvent("machiamavlad:remoteCode", nplayer, [[
                                    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
                                    NetworkResurrectLocalPlayer(x, y, z, true, true, false)
                                ]])
                                vRPclient.setHealth(nplayer, {200})

                                TriggerClientEvent("machiamavlad:remoteCode", player, [[
                                    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
                                    NetworkResurrectLocalPlayer(x, y, z, true, true, false)
                                ]])
                                vRPclient.setHealth(player, {200})
                            end)
                        end
                    end 
                end
            elseif game == "ffa" then
                Player(player).state.paint_deaths = (Player(player).state.paint_deaths or 0) + 1
                if ffa_game.players[nuser_id] then
                    Player(nplayer).state.paint_kills = (Player(nplayer).state.paint_kills or 0) + 1
                end

                local spawns = cfg.ffaConfig.arenas[ffa_game.map].spawns[spawnLoc]
                vRPclient.revive(player, {})
                vRPclient.removeWeapons(player, {})
                Citizen.Wait(10)
                for wbody, wammo in pairs(cfg.ffaConfig.weapons) do
                    vRPclient.giveWeapon(player, {wbody, wammo})
                end
                TriggerClientEvent("machiamavlad:remoteCode", player, [[
                    local ped = PlayerPedId()
                    local x, y, z = ]].. (spawns.x .. ", " .. spawns.y .. ", " .. spawns.z) ..[[
                    
                    DoScreenFadeOut(1000)
                    Citizen.Wait(2000)
                    tvRP.teleport({x, y, z})
                    RequestCollisionAtCoord(x, y, z)
                    SetEntityCoords(ped, x + 0.0001, y + 0.0001, z + 5.0000, 1, 0, 0, 1)
                    SetEntityInvincible(ped, false)
                    tvRP.setRagdoll({false})
                    NetworkResurrectLocalPlayer(x, y, z + 1.0, true, true, false)
                    FreezeEntityPosition(ped, false)
                    Citizen.Wait(500)
                    DoScreenFadeIn(300)
                ]])

                spawnLoc = spawnLoc + 1
                if spawnLoc > #cfg.ffaConfig.arenas[ffa_game.map].spawns then
                    spawnLoc = 1
                end

                for user_id, info in pairs(ffa_game.players) do
                    local nnplayer = info.player
                    TriggerClientEvent("machiamavlad:indexFFAKillNotification", nnplayer, GetPlayerName(nplayer), GetPlayerName(player))
                end
            end
        end
    else
        if (player and nplayer == nil) then
            if Player(player).state.inFFA then
                Player(player).state.paint_deaths = (Player(player).state.paint_deaths or 0) + 1

                local spawns = cfg.ffaConfig.arenas[ffa_game.map].spawns[spawnLoc]
                vRPclient.revive(player, {200})
                vRPclient.removeWeapons(player, {})
                Citizen.Wait(10)
                for wbody, wammo in pairs(cfg.ffaConfig.weapons) do
                    vRPclient.giveWeapon(player, {wbody, wammo})
                end

                TriggerClientEvent("machiamavlad:remoteCode", player, [[
                    local ped = PlayerPedId()
                    local x, y, z = ]].. (spawns.x .. ", " .. spawns.y .. ", " .. spawns.z) ..[[
                    
                    DoScreenFadeOut(1000)
                    Citizen.Wait(2000)
                    tvRP.teleport({x, y, z})
                    RequestCollisionAtCoord(x, y, z)
                    SetEntityCoords(ped, x + 0.0001, y + 0.0001, z + 5.0000, 1, 0, 0, 1)
                    SetEntityInvincible(ped, false)
                    tvRP.setRagdoll({false})
                    NetworkResurrectLocalPlayer(x, y, z + 1.0, true, true, false)
                    FreezeEntityPosition(ped, false)
                    Citizen.Wait(500)
                    DoScreenFadeIn(300)
                ]])

                spawnLoc = spawnLoc + 1
                if spawnLoc > #cfg.ffaConfig.arenas[ffa_game.map].spawns then
                    spawnLoc = 1
                end
            end
        end
    end
end)

RegisterCommand("cancelduel", function(player)
    local user_id = vRP.getUserId({player})
    if user_id then
        if activeDuelRequests[user_id] then
            vRP.request({player, "Esti sigur ca doresti sa anulezi cererea de duel?", 30, function(player, ok)
                if ok then
                    local nuser_id = activeDuelRequests[user_id].challengedId
                    if nuser_id then
                        TriggerClientEvent("chatMessage", player, "^7[^6FFA^7]: Ai anulat cererea de duel.")
                        activeDuelRequests[user_id] = nil

                        local nplayer = vRP.getUserSource({nuser_id})

                        local nplayerName = "Unknown("..nuser_id..")"
                        if nplayer then
                            if activeDuelRequests[nuser_id] then
                                if activeDuelRequests[nuser_id].challengerId == user_id then
                                    activeDuelRequests[nuser_id] = nil
                                    TriggerClientEvent("chatMessage", nplayer, "^7[^6FFA^7]: Jucatorul ^6"..GetPlayerName(player).."("..user_id..")^7 a anulat cererea de duel.")
                                    nplayerName = GetPlayerName(nplayer).."("..nuser_id..")"
                                end
                            end
                        end
                    end
                end
            end})
        else
            vRPclient.notify(player, {"Nu ai nicio cerere pentru duelare in asteptare."})
        end
    end
end)

local function choose_duel(player, choice)
    local user_id = vRP.getUserId({player})
    if user_id then
        if not activeDuelRequests[user_id] then
            vRP.prompt(player, "FFA Duel", "Te rugam sa introduci id-ul jucatorului pe care doresti sa-l inviti la un duel.", function(player, nuser_id)
                local nuser_id = parseInt(nuser_id)
                if nuser_id > 0 then
                    if nuser_id ~= user_id then
                        local nplayer = vRP.getUserSource({nuser_id})
                        if nplayer then
                            if not activeDuelRequests[nuser_id] then
                                if not duelPlayers[nuser_id] then
                                    local menu = {}
                                    menu.name = "Duel"
                                    menu.css = {header_color = "32 100 156 / 30%"}
                                    local playerName = GetPlayerName(nplayer).."("..nuser_id..")";
                                    
                                    for whash, wname in pairs(availableWeapons) do
                                        if whash:find("BAT") == nil then
                                            menu[wname] = {function(player, choice) 
                                                send_duel_request(user_id, nuser_id, whash)
                                            end, "Provoaca-l pe <font style='color: var(--color-chat-4);'>"..playerName.."</font> la un duel folosind arma <font style='color: var(--color-chat-1);'>"..wname.."</font>."}
                                        end
                                    end

                                    vRP.openMenu({player, menu})
                                else
                                    vRPclient.notify(player, {"Acest jucator este deja intr-un meci de FFA."})
                                end
                            else
                                vRPclient.notify(player, {"Acest jucator are deja o cerere de duelare in asteptare."})
                            end
                        else
                            vRPclient.notify(player, {"Acest jucator nu este conectat."})
                        end
                    else
                        vRPclient.notify(player, {"Nu poti sa iti trimiti o cerere de duel singur."})
                    end
                else
                    vRPclient.notify(player, {"Jucatorul specificat este invalid."})
                end
            end)
        else
            vRPclient.notify(player, {"Deja ai trimis o cerere de duelare, foloseste comanda ^1/cancelduel^0 pentru a o anula.."})
        end
    end
end

-- FFA
local function tryStartPaintballLobby()
    ffa_game.inLobby = true
    ffa_game.lobbyTimer = os.time() + cfg.ffaConfig.lobbyDuration
    Citizen.Wait(500)
    Citizen.CreateThread(function() 
        GlobalState["ffaPlayers"] = table.count(ffa_game.players)
        GlobalState["ffaLobbyTimer"] = (ffa_game.lobbyTimer - os.time())
        while ffa_game.inLobby and os.time() < ffa_game.lobbyTimer do
            Citizen.Wait(1000)
            local count = table.count(ffa_game.players)

            if count == 0 then
                break
            end

            for user_id, info in pairs(ffa_game.players) do
                local player = info.player
                local data = vRP.getUserDataTable({user_id})
                if GetPlayerName(player) == nil or data == nil then
                    ffa_game.players[user_id] = nil 
                end
            end
            GlobalState["ffaPlayers"] = table.count(ffa_game.players)
            GlobalState["ffaLobbyTimer"] = (ffa_game.lobbyTimer - os.time())
        end

        local count = table.count(ffa_game.players)
        if count == 0 then
            ffa_game.inLobby = false
            ffa_game.lobbyTimer = 0
            ffa_game.players = {}
            return
        end

        if count < cfg.ffaConfig.minPlayersToStart then
            ffa_game.inLobby = false
            ffa_game.lobbyTimer = 0
            for user_id, info in pairs(ffa_game.players) do
                local player = info.player

                Player(player).state.inFFA = false

                TriggerClientEvent("machiamavlad:setPlayerOutOfLobby", player)
                TriggerClientEvent("chatMessage", player, "^7[^6FFA^7]: ^7Din pacate nu s-au strans suficienti jucatori pentru a incepe meciul de FFA.")
            end
            ffa_game.players = {}
        else
            ffa_game.started = true
            ffa_game.map = math.random(1, #cfg.ffaConfig.arenas)

            GlobalState["ffaLobbyTimer"] = 0

            spawnLoc = 1
            for user_id, info in pairs(ffa_game.players) do
                local player = info.player
                local data = vRP.getUserDataTable({user_id})
                if GetPlayerName(player) == nil or data == nil then
                    GlobalState["ffaPlayers"] = table.count(ffa_game.players)
                    ffa_game.players[user_id] = nil 
                else
                    local posSpawn = cfg.ffaConfig.arenas[ffa_game.map].spawns[spawnLoc]

                    ffa_game.players[user_id].oldWeapons = data.weapons
                    vRPclient.removeWeapons(player, {})
                    TriggerClientEvent("machiamavlad:setPlayerOutOfLobby", player)
                    TriggerClientEvent("machiamavlad:setInPaintballArena", player, {
                        spawnLoc = posSpawn,
                        arena = cfg.ffaConfig.arenas[ffa_game.map].pos
                    })
                    TriggerClientEvent("machiamavlad:toggleFFABlips", player)

                    Player(player).state.paint_kills = 0
                    Player(player).state.paint_deaths = 0
                    SetPlayerRoutingBucket(player, cfg.ffaConfig.virtualWorldId)
                    spawnLoc = spawnLoc + 1
                    if spawnLoc > #cfg.ffaConfig.arenas[ffa_game.map].spawns then
                        spawnLoc = 1
                    end

                end
            end

            Citizen.SetTimeout(5000, function() 
                for user_id, info in pairs(ffa_game.players) do
                    local player = info.player
                    for wbody, wammo in pairs(cfg.ffaConfig.weapons) do
                        vRPclient.giveWeapon(player, {wbody, wammo})
                    end
                    vRPclient.notify(player, {"Ai primit pachetul de arme pentru FFA."})
                end
                
                Citizen.Wait(4000)
                
                ffa_game.gameTimer = os.time() + cfg.ffaConfig.gameDuration
                
                GlobalState["ffa_gameTimer"] = cfg.ffaConfig.gameDuration
                GlobalState["ffaPlayers"] = table.count(ffa_game.players)

                while ffa_game.started and os.time() <= ffa_game.gameTimer do
                    local s = (ffa_game.gameTimer - os.time())
                    local mr = math.floor(s / 60)
                    local sr = s % 60

                    GlobalState["ffa_gameTimer"] = string.format("%02d:%02d", tonumber(mr), tonumber(sr))
                    Citizen.Wait(1000)
                end

                --TriggerClientEvent("chatMessage", -1, "^7[^6FFA^7]: ^7Meciul de ^6FFA^7 s-a incheiat.")
                if table.count(ffa_game.players) > 0 then
                    local tempPlayers = {}
                    local bestPlayer = nil
                    for user_id, info in pairs(ffa_game.players) do
                        local player = info.player
                        table.insert(tempPlayers, player)
                    end
    
                    table.sort(tempPlayers, function(a, b) 
                        return (Player(a).state.paint_kills or 0) > (Player(b).state.paint_kills or 0)
                    end)
    
                    bestPlayer = tempPlayers[1]
    
                    TriggerClientEvent("chatMessage", -1, "^7• ^6FFA BP^7 >> ^6"..GetPlayerName(bestPlayer).." "..vRP.getUserId({bestPlayer}).."^7 >> ^6"..Player({bestPlayer}).state.paint_kills.." KILLS •")
    
                    for user_id, info in pairs(ffa_game.players) do
                        local player = info.player
                        if GetPlayerName(player) ~= nil then
                            vRPclient.removeWeapons(player, {})
                            Player(player).state.inFFA = false
                            Player(player).state.paint_kills = 0
                            Player(player).state.paint_deaths = 0
    
                            TriggerClientEvent("machiamavlad:setPlayerOutOfArena", player)
                            SetPlayerRoutingBucket(player, 0)
                            TriggerClientEvent("machiamavlad:remoteCode", player, [[
                                local ped = PlayerPedId()
                                local x, y, z = ]].. (paintPosition.x .. ", " .. paintPosition.y .. ", " .. paintPosition.z) ..[[
                                
                                DoScreenFadeOut(1000)
                                Citizen.Wait(2000)
                                tvRP.teleport({x, y, z})
                                RequestCollisionAtCoord(x, y, z)
                                SetEntityCoords(ped, x + 0.0001, y + 0.0001, z + 5.0000, 1, 0, 0, 1)
                                SetEntityInvincible(ped, false)
                                tvRP.setRagdoll({false})
                                NetworkResurrectLocalPlayer(x, y, z + 1.0, true, true, false)
                                FreezeEntityPosition(ped, false)
                                Citizen.Wait(500)
                                DoScreenFadeIn(300)
                            ]])
    
                            if next(info.oldWeapons) ~= nil then
                                local ol = info.oldWeapons
                                local data = vRP.getUserDataTable({user_id})
                                if data then
                                    data.weapons = ol
    
                                    vRPclient.giveWeapons(player, {ol})
                                    vRPclient.notify(player, {"Ti-ai recuperat armele vechi."})
                                end
                            end
                        end
                    end
                end


                ffa_game.players = {}
                ffa_game.started = false
                ffa_game.inLobby = false
                ffa_game.lobbyTimer = 0
                ffa_game.map = 0
                ffa_game.gameTimer = 0
                GlobalState["ffa_gameTimer"] = 0
                GlobalState["ffaPlayers"] = 0
            end)
        end
    end)
end

local function choose_freeforall(player, choice)
    local user_id = vRP.getUserId({player})
    if user_id then
        local data = vRP.getPlayerData({user_id})
        if ffa_game.started then
            vRPclient.notify(player, {"Deja a inceput meciul de FFA."})
            return
        end

        if ffa_game.players[user_id] then
            vRPclient.notify(player, {"Deja esti intr-un meci de FFA."})
            return
        end

        if activeDuelRequests[user_id] then
            vRPclient.notify(player, {"Nu poti sa te alaturi unui meci de FFA cat timp ai o cerere de duel in asteptare ^1(/cancelduel)^0."})
            return
        end
        
        ffa_game.players[user_id] = {player = player, oldWeapons = {}}
        TriggerClientEvent("chatMessage", player, "[^6FFA^7]: ^7Te-ai alaturat lobbyului arenei de ^6FFA^7.")
        TriggerClientEvent("machiamavlad:setPlayerInArenaLobby", player)
        Player(player).state.inFFA = true

        if not ffa_game.inLobby then
            tryStartPaintballLobby()
        end
        
        vRP.closeMenu({player})
    end
end

RegisterCommand("leavepaint", function(player, args) 
    local user_id = vRP.getUserId({player})
    if user_id then
        if not ffa_game.started then
            vRPclient.notify(player, {"Momentan nu este niciun meci de FFA in desfasurare."})
            return
        end

        if not ffa_game.players[user_id] then
            vRPclient.notify(player, {"Nu te afli intr-un meci de FFA."})
            return
        end

        vRPclient.removeWeapons(player, {})
        Player(player).state.inFFA = false;
        Player(player).state.paint_kills = 0;
        Player(player).state.paint_deaths = 0;

        TriggerClientEvent("machiamavlad:setPlayerOutOfArena", player)
        SetPlayerRoutingBucket(player, 0)
        TriggerClientEvent("machiamavlad:remoteCode", player, [[
            local ped = PlayerPedId()
            local x, y, z = ]].. (paintPosition.x .. ", " .. paintPosition.y .. ", " .. paintPosition.z) ..[[
            
            DoScreenFadeOut(1000)
            Citizen.Wait(2000)
            tvRP.teleport({x, y, z})
            RequestCollisionAtCoord(x, y, z)
            SetEntityCoords(ped, x + 0.0001, y + 0.0001, z + 5.0000, 1, 0, 0, 1)
            SetEntityInvincible(ped, false)
            tvRP.setRagdoll({false})
            NetworkResurrectLocalPlayer(x, y, z + 1.0, true, true, false)
            FreezeEntityPosition(ped, false)
            Citizen.Wait(500)
            DoScreenFadeIn(300)
        ]])

        ffa_game.players[user_id] = nil
        vRPclient.notify(player, {"Ai parasit arena de FFA."})
    end
end)

local function build_pb_menu(player)
    local user_id = vRP.getUserId({player})
    if user_id then
        local menu = {name="Paintball",css={top="75px",header_color="32 100 156 / 30%"}}


        local isInGame = (Player(player).state.inFFA)

        if isInGame then
            if ffa_game.inLobby then
                menu["Paraseste Lobbyul"] = {
                    function(player, choice) 
                        vRP.closeMenu({player})
                        if ffa_game.started then
                            vRPclient.notify(player, {"Jocul in arena FFA tocmai a inceput.."})
                            return
                        end

                        TriggerClientEvent("chatMessage", player, "[^6FFA^7]: ^7Ai parasit lobbyul arenei de ^6FFA^7.")
                        TriggerClientEvent("machiamavlad:setPlayerOutOfLobby", player)
                        if ffa_game.players[user_id] then
                            ffa_game.players[user_id] = nil
                        end
                        Player(player).state.inFFA = false
                    end,
                    "<font style='color: var(--color-chat-8); font-size: 1.8vh'>Paraseste Lobbyul</font><br/><br/>Paraseste lobbyul arenei de FFA."
                }
            end
        else
            menu["[FFA] Free for all"] = {choose_freeforall, 
            [[
                <font style='color: var(--color-chat-8); font-size: 2vh;'>Free for all</font>
                <br/>
                <font style='font-size: 1.4vh;'>Alatura-te unui meci de FFA <b style='color: var(--color-chat-5);'>free for all</b>.</font>
                <br/>
                <br/>
                <font style='font-size: 1.5vh; font-weight: bold;'>Arme disponibile</font>
                <style>
                    li::marker {
                        opacity: 0;
                    }
                </style
                <li>
                    <ul>Bata</ul>
                    <ul>Pistol .50</ul>
                    <ul>Assault Rifle</ul>
                    <ul>Pump Shotgun</ul>
                </li>
            ]]}
            --"<font style='color: var(--color-chat-8);'>Free for all</font><br/><br/>Alatura-te unui meci de paintball care este in desfasurare sau intra in asteptarea unui meci de paintball."
            menu["[1V1] Duel"] = {choose_duel, 
            [[
                <font style='color: var(--color-chat-8); font-size: 2vh;'>1VS1 Duel</font>
                <br/>
                <font style='font-size: 1.4vh;'>Invita un jucator din preajma ta la un duel.</font>
            ]]}
            --"<font style='color: var(--color-chat-5);'>Duel</font><br/><br/>Invita la un duel un jucator din aproprierea arenei de paintball.",
        end

        vRP.openMenu({player, menu});
    end
end

local function build_player_pb_entry(player)
    local user_id = vRP.getUserId({player})
    if user_id then
        local x, y, z = table.unpack(paintPosition)
        
        local function pb_entry(player, area)
            build_pb_menu(player)
            -- vRPclient.notify(player, {"Acest sistem o sa fie adaugat in curand pe server!"})
        end
        
        local function pb_leave(player, area) end

        vRPclient.addMarker(player, {x, y, z - 1.3, 0.5, 0.5, 0.7, 0, 32, 100, 156, 7.5, 42})
        vRPclient.addMarkerNames(player, {x, y, z + 0.3, "FFA", 1.0, 0})
        vRPclient.addBlip(player, {x, y, z, 150, 30, "FFA Arena", 1.0})

        vRP.setArea({player, "FFA Arena", x, y, z, 1, 1.5, pb_entry, pb_leave})
    end
end

local function handle_player_spawn(user_id, player, first_spawn)
    if first_spawn then
        build_player_pb_entry(player)    

        Player(player).state.inFFA = false
        Player(player).state.inDuel = false
    end
end
AddEventHandler("vRP:playerSpawn", handle_player_spawn)

local storedNames = {}
local function handleWeaponDamage(player, args)
    if not ffa_game.started then return end
    local damage = tonumber(args.weaponDamage)
    local victim = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(args.hitGlobalId))

    if not Player(player).state.inFFA then return end
    if not Player(victim).state.inFFA then return end

    if damage < 0 then
        damage = 0
    elseif damage >= 125 then
        damage = 125
    end

    if GetPlayerName(victim) == nil then
        return
    else
        if storedNames[victim] == nil then
            storedNames[victim] = GetPlayerName(victim)
        end
    end

    if GetPlayerName(player) == nil then 
        return
    else
        if storedNames[player] == nil then
            storedNames[player] = GetPlayerName(player)
        end
    end

    TriggerClientEvent("nzv:paint-dmgInfo", player, damage, storedNames[victim], "attacker")
    TriggerClientEvent("nzv:paint-dmgInfo", victim, damage, storedNames[player], "victim")
end
AddEventHandler("weaponDamageEvent", handleWeaponDamage)

local playerDeaths = {}
local alreadyDead = {}
RegisterServerEvent('machiamavlad:OnPlayerDied', function(...)
    local player = source
    local user_id = vRP.getUserId({player})
    if user_id then
        if alreadyDead[user_id] then return end
        alreadyDead[user_id] = true
        local args = {...}
        TriggerEvent("paintball:onPlayerDied", user_id, nuser_id, args[4])
        Citizen.SetTimeout(3000, function() 
            if alreadyDead[user_id] then 
                alreadyDead[user_id] = nil 
            end
        end)
    end
end)
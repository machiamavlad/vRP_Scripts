-----------------------------------------------------------------------
--           Cine fura ma-sa-i curva, semnat machiamavlad.           --
--               www.fantasyrp.ro | fivem.fantasyrp.ro               --
--                      discord.fantasyrp.ro                         --
-----------------------------------------------------------------------
--                  _._     _,-'""`-._                               --
--                  (,-.`._,'(       |\`-/|                          --
--                      `-.-' \ )-`( , o o)                          --
--                            `-    \`_`"'-                          --
-----------------------------------------------------------------------

function vRP.sendStaffMessage(msg)
    for k, v in pairs(vRP.rusers) do
        local ply = vRP.getUserSource(tonumber(k))
        if vRP.isUserTrialHelper(user_id) and ply then
            TriggerClientEvent("chatMessage", ply, "^1System: ^0"..msg)
        end
    end
end

-- Tickets
local delayTickets = 300 -- delay in secunde
local adminTickets = {}

local function countTable(table)
    local total = 0
    if type(table) == "table" then
        for _,__ in pairs(table) do
            total = total + 1
        end
    end
    return total
end

local function canCreateTicket(user_id, player)
    local adminsOnline = false
    local players = vRP.getUsers()
    local playerName = GetPlayerName(player)
    adminTickets[user_id] = {
        playerName = playerName,
        expireTime = os.time() + delayTickets
    }
    for nuser_id, player in pairs(players) do
        player = vRP.getUserSource(nuser_id)
        if player then
            local isAdmin = vRP.isUserTrialHelper(nuser_id)
            if isAdmin then
                TriggerClientEvent("chatMessage", player, "^1Tickets: ^0Ticket nou creeat de catre jucatorul "..playerName.."("..user_id..")")
                if not adminsOnline then
                    adminsOnline = true
                end
            end
        end
    end

    if not adminsOnline then
        adminTickets[user_id] = nil
    else
        vRPclient.notify(player, {'Ai creeat un ticket, asteapta ca un membru staff sa-ti accepte ticket-ul.'})
        TriggerClientEvent("TicketsUpdate", -1, countTable(adminTickets))
    end
    return adminsOnline
end

local function canTakeTicket(player, user_id, nuser_id)
    local canTakeTicket = false
    local playerName = GetPlayerName(player)
    if adminTickets[nuser_id] then
        local nplayer = vRP.getUserSource(nuser_id)
        local nplayerName = adminTickets[nuser_id].playerName
        if nplayer then
            local ped = GetPlayerPed(nplayer)
            local coords = GetEntityCoords(ped)
            vRPclient.teleport(player, {coords.x, coords.y, coords.z})
            vRPclient.notify(nplayer, {"Adminul ~y~"..playerName.."~w~ ti-a preluat ticket-ul, descrie-i problema intampinata."})

            vRP.sendStaffMessage("Adminul ^1"..playerName.."("..user_id..")^0 i-a preluat ticket-ul jucatorului ^1"..nplayerName.."("..nuser_id..")^0.")

            exports.ghmattimysql:execute("UPDATE vrp_users SET raport = raport + 1 WHERE id = @user_id", {
                ["@user_id"] = user_id
            });
            adminTickets[nuser_id] = nil;
            canTakeTicket = true
            TriggerClientEvent("TicketsUpdate", -1, countTable(adminTickets))
        else
            canTakeTicket = false
        end
    end
    return canTakeTicket
end

RegisterCommand("tk", function(player, args, rawCommand)
    local user_id = vRP.getUserId(player)
    if user_id then
        local isAdmin = vRP.isUserTrialHelper(user_id)
        if isAdmin then
            local ticketCount = countTable(adminTickets)
            if ticketCount > 0 then
                local nuser_id = 0
                for k, v in pairs(adminTickets) do
                    if adminTickets[k] then
                        nuser_id = k
                    end
                end
                if nuser_id ~= 0 then
                    if not canTakeTicket(player,user_id, nuser_id) then
                        vRPclient.executeCommand(player, {"tk"})
                    end
                else
                    vRPclient.executeCommand(player, {"tk"})
                end
            else
                TriggerClientEvent("chatMessage", player, "^1Eroare: ^0In momentul de fata nu este niciun ticket activ.")
            end
        else
            TriggerClientEvent("chatMessage", player, "^1Eroare: ^0Nu ai acces la aceasta comanda.")
        end
    end
end)

RegisterCommand("tklist", function(player)
    local user_id = vRP.getUserId(player)
    local isAdmin = vRP.isUserTrialHelper(user_id)
    if isAdmin then
        local ticketCount = countTable(adminTickets)
        if ticketCount > 0 then
            TriggerClientEvent("chatMessage", player, "= Lista tickete active =")
            for k, v in pairs(adminTickets) do
                TriggerClientEvent("chatMessage", player, "^1* "..v.playerName.."("..k..") - expire: "..os.date("%H:%M:%S ", v.expireTime))
            end
        else
            TriggerClientEvent("chatMessage", player, "^1Eroare: ^0In momentul de fata nu este niciun ticket activ.")
        end
    else
        TriggerClientEvent("chatMessage", player, "^1Eroare: ^0Nu ai acces la aceasta comanda.")
    end
end)

RegisterCommand("+calladmin", function(player, args, rawCommand)
    local user_id = vRP.getUserId(player)
    local isStaff = vRP.isUserTrialHelper(user_id)
    if user_id then
        if not isStaff or user_id == 21 or user_id == 1 or user_id == 2 then
            if not adminTickets[user_id] then
                if not canCreateTicket(user_id, player) then
                    vRPclient.notify(player, {"~r~Niciun membru staff nu este conectat."})
                end
            else
                if adminTickets[user_id].createdTime or 0 > os.time() then
                    vRPclient.notify(player, {"~r~Deja ai un ticket activ!"})
                else
                    adminTickets[user_id] = nil
                    vRPclient.executeCommand(player, {"+calladmin"})
                end
            end
        else
            vRPclient.notify(player, {"~r~Nu poti creea un ticket ca membru staff."})
        end
    end
end)


AddEventHandler("vRP:playerLeave", function(user_id, player)
    if adminTickets[user_id] then
        adminTickets[user_id] = nil
        TriggerClientEvent("TicketsUpdate", -1, countTable(adminTickets))
    end
end)

vRP.registerMenuBuilder("main", function(add, data)
    local user_id = vRP.getUserId(data.player)
    if user_id ~= nil then
        local choices = {}
        
        choices["Admin"] = {function(player, choice)
            vRP.buildMenu("admin", {player = player}, function(menu)
                menu.name = "Admin"
                menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                menu.onclose = function(player)vRP.closeMenu(player) end

                menu["Admin Ticket"] = {function(player, choice) 
                    vRPclient.executeCommand(player, {"+calladmin"})
                end}
                
                vRP.openMenu(player, menu)
            end)
        end}
        
        add(choices)
    end
end)
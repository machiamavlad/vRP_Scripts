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

local vipConfig = {

    [1] = {title = "Bronze", salary = 1000},
    [2] = {title = "Silver", salary = 2000},
    [3] = {title = "Gold", salary = 3000},
    [4] = {title = "Diamond", salary = 4000}

}




function vRP.getVipTitle(vipRank)
    if type(vipRank) ~= "number" then return "" end
    if not vipConfig[vipRank] then return "" end

    return tostring(vipConfig[vipRank].title)
end

function vRP.getVipSalary(vipRank)
    if type(vipRank) ~= "number" then return 0 end
    if not vipConfig[vipRank] then return 0 end

    return tonumber(vipConfig[vipRank].salary)
end

function vRP.getVipLvl(user_id)
    local tmpData = vRP.getUserTmpTable(user_id)
    if tmpData then
        return tmpData.vipLvl
    end
    return 0
end

function vRP.setUserVip(user_id, vip, days)
    local days = days or -1
    local tmp = vRP.getUserTmpTable(user_id)
    if days ~= -1 then
        days = os.time() + (86400 * days)
    end
    if tmp then
        tmp.vipLvl = vip
        tmp.vipTime = days
    end

    exports.ghmattimysql:execute("UPDATE vrp_users SET vipLvl = @vipLvl, vipTime = @vipTime WHERE id = @user_id", {
        ["@vipLvl"] = vip,
        ["@vipTime"] = days,
        ["@user_id"] = user_id
    })
end

for k,v in pairs(vipConfig) do
    vRP["isUserVip"..v.title] = function(user_id)
        local vipRank = vRP.getVipLvl(user_id)
        if vipRank == k then
            return true
        end
        return false
    end
end

local function ch_addVip(player,args,rawMsg)
    local user_id = vRP.getUserId(player)
    if user_id then
        local isAdmin = vRP.hasPermission(user_id, "permisie")
        if isAdmin then
            vRP.prompt(player, "ID:", "", function(player,nuser_id)
                local nuser_id = parseInt(nuser_id)
                if nuser_id ~= nil and nuser_id > 0 then
                    local pName = tostring(exports.ghmattimysql:executeSync('SELECT username FROM vrp_users WHERE id = @user_id', {user_id = nuser_id})[1].username)
                    if pName ~= nil then
                        vRP.prompt(player, "VIP: (0 - "..(#vipConfig)..")", "", function(player, vipLvl)
                            local vipLvl = parseInt(vipLvl)
                            if vipLvl ~= nil then
                                if tonumber(vipLvl) > 0 and vipLvl <= #vipConfig then
                                    vRP.prompt(player, "Durata:", "(-1 = permanent | durata trebuie specificata in zile)", function(player, days)
                                        local days = tonumber(days) or -1
                                        if days then
                                            local durr = ""
                                            if days == -1 then
                                                durr = "permanent"
                                            else
                                                durr = days.." zi(le)"
                                            end
                                            local nplayer = vRP.getUserSource(nuser_id)
                                            if nplayer then
                                                vRPclient.notify(nplayer, {"Ai primit gradul de ~g~VIP "..vRP.getVipTitle(vipLvl).."~w~ de la adminul ~r~"..GetPlayerName(player).."["..user_id.."]~w~!~n~Durata: ~y~"..durr})
                                            end
                                            vRPclient.notify(player, {"I-ai dat gradul de ~g~VIP "..vRP.getVipTitle(vipLvl).."~w~ jucatorului ~r~"..pName.."["..nuser_id.."]~n~~w~Durata: ~y~"..durr})
                                            vRP.setUserVip(nuser_id, vipLvl, days)
                                        else
                                            vRPclient.notify(player, {"~r~Durata specificata este invalida!"})
                                        end
                                    end)
                                else
                                    local nplayer = vRP.getUserSource(nuser_id)
                                    if nplayer then
                                        vRPclient.notify(nplayer, {"Gradul de ~r~VIP "..vRP.getVipTitle(vRP.getVipLvl(nuser_id)).."~w~ ti-a fost scos de catre adminul ~g~"..GetPlayerName(player).."~w~."})
                                    end
                                    vRPclient.notify(player, {"I-ai scos gradul de ~r~VIP "..vRP.getVipTitle(vRP.getVipLvl(nuser_id)).."~w~ jucatorului ~g~"..pName.."["..nuser_id.."]~w~!"})
                                    vRP.setUserVip(nuser_id, 0, 0)
                                end
                            else
                                vRPclient.notify(player, {"~r~Valoare invalida!"})
                            end
                        end)
                    else
                        vRPclient.notify(player, {"~r~Acest jucator nu a fost gasit in baza de date!"})
                    end
                else
                    vRPclient.notify(player, {'~r~Acest jucator nu este conectat!'})
                end
            end)
        else
            vRPclient.notify(player, {"~r~Nu ai acces la aceasta comanda."})
        end
    end
end
RegisterCommand("+addVip", ch_addVip)

vRP.registerMenuBuilder("admin", function(add, data)
    local user_id = vRP.getUserId(data.player)
    if user_id ~= nil then
        local choices = {}

        if vRP.hasPermission(user_id, "permisie") then
            choices["Add/Remove VIP"] = {function(player, choice) 
                vRPclient.executeCommand(player, {"+addVip"})
            end}
        end

        add(choices)
    end
end)

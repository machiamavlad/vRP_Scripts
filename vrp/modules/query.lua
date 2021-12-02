AddEventHandler("vRP:playerJoin", function(user_id, player, name)
    local tmp = vRP.getUserTmpTable(user_id) or {}
    local dataPlayer = exports.ghmattimysql:executeSync('SELECT * FROM vrp_users WHERE id = @user_id', {user_id = user_id})[1]
    if tmp then
        local pVip = tonumber(dataPlayer.vipLvl) or 0
        local pVipTime = tonumber(dataPlayer.vipTime) or 0

        tmp.vipLvl = pVip;
        tmp.vipTime = pVipTime;
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    local tmp = vRP.getUserTmpTable(user_id)
    if first_spawn then
        local actTime = os.time()
        local pIsAdmin = vRP.hasPermission(user_id, "admin.tickets")
        local pVip = tonumber(tmp.vipLvl) or 0
        local pVipTime = tonumber(tmp.vipTime) or 0
        local pAdminLevel = tonumber(tmp.adminLvl) or 0

        if pVip > 0 then
            if pVipTime ~= -1 and pVipTime > 0 then
                if actTime > pVipTime then
                    vRPclient.notify(player, {"Statutul tau de ~g~VIP "..vRP.getVipTitle(pVip).."~w~ tocmai a expirat!"})
                    tmp.vipLvl = 0;
                    tmp.vipTime = 0;
                    exports.ghmattimysql:execute('UPDATE vrp_users SET vipTime = 0, vipLvl = 0 WHERE id = @user_id', {user_id = user_id})
                else
                    local daysUntil = math.floor(tonumber((pVipTime - actTime) / 60))
                    local bString = returnDays(daysUntil)
                    vRPclient.notify(player, {"Detii statutul de ~g~VIP "..vRP.getVipTitle(pVip).." acesta expira in ~b~"..bString.."~w~!"})
                end
            else
                vRPclient.notify(player, {"Detii statutul de ~g~VIP "..vRP.getVipTitle(pVip).." permanent!"})
            end
        end
        if pIsAdmin then
            vRPclient.setAdmin(player, {})
        end
    end
end)
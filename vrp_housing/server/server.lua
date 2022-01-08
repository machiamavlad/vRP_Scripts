local houses = {}
inHouse = {}
refreshTables = function(player)
    exports.ghmattimysql:execute('SELECT * FROM `housing`', {}, function(rows)
        if #rows > 0 then
            for k, v in pairs(rows) do
                if houses[v.id] == nil then houses[v.id] = {} end
                if houses[v.id] then houses[v.id] = {} end
                
                houses[v.id] = {
                    id = v.id,
                    owner = tonumber(v.owner),
                    ownername = tostring(v.ownername) or '~b~Statul',
                    owned = v.owned,
                    price = v.price,
                    entry = json.decode(table.tovec(v.entry)),
                    type = v.type,
                    garage = json.decode(table.tovec(v.garage)) or {},
                    furniture = json.decode(v.furniture) or {},
                    shell = v.shell,
                    housekeys = v.housekeys,
                    wardrobe = json.decode(table.tovec(v.wardrobe)) or {},
                    chest = json.decode(table.tovec(v.chest)) or {}
                }
                TriggerClientEvent('machiamavlad:getHouse', (player or -1), {
                    id = houses[v.id].id,
                    owner = tonumber(houses[v.id].owner),
                    ownername = tostring(houses[v.id].ownername) or '~b~Statul',
                    owned = houses[v.id].owned,
                    price = houses[v.id].price,
                    entry = houses[v.id].entry,
                    type = houses[v.id].type,
                    garage = houses[v.id].garage or {},
                    furniture = houses[v.id].furniture or {},
                    shell = houses[v.id].shell,
                    housekeys = houses[v.id].housekeys,
                    wardrobe = houses[v.id].wardrobe or {},
                    chest = houses[v.id].chest or {}
                })
            end
        end
    end)
end

CreateThread(function()
    Wait(5000)
    refreshTables()
end)

hasUserHouse = function(user_id)
    -- for i = 1, #houses do
    for i, _ in pairs(houses) do
        if houses[i] ~= nil then
            if houses[i].owner == user_id then return true end
        end
    end
    -- end
    return false
end
RegisterCommand('fixhousing', function(src)
    local player = src
    local user_id = vRP.getUserId({player})
    if vRP.isUserFondator({user_id}) then
        refreshTables()
    end
end)

RegisterCommand('createHouse', function(src)
    local ped = GetPlayerPed(src)
    local heading = GetEntityHeading(ped)
    local user_id = vRP.getUserId({src})
    local player = vRP.getUserSource({user_id})
    if vRP.isUserFondator({user_id}) then
        vRP.prompt({player, "Shell casa:", "[Hotel,Apartment,Trailer,Trevor,Lester,Ranch,HighEndV1,HighEndV2,Michaels]", function(player, shell)
            shell = tostring(shell)
            if shell ~= nil and shell ~= '' and inTable(shell, shells) then
                vRP.prompt({player, "Pret casa:", "", function(player, price)
                    price = parseInt(price)
                    if price > 0 and price ~= nil then
                        vRP.prompt({player, "Tip Casa:", "", function(player, tipCasa)
                            local tipCasa = tostring(tipCasa)
                            if tipCasa ~= nil and tipCasa ~= '' then
                                local coords = GetEntityCoords(ped)
                                local encode = vector3(coords.x, coords.y, coords.z)
                                exports.ghmattimysql:executeSync("INSERT INTO housing SET owner=@owner,owned=@owned,price=@price,entry=@entry,garage=@garage,furniture=@furniture,shell=@shell,housekeys=@housekeys,type=@tipCasa,wardrobe=@wardrobe,chest=@chest", {
                                    ['@owner'] = 0,
                                    ['@owned'] = 0,
                                    ['@price'] = price,
                                    ['@entry'] = json.encode(encode),
                                    ['@garage'] = json.encode({}),
                                    ['@furniture'] = json.encode({}),
                                    ['@shell'] = GetShellData(shell:lower()), -- shells[shell:lower()]
                                    ['@housekeys'] = json.encode({}),
                                    ['@wardrobe'] = json.encode({}),
                                    ['@tipCasa'] = tipCasa,
                                    ['@chest'] = json.encode({})
                                })
                                -- Wait(5000)
                                refreshTables()
                            else
                                vRPclient.notify(player, {'~r~Tipul casei specificat este invalid!'})
                            end
                        end})
                    else
                        vRPclient.notify(player, {'~r~Pret-ul specificat este invalid!'})
                    end
                end})
            else
                vRPclient.notify(player, {'~r~Shell-ul specificat este invalid!'})
            end
        end})
    else
        vRPclient.notify(player, {'~r~Crezi ca ai acces gen?'})
    end
end)
vRPShousing.getHouseFurniture = function(houseId)
    if houses[houseId] then
        return houses[houseId].furniture or {}
    end
    return {}
end
vRPShousing.openHouseChest = function(d)
    local thePlayer = source
    local user_id = vRP.getUserId({thePlayer})
    if tonumber(houses[d].owner) == user_id then
        vRP.openChest({thePlayer, 'Chest casa: ' .. tonumber(d), 500, nil, nil, nil})
    else
        vRPclient.notify(thePlayer, {'~r~Nu esti detinatorul acestei case!'})
    end
end
vRPShousing.openHouseWardrobe = function(d)
    local player = source
    local user_id = vRP.getUserId({player})
    if tonumber(houses[d].owner) == user_id then
        local data = vRP.getUserDataTable({user_id})
        local menu = {name = 'Wardrobe Menu', css = {top = "75px", header_color = "rgba(255,255,255,1.0)"}}
        vRP.getSData({"Wardrobe_House_ID:" .. d, function(data)
            local sets = json.decode(data)
            if sets == nil then
                sets = {}
            end
            menu['@ Salveaza imbracamintea'] = {function(player, choice)
                vRP.prompt({player, 'Pune un nume acestei imbracaminte:', '', function(player, setname)
                    setname = tostring(setname)
                    if setname:len() > 0 and setname ~= nil then
                        exports.ghmattimysql:execute('SELECT `skin` FROM `vrp_users` WHERE id = @user_id', {user_id = user_id}, function(_)
                            if _[1].skin ~= 'New' then
                                sets[setname] = _[1].skin
                                vRP.setSData({"Wardrobe_House_ID:" .. d, json.encode(sets)})
                                vRPclient.notify(player, {'Ai salvat imbracamintea cu numele ~y~' .. setname})
                                vRP.closeMenu({player})
                            else
                                vRPclient.notify(player, {'~r~Imbracaminte invalida!'})
                            end
                        end)
                    else
                        vRPclient.notify(player, {'~r~Valoare invalida'})
                    end
                end})
            end}
            local choose_set = function(player, choice)
                local custom = sets[choice]
                if custom ~= nil then
                    TriggerClientEvent('raid_clothes:loadclothes', player, json.decode(custom))
                end
            end
            for k, v in pairs(sets) do
                menu[k] = {choose_set}
            end
            vRP.openMenu({player, menu})
        end})
    else
        vRPclient.notify(player, {'~r~Nu esti detinatorul acestei case!'})
    end
end
vRPShousing.openHouseMenu = function(d, sursa)
    local player = source
    local user_id = vRP.getUserId({player})
    local sursa = tostring(sursa)
    if user_id ~= nil then
        if not houses[d] then vRPclient.notify(player, {"~r~Aceasta casa nu exista!"}) return end
        if sursa == 'inside' then
            vRP.buildMenu({"Inside House Menu", {player = player}, function(menu)
                menu.name = "Inside House Menu"
                menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                menu.onclose = function(player)vRP.closeMenu({player}) end
                user_id = vRP.getUserId({player})
                if tonumber(user_id) == tonumber(houses[d].owner) then
                    menu["@ Mobileaza-ti casa"] = {function(player, choice)
                        TriggerClientEvent('machiamavlad_furni:openFurni', player)
                        vRP.closeMenu({player})
                    end, "Mobileaza-ti casa cu mobila pe placul tau cu mobila direct de la IKEA."}
                    menu["@ Seteaza Garderoba"] = {function(player, choice)
                        TriggerClientEvent('machiamavlad:setWardrobe', player, d)
                        vRP.closeMenu({player})
                    end, "Seteaza garderoba casei tale."}
                    menu["@ Seteaza Chest"] = {function(player, choice)
                        TriggerClientEvent('machiamavlad:setChest', player, d)
                        vRP.closeMenu({player})
                    end, "Seteaza chest-ul casei tale."}
                end
                menu["Paraseste casa"] = {function(player, choice)
                    TriggerClientEvent('machiamavlad:leaveHouse', player, d)
                    TriggerClientEvent('machiamavlad_furni:LeaveHouse', player)
                    inHouse[user_id] = 0
                    vRP.closeMenu({player})
                end, "Paraseste casa in care te aflii acum!"}
                vRP.openMenu({player, menu})
            end})
        elseif sursa == 'outside' then
            vRP.buildMenu({'Outside House Menu', {player = player}, function(menu)
                menu.name = 'Outside House Menu'
                menu.css = {top = "75px", header_color = "rgba(200,0,0,0.75)"}
                menu.onclose = function(player)vRP.closeMenu({player}) end
                user_id = vRP.getUserId({player})
                local msg = "<font color ='red'>Casa Nr. " .. houses[d].id .. "</font> <br/> <br/>Tip Casa <font color='green'>" .. houses[d].type .. "</font> <br/>"
                msg = msg .. "Detinator <font color='green'>" .. houses[d].ownername .. "[" .. houses[d].owner .. "]</font><br/>"
                if houses[d].price > 0 then
                    msg = msg .. "<br><u><font color='green'>DE VANZARE</font></u><br/>"
                    msg = msg .. "<font color='green'>" .. vRP.formatMoney({tonumber(houses[d].price)}) .. "$</font>"
                end
                if tonumber(user_id) == tonumber(houses[d].owner) then
                    menu['Intra in casa'] = {function(player, choice)
                        vRP.closeMenu({player})
                        TriggerClientEvent('machiamavlad:enterHouse', player, d, false)
                        TriggerClientEvent('machiamavlad_furni:EnterHouse', player, houses[d])
                        inHouse[user_id] = d
                    end, 'Intra in casa'}
                    if houses[d].price > 0 then
                        menu['Scoate casa de la vanzare'] = {function(player, choice)
                            exports.ghmattimysql:execute("UPDATE `housing` SET `price` = @price WHERE `id` = @houseId", {houseId = tonumber(d), price = 0})
                            houses[d].price = 0
                            vRPclient.notify(player, {'Ti-ai scos ~g~Casa~w~ de la vanzare!'})
                            TriggerClientEvent("machiamavlad:getHouse", -1, houses[d])
                            vRP.closeMenu({player})
                        end, 'Scoate de la vanzare <font color="yellow">Casa Nr. ' .. d .. '</font>!'}
                    end
                    if houses[d].price == 0 then
                        menu['Pune casa la vanzare'] = {function(player, choice)
                            vRP.prompt({player, 'Te rog sa introduci suma pentru care vrei sa vinzi casa: ', '', function(player, amount)
                                amount = tonumber(amount)
                                if amount ~= nil and amount > 0 then
                                    if amount >= 10000 and amount <= 100000000 then
                                        exports.ghmattimysql:execute("UPDATE `housing` SET `price` = @price WHERE `id` = @houseId", {houseId = tonumber(d), price = tonumber(amount)})
                                        houses[d].price = tonumber(amount)
                                        vRPclient.notify(player, {'Ai scos ~y~Casa Nr. ' .. d .. '~w~ la vanzare pentru suma de ~g~' .. vRP.formatMoney({amount}) .. '$'})
                                        TriggerClientEvent("machiamavlad:getHouse", -1, houses[d])
                                        vRP.closeMenu({player})
                                    else
                                        vRPclient.notify(player, {'~r~Suma trebuie sa fie cuprinsa intre ~g~10.000$ si 100.000.000$!'})
                                        vRP.closeMenu({player})
                                    end
                                else
                                    vRPclient.notify(player, {'~r~Suma specificata este invalida!'})
                                    vRP.closeMenu({player})
                                end
                            end})
                        end, 'Pune la vanzare <font color="yellow">Casa Nr. ' .. d .. '</font>!'}
                    end
                else
                    if houses[d].price > 0 then
                        if not hasUserHouse(user_id) then
                            menu['Cumpara aceasta casa'] = {function(player, choice)
                                exports.ghmattimysql:execute('SELECT price FROM `housing` WHERE id = @d', {d = tonumber(d)}, function(rows)
                                    if #rows > 0 then
                                        if rows[1].price > 0 then
                                            vRP.prompt({player, 'Esti sigur ca vrei sa cumperi aceasta casa de la ' .. houses[d].ownername .. '?', '[sterge si scrie "da" pentru a continua]', function(player, raspuns)
                                                raspuns = tostring(raspuns)
                                                if raspuns == 'da' or raspuns == 'nu' then
                                                    if houses[d].price > 0 then
                                                        if vRP.tryFullPayment({user_id, houses[d].price}) then
                                                            if houses[d].owner ~= 0 then
                                                                local nid = houses[d].owner
                                                                local nplayer = vRP.getUserSource({nid})
                                                                if nplayer then
                                                                    vRPclient.notify(nplayer, {'~g~' .. GetPlayerName(player) .. '~w~ ti-a cumparat casa pentru suma de ~g~' .. vRP.formatMoney({houses[d].price})})
                                                                    vRP.giveBankMoney({nid, houses[d].price})
                                                                    vRP.addNewLog({user_id, 555, 'Jucatorul ' .. GetPlayerName(player) .. '[' .. user_id .. '] a cumparat casa #' .. tonumber(d) .. ' pentru pretul de ' .. vRP.formatMoney({houses[d].price}) .. '$'})
                                                                -- log sell house
                                                                else
                                                                    exports.ghmattimysql:execute('UPDATE `vrp_users` SET `bankMoney` = `bankMoney` + @amount WHERE id = @id', {id = nid, amount = houses[d].price})
                                                                end
                                                            end
                                                            exports.ghmattimysql:execute("UPDATE `housing` SET price = @price, owner = @newUser, owned = @state, ownername = @ownerName WHERE id = @houseId", {
                                                                houseId = tonumber(d),
                                                                price = 0,
                                                                newUser = user_id,
                                                                state = 1,
                                                                ownerName = GetPlayerName(player)
                                                            })
                                                            vRPclient.notify(player, {'Ai cumparat ~y~Casa Nr. ' .. d .. '~w~ pentru suma de ~g~' .. vRP.formatMoney({houses[d].price}) .. '$~w~!'})
                                                            houses[d].owner = user_id
                                                            houses[d].price = 0
                                                            houses[d].ownername = GetPlayerName(player)
                                                            houses[d].owned = 1
                                                            TriggerClientEvent("machiamavlad:getHouse", -1, houses[d])
                                                            vRP.closeMenu({player})
                                                        else
                                                            vRPclient.notify(player, {'~r~Nu ai suficienti bani pentru a cumpara aceasta casa!'})
                                                            vRP.closeMenu({player})
                                                        end
                                                    else
                                                        vRPclient.notify(player, {'~r~Aceasta casa a fost deja vanduta!'})
                                                        vRP.closeMenu({player})
                                                    end
                                                else
                                                    vRPclient.notify(player, {'~r~Raspuns invalid, singurele raspunsuri valide sunt ~g~`da`~r~ si ~y~`nu`~r~!'})
                                                    vRP.closeMenu({player})
                                                end
                                            end})
                                        else
                                            vRPclient.notify(player, {'~r~Aceasta casa a fost deja vanduta!'})
                                            vRP.closeMenu({player})
                                        end
                                    end
                                end)
                            end, 'Cumpara <font color="yellow">Casa Nr. ' .. d .. '</font> pentru suma de <font color="green">' .. vRP.formatMoney({houses[d].price}) .. '$</font> <br/> Apasa <i><font color="cyan">ENTER</font></i> pentru a cumpara aceasta casa!'}
                        end
                    end
                    menu['Bate la usa'] = {function(player, choice)
                        local nuser_id = houses[d].owner
                        local nplayer = vRP.getUserSource({nuser_id})
                        vRPclient.notify(player, {'Bati la usa...'})
                        vRP.closeMenu({player})
                        SetTimeout(math.random(5000, 7500), function()
                            if nplayer then
                                vRP.request({nplayer, '<font color="yellow">' .. GetPlayerName(player) .. '</font> iti bate la usa. Ii deschizi?', 1000, function(nplayer, ok)
                                    if (ok) then
                                        TriggerClientEvent('machiamavlad:enterHouse', player, d, false)
                                        inHouse[user_id] = d
                                    else
                                        vRPclient.notify(player, {'~r~Proprietarul casei a ales sa nu iti deschida usa!'})
                                    end
                                end})
                            else
                                vRPclient.notify(player, {'~r~Se pare ca nimeni nu este acasa!'})
                            end
                        end)
                    end, ''}
                end
                menu['# Informatii Casa #'] = {function(player, choice)
                    end, msg}
                vRP.openMenu({player, menu})
            end})
        end
    end
end
vRPShousing.closeAllMenus = function()
    local thePlayer = source
    vRP.closeMenu({thePlayer})
end
RegisterServerEvent('machiamavlad:SetChest')
AddEventHandler('machiamavlad:SetChest', function(d, vecCoords)
    local thePlayer = source
    local user_id = vRP.getUserId({thePlayer})
    local newCoords = vector3(vecCoords.x, vecCoords.y, vecCoords.z)
    if houses[d] then
        if tonumber(houses[d].owner) == user_id then
            newCoords = json.encode(newCoords)
            exports.ghmattimysql:execute("UPDATE `housing` SET `chest` = @coords WHERE `id` = @houseId", {houseId = tonumber(d), coords = newCoords})
            vRPclient.notify(thePlayer, {'~g~Ai actualizat pozitia chest-ului!'})
            Wait(2500)
        else
            end
    end
end)

RegisterServerEvent('machiamavlad:SetWardrobe')
AddEventHandler('machiamavlad:SetWardrobe', function(d, vecCoords)
    local thePlayer = source
    local user_id = vRP.getUserId({thePlayer})
    local newCoords = vector3(vecCoords.x, vecCoords.y, vecCoords.z)
    if houses[d] then
        if tonumber(houses[d].owner) == user_id then
            newCoords = json.encode(newCoords)
            exports.ghmattimysql:execute("UPDATE `housing` SET `wardrobe` = @coords WHERE `id` = @houseId", {houseId = tonumber(d), coords = newCoords})
            vRPclient.notify(thePlayer, {'~g~Ai actualizat pozitia garderobei!'})
            Wait(2500)
        else
            vRPclient.notify(thePlayer, {'~r~Nu poti sa setezi garderoba unei case pe care n-o deti!'})
        end
    end
end)
RegisterServerEvent('machiamavlad:RequestID')
AddEventHandler('machiamavlad:RequestID', function()
    local thePlayer = source
    local user_id = vRP.getUserId({thePlayer})
    TriggerClientEvent('machiamavlad:getId', thePlayer, tonumber(user_id))
end)
RegisterCommand('syncPlayer', function(player)
    local user_id = vRP.getUserId({player})
    local insideHouse = inHouse[user_id]
    if insideHouse > 0 then
        TriggerClientEvent('machiamavlad:RefreshFurniture', player, insideHouse)
    end
end)

AddEventHandler('vRP:playerSpawn', function(user_id, player, isFirstSpawn)
    if inHouse[user_id] == nil then inHouse[user_id] = 0 end
    if inHouse[user_id] > 0 then
        TriggerClientEvent('machiamavlad:leaveHouse', player, inHouse[user_id])
        if houses[inHouse[user_id]].owner == user_id then
            TriggerClientEvent('machiamavlad_furni:LeaveHouse', player)
        end
    end
    inHouse[user_id] = 0
    if isFirstSpawn then
        -- for d = 1, #houses do
        for d, _ in pairs(houses) do
            if houses[d] ~= nil then
                TriggerClientEvent('machiamavlad:getHouse', player, {
                    id = houses[d].id,
                    owner = tonumber(houses[d].owner),
                    ownername = tostring(houses[d].ownername) or '~y~Statul',
                    owned = houses[d].owned,
                    price = houses[d].price,
                    entry = houses[d].entry,
                    type = houses[d].type,
                    garage = houses[d].garage,
                    furniture = houses[d].furniture,
                    shell = houses[d].shell,
                    housekeys = houses[d].housekeys,
                    wardrobe = houses[d].wardrobe,
                    chest = houses[d].chest
                })
            end
        end
        -- end
    end
end)
SetFurni = function(house, furni)
    local v = houses[house.id]
    local entry = house.entry
    v.furniture = furni
    return
end
ReSyncGuests = function(hID)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local user_id = vRP.getUserId({playerId})
        -- print(inHouse[user_id],hID,GetPlayerName(playerId))
        if houses[hID].owner ~= user_id then
            if inHouse[user_id] == hID then
                -- print(GetPlayerName(playerId)..' resynced')
                TriggerClientEvent('machiamavlad:RefreshFurniture', playerId, hID)
            end
        end
        Wait(50)
    end
end
RegisterServerEvent('machiamavlad:requestHouses')
AddEventHandler('machiamavlad:requestHouses', function()
    for i, v in pairs(houses) do
        if houses[v.id] ~= nil then
            TriggerClientEvent('machiamavlad:getHouse', (source), {
                id = houses[v.id].id,
                owner = tonumber(houses[v.id].owner),
                ownername = tostring(houses[v.id].ownername) or '~b~Statul',
                owned = houses[v.id].owned,
                price = houses[v.id].price,
                entry = houses[v.id].entry,
                type = houses[v.id].type,
                garage = houses[v.id].garage or {},
                furniture = houses[v.id].furniture or {},
                shell = houses[v.id].shell,
                housekeys = houses[v.id].housekeys,
                wardrobe = houses[v.id].wardrobe or {},
                chest = houses[v.id].chest or {}
            })
        end
    end
end)

RegisterServerEvent('machiamavlad:SyncAllPlayers')
AddEventHandler('machiamavlad:SyncAllPlayers', ReSyncGuests)
AddEventHandler("machiamavlad:SetFurni", SetFurni)

CreateThread(function()
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local user_id = vRP.getUserId({playerId})
        inHouse[user_id] = 0
    end
    while true do
        -- for d = 1, #houses do
        for d, _ in pairs(houses) do
            if houses[d] ~= nil then
                TriggerClientEvent('machiamavlad:getHouse', -1, {
                    id = houses[d].id,
                    owner = tonumber(houses[d].owner),
                    ownername = tostring(houses[d].ownername) or '~b~Statul',
                    owned = houses[d].owned,
                    price = houses[d].price,
                    entry = houses[d].entry,
                    type = houses[d].type,
                    garage = houses[d].garage,
                    furniture = houses[d].furniture,
                    shell = houses[d].shell,
                    housekeys = houses[d].housekeys,
                    wardrobe = houses[d].wardrobe,
                    chest = houses[d].chest
                })
            end
        end
        -- end
        Wait(1800000)
    end
end)

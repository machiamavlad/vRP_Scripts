houseBlips = {}
RegisterNetEvent('machiamavlad:getHouse')
AddEventHandler('machiamavlad:getHouse',function(d)
	if tmpHouses[d.id] ~= {} or tmpHouses[d.id] ~= nil then tmpHouses[d.id] = {} end
	tmpHouses[d.id] = {
        id = d.id,
        owner = d.owner,
        ownername = d.ownername or '~b~Statul',
        owned = d.owned,
        price = d.price,
        entry = vector3(d.entry.x,d.entry.y,d.entry.z),
        type = d.type,
        garage = vector3(d.garage.x or 0.0,d.garage.y or 0.0,d.garage.z or 0.0),
        furniture = d.furniture,
        shell = d.shell,
        housekeys = d.housekeys,
        wardrobe = vector3(d.wardrobe.x or 0.0,d.wardrobe.y or 0.0,d.wardrobe.z or 0.0),
        chest = vector3(d.chest.x or 0.0,d.chest.y or 0.0,d.chest.z or 0.0)
	}
	while myIdentifier == -1 do Wait(5) end
	if houseBlips[d.id] then
		RemoveBlip(houseBlips[d.id])
	end
	houseBlips[d.id] = AddBlipForCoord(d.entry.x,d.entry.y,d.entry.z)
	SetBlipSprite(houseBlips[d.id],40)
	if tonumber(d.owner) == myIdentifier then
		SetBlipColour(houseBlips[d.id],2)
	else
		if d.price == 0 then
			SetBlipColour(houseBlips[d.id],1)
		else
			SetBlipColour(houseBlips[d.id],2)
		end
	end
	SetBlipScale(houseBlips[d.id],0.75)
	SetBlipAsShortRange(houseBlips[d.id],true)
	SetBlipDisplay(houseBlips[d.id],2)
    BeginTextCommandSetBlipName("STRING")
    if d.owned == 1 then
    	if d.price == 0 then
    		AddTextComponentString("Casa Locuita Nr. "..d.id)
    	else
    		AddTextComponentString("Casa Libera Nr. "..d.id)
    	end
    else
    	AddTextComponentString("Casa Libera Nr. "..d.id)
    end
    EndTextCommandSetBlipName(houseBlips[d.id])
end)


CreateThread(function()
	local ticks = 500
	while true do
		local ped = PlayerPedId()
		-- for i = 1 ,#tmpHouses do
		for i, _ in pairs(tmpHouses) do
			if tmpHouses[i] ~=nil then 
			if #(GetEntityCoords(ped) - tmpHouses[i].entry) < 10.0 then
				local x,y,z = table.unpack(tmpHouses[i].entry)
				draw3dtext(x,y,z + 0.6, 'Casa Nr. ~r~'..tmpHouses[i].id, 1.0, 1) 
				draw3dtext(x,y,z + 0.5, 'Tip Casa ~r~'..tmpHouses[i].type, 1.0, 4) 
				draw3dtext(x,y,z + 0.4, 'Proprietar ~y~'..tmpHouses[i].ownername, 1.0, 4) 
				if tmpHouses[i].price > 0 then
					draw3dtext(x,y,z + 0.2, "~y~DE VANZARE", 1.0, 4) 
					draw3dtext(x,y,z + 0.1, "~g~"..tmpHouses[i].price.."$", 1.0, 4) 
				end
				if #(GetEntityCoords(ped) - tmpHouses[i].entry) < 2.5 then
					draw3dtext(x,y,z + 0.7, 'Apasa [~y~E~w~] pentru a accesa meniul', 0.7, 0) 
					if IsDisabledControlJustPressed(0,38) then
						vRPShousing.openHouseMenu({tmpHouses[i].id,'outside'})
					end
				end
				ticks = 1
				end
			end
		end
		-- end
		Wait(ticks)
		ticks = 500
	end
end)

CreateThread(function()
	TriggerServerEvent('machiamavlad:requestHouses')
	while myIdentifier == -1 do
		TriggerServerEvent('machiamavlad:RequestID')
		Wait(2500)
	end
end)

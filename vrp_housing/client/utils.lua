Pressed = IsDisabledControlJustPressed
CreateThread = Citizen.CreateThread
Wait = Citizen.Wait


myIdentifier = -1
tmpHouses = {}
inHouse = {}
Keys = {
  ['G'] = 58,
  ['E'] = 38,
  ['LEFTCLICK'] = 24,
  ['RIGHTCLICK'] = 25,
}
vRP = Proxy.getInterface('vRP')
vRPShousing = Tunnel.getInterface('playerhousing','playerhousing')
houseInfo = {}
RegisterNetEvent('machiamavlad:enterHouse')
AddEventHandler('machiamavlad:enterHouse',function(houseId)
  houseId = tonumber(houseId)
end)
ShowNotification = function(t)
	vRP.notify({t})
end

TeleportInside = function(d,v)  
  local exitOffset = Shells[tmpHouses[d].shell].exit

  local plyPed = GetPlayerPed(-1)
  FreezeEntityPosition(plyPed,true)

  DoScreenFadeOut(1000)
  Wait(1500)

  ClearPedTasksImmediately(plyPed)

  local shell,extras = SpawnHouse(d)
  if shell and extras then
    SetEntityCoordsNoOffset(plyPed, tmpHouses[d].entry.x - exitOffset.x,tmpHouses[d].entry.y - exitOffset.y,tmpHouses[d].entry.z - exitOffset.z)

    local start_time = GetGameTimer()
    while (not HasCollisionLoadedAroundEntity(plyPed) and GetGameTimer() - start_time < 5000) do Wait(0); end
    FreezeEntityPosition(plyPed,false)

    DoScreenFadeIn(500)

    houseInfo[d] = {house = d,inside = true,visiting = v,shell = shell, extras = extras}
    inHouse = {
      house = d,
      inside = true,
      visiting = v,
      shell = shell,
      extras = extras,
      menu = {
        ['Exit'] = false,
        ['Wardrobe'] = false,
        ['Chest'] = false
      }
    }
    while houseInfo[d].inside do
      local ped = PlayerPedId()
      local coords = GetEntityCoords(ped)
      local nearExit = #(coords - vector3(tmpHouses[d].entry.x - exitOffset.x,tmpHouses[d].entry.y - exitOffset.y,tmpHouses[d].entry.z - exitOffset.z)) -- #(InsideHouse.Entry.xyz-InsideHouse.InventoryLocation+Config.SpawnOffset - pos)
      local nearWardrobe = #(coords - tmpHouses[d].wardrobe)
      local nearChest = #(coords - tmpHouses[d].chest)
      if nearExit < 5.0 then
        draw3dtext(tmpHouses[d].entry.x - exitOffset.x,tmpHouses[d].entry.y - exitOffset.y,tmpHouses[d].entry.z - exitOffset.z + 0.4, 'Apasa [~y~E~w~] pentru optiuni casa',1.0, 7) 
        if IsDisabledControlJustPressed(0,38) then
          if not inHouse.menu['Wardrobe'] then
            if not inHouse.menu['Chest'] then
              inHouse.menu['Exit'] = true
              vRPShousing.openHouseMenu({d,'inside'})
            else
              vRP.notify({"~r~Deja ai un meniu deschis"})
            end
          else
            vRP.notify({'~r~Deja ai un meniu deschis'})
          end
        end
      elseif nearExit > 5.0 and inHouse.menu['Exit'] then
        inHouse.menu['Exit'] = false
        vRPShousing.closeAllMenus({})
      end
      if nearWardrobe < 2.5 then
        draw3dtext(tmpHouses[d].wardrobe.x,tmpHouses[d].wardrobe.y,tmpHouses[d].wardrobe.z + 0.4,'Apasa [~y~E~w~] pentru a deschide garderoba',1.0, 7) 
        if Pressed(0,Keys['E']) then
          if not inHouse.menu['Exit'] then
            if not inHouse.menu['Chest'] then
              inHouse.menu['Wardrobe'] = true
              vRPShousing.openHouseWardrobe({d})
            else
              vRP.notify({"~r~Deja ai un meniu deschis"})
            end
          else
            vRP.notify({'~r~Deja ai un meniu deschis'})
          end
        end
      elseif nearWardrobe > 2.5 and inHouse.menu['Wardrobe'] then
        inHouse.menu['Wardrobe'] = false
        vRPShousing.closeAllMenus({})
      end
      if nearChest < 2.5 then
        draw3dtext(tmpHouses[d].chest.x,tmpHouses[d].chest.y,tmpHouses[d].chest.z + 0.4, 'Apasa [~y~E~w~] pentru a deschide chest-ul',1.0, 7) 
        if Pressed(0,Keys['E']) then
          if not inHouse.menu['Exit'] then
            if not inHouse.menu['Wardrobe'] then
              inHouse.menu['Chest'] = true
              vRPShousing.openHouseChest({d})
            else
              vRP.notify({"~r~Deja ai un meniu deschis"})
            end
          else
            vRP.notify({'~r~Deja ai un meniu deschis'})
          end
        end
      elseif nearWardrobe > 2.5 and inHouse.menu['Chest'] then
        inHouse.menu['Chest'] = false
        vRPShousing.closeAllMenus({})
      end
      Wait(0)
    end
  else
    FreezeEntityPosition(plyPed,false)
    DoScreenFadeIn(500)
  end
end


-- @info casa: houseInfo[d] = {house = d,inside = true,visiting = v,shell = shell, extras = extras}
LeaveHouse = function(d)
  -- while tmpHouses[d] == nil do Wait(5000) vRP.notify({'Aceasta casa nu a fost gasita in config!'}) end
  -- while houseInfo[d] == nil do Wait(5000) vRP.notify({'Interiorul acestei case nu exista!'}) end
  DoScreenFadeOut(500)
  Wait(1000)
  plyPed = PlayerPedId()
  SetEntityCoords(plyPed,tmpHouses[d].entry.x,tmpHouses[d].entry.y,tmpHouses[d].entry.z, false, false, false, true) -- tmpHouses[d].entry.x
  Wait(500)
  DoScreenFadeIn(500)
  SetEntityAsMissionEntity(houseInfo[d].shell,true,true)
  DeleteObject(houseInfo[d].shell)
  DeleteEntity(houseInfo[d].shell)

  if type(houseInfo[d].extras) == 'table' then
    for k,v in pairs(houseInfo[d].extras) do
      SetEntityAsMissionEntity(v,true,true)
      DeleteObject(v)
      print('debug case: obiect sters - '..v)
    end
  end
  houseInfo[d] = {}
end
SpawnHouse = function(d)
  local model = Shells[tmpHouses[d].shell].prop
  local hash  = GetHashKey(model)

  local start = GetGameTimer()
  RequestModel(hash)
  while not HasModelLoaded(hash) and GetGameTimer() - start < 30000 do Wait(0); end
  if not HasModelLoaded(hash) then
    ShowNotification('Model de casa invalid!')
    return false,false
  end

  local shell = CreateObject(hash, tmpHouses[d].entry.x,tmpHouses[d].entry.y,tmpHouses[d].entry.z - 30.0,false,false)
  FreezeEntityPosition(shell,true)
  start = GetGameTimer()
  while not DoesEntityExist(shell) and GetGameTimer() - start < 30000 do Wait(0); end
  if not DoesEntityExist(shell) then
    ShowNotification('Nu am putut incarca aceasta casa!')
    return false,false
  end
  SetEntityAsMissionEntity(shell,true,true)
  SetModelAsNoLongerNeeded(hash)
  local pos = tmpHouses[d].entry
  local extras = {}
  vRPShousing.getHouseFurniture({tonumber(d)},function(mobila)
    if type(mobila) == 'table' then
      for k,v in pairs(mobila) do
        local objHash = GetHashKey(v.model)
        RequestModel(objHash)
        if HasModelLoaded(objHash) then
          local obj = CreateObject(objHash, pos.x + v.pos.x, pos.y + v.pos.y, pos.z + v.pos.z, false,false,false)
          FreezeEntityPosition(obj, true)
          SetEntityCoordsNoOffset(obj, pos.x + v.pos.x, pos.y + v.pos.y, pos.z + v.pos.z)
          SetEntityRotation(obj, v.rot.x, v.rot.y, v.rot.z, 2)
    
          SetModelAsNoLongerNeeded(objHash)
          print('debug case: obiect creeat - '..obj)
          table.insert(extras,obj)
        end
      end
    end
  end)

  return shell,extras
end
draw3dtext = function(x,y,z, text, scl, font) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
		  SetTextScale(0.0*scale, 1.1*scale)
		  SetTextFont(font or 0)
		  SetTextProportional(1)
		  -- SetTextScale(0.0, 0.55)
		  SetTextColour(255, 255, 255, 255)
		  SetTextDropshadow(0, 0, 0, 0, 255)
		  SetTextEdge(2, 0, 0, 0, 150)
		  SetTextDropShadow()
		  SetTextOutline()
		  SetTextEntry("STRING")
		  SetTextCentre(1)
		  AddTextComponentString(text)
		  DrawText(_x,_y)
    end
end
drawText = function(x,y,text,scale,font,rgbTable,centre)
	local font = font or 0
	local r,g,b,a = 255,255,255,255
	local centre = centre or 1
	local text = text or 'NULL'
	if type(rgbTable) == 'table' then
		r,g,b,a = rgbTable[1],rgbTable[2],rgbTable[3],rgbTable[4]
	end
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextDropShadow(5,0,0,0,255)
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

SetChest = function(d)
  if not inHouse.house == d then vRP.notify({'~r~Nu esti in aceasta casa!'}) end
  if inHouse.house == d then
    vRP.notify({"Du-te in locatia in care vrei sa setezi chest-ul si apasa [~y~G~w~]"})
    while true do
      if Pressed(0,Keys['G']) then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        TriggerServerEvent('machiamavlad:SetChest',d,coords)
        tmpHouses[d].chest = coords
        break
      end
      Wait(1)
    end
  end
end
SetWardrobe = function(d)
  if not inHouse.house == d then vRP.notify({'~r~Nu esti in aceasta casa!'}) end
  if inHouse.house == d then
    vRP.notify({"Du-te in locatia in care vrei sa setezi garderoba si apasa [~y~G~w~]"})
    while true do
      if Pressed(0,Keys['G']) then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        TriggerServerEvent('machiamavlad:SetWardrobe',d,coords)
        tmpHouses[d].wardrobe = coords
        break
      end
      Wait(1)
    end
  end
end
RefreshFurniture = function(myHID)
  if houseInfo[myHID] ~= nil then
    if type(houseInfo[myHID].extras) == 'table' then
      for k,v in pairs(houseInfo[myHID].extras) do
        SetEntityAsMissionEntity(v,true,true)
        DeleteObject(v)
        print('debug case: obiect sters - '..v)
      end
    end
    local pos = tmpHouses[myHID].entry
    houseInfo[myHID].extras = {}
    vRPShousing.getHouseFurniture({tonumber(myHID)},function(mobila)
      if type(mobila) == 'table' then
        for k,v in pairs(mobila) do
          local objHash = GetHashKey(v.model)
          RequestModel(objHash)
          if HasModelLoaded(objHash) then
  
            local obj = CreateObject(objHash, pos.x + v.pos.x, pos.y + v.pos.y, pos.z + v.pos.z, false,false,false)
            FreezeEntityPosition(obj, true)
            SetEntityCoordsNoOffset(obj, pos.x + v.pos.x, pos.y + v.pos.y, pos.z + v.pos.z)
            SetEntityRotation(obj, v.rot.x, v.rot.y, v.rot.z, 2)
      
            SetModelAsNoLongerNeeded(objHash)
            print('debug case: obiect recreeat - '..obj)
            table.insert(houseInfo[myHID].extras,obj)
          end
        end
      end
    end)
  end
end
RegisterNetEvent('machiamavlad:leaveHouse')
AddEventHandler('machiamavlad:leaveHouse',LeaveHouse)

RegisterNetEvent('machiamavlad:setChest')
AddEventHandler('machiamavlad:setChest',SetChest)

RegisterNetEvent('machiamavlad:setWardrobe')
AddEventHandler('machiamavlad:setWardrobe',SetWardrobe)

RegisterNetEvent('machiamavlad:enterHouse')
AddEventHandler('machiamavlad:enterHouse',TeleportInside)

RegisterNetEvent('machiamavlad:RefreshFurniture')
AddEventHandler('machiamavlad:RefreshFurniture',RefreshFurniture)

RegisterNetEvent('machiamavlad:getId')
AddEventHandler('machiamavlad:getId',function(gamesense_uid)
  myIdentifier = gamesense_uid
end)
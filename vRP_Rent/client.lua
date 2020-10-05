vRPCrent = {}
Tunnel.bindInterface("vRP_rent",vRPCrent)
Proxy.addInterface("vRP_rent",vRPCrent)
vRPSrent = Tunnel.getInterface("vRP_rent","vRP_rent")
vRP = Proxy.getInterface("vRP")

local rented = false
local rentPos = {-136.53581237792,6308.4931640625,31.488779067994}
rentObj = nil
local carPrice = 50

Citizen.CreateThread(function()

  local cIcon = CreateRuntimeTxd("carIcon")
  CreateRuntimeTextureFromImage(cIcon, "carIcon", "img/carIcon.png")
  
end)

function drawSubtitleText(m_text, showtime)
  ClearPrints()
  SetTextEntry_2("STRING")
  SetTextFont(fontId)
  AddTextComponentString(m_text)
  DrawSubtitleTimed(showtime, 1)
end

function isCursorInPosition(x,y,width,height)
    local sx, sy = GetActiveScreenResolution()
  local cx, cy = GetNuiCursorPosition ( )
  local cx, cy = (cx / sx), (cy / sy)
  
    local width = width / 2
    local height = height / 2
  
  if (cx >= (x - width) and cx <= (x + width)) and (cy >= (y - height) and cy <= (y + height)) then
      return true
  else
      return false
  end
end

function deleteCar( entity )
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
end

function vRPCrent.spawnVeh(car)
    local car = GetHashKey(car)

    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, x , y , z + 1, 0.0, true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1) -- put player inside
    SetEntityAsMissionEntity(vehicle, true, true)
    SetTimeout(900000, function()
    	rented = false
    	if( DoesEntityExist(vehicle) )then
    		deleteCar(vehicle)
    		vRP.notify({"~g~[RENT] ~r~Masina inchiriata a fost returnata."})
    	else
    		vRP.notify({"~g~[RENT] ~r~Masina inchiriata a fost returnata."})
    	end
    end)
end

Citizen.CreateThread(function()
	while true do
    Citizen.Wait(0)
    if (Vdist(GetEntityCoords(GetPlayerPed(-1)),rentPos[1],rentPos[2],rentPos[3]) <= 5.5) and not isCursor then
      drawSubtitleText("Press ~y~[E]~s~ to rent a ~y~Car~s~ for 15 minutes", 1)
      if IsControlJustPressed(1,46) then
        isCursor = true
        FreezeEntityPosition(GetPlayerPed(-1), true)
      end
    end
    if not isCursor then
      if(Vdist(GetEntityCoords(GetPlayerPed(-1)),rentPos[1],rentPos[2],rentPos[3]) <= 5.5) then
	  	  DrawText3D(rentPos[1],rentPos[2],rentPos[3]+0.9, "~b~[RENT]~w~ \n Rent a car", 1.0, 7)
        DrawText3D(rentPos[1],rentPos[2],rentPos[3]+0.7, "~y~Ford Bronco", 0.5, 4)
      end
	  end
	end
end)

Citizen.CreateThread(function()
  while true do
    if(rentObj == nil)then
      model = "imp_prop_impexp_tyre_03c"
      RequestModel(GetHashKey(model))
      while not HasModelLoaded(GetHashKey(model)) do
        Wait(0)
      end
      rentObj = CreateObject(GetHashKey(model), rentPos[1], rentPos[2], rentPos[3]-0.40, false, false)
      FreezeEntityPosition(rentObj, true)
      SetEntityCollision(rentObj, false)
      SetEntityDynamic(rentObj, false)
    end
  
    Citizen.Wait(15)
    if(rentObj)then
      if DoesEntityExist(rentObj) then
        SetEntityHeading(rentObj, GetEntityHeading(rentObj)+1 %360)
      end
    end
  end
end)

isCursor = false
local closeColor = {128,128,128}
local rentColor = {128,128,128}


Citizen.CreateThread(function()
    while true do
        if(isCursor)then
           local ped = GetPlayerPed(-1)
           ShowCursorThisFrame()
           SetCursorSprite(1)
           DisableControlAction(0,24,true)
           DisableControlAction(0,47,true)
           DisableControlAction(0,58,true)
           DisableControlAction(0,263,true)
           DisableControlAction(0,264,true)
           DisableControlAction(0,257,true)
           DisableControlAction(0,140,true)
           DisableControlAction(0,141,true)
           DisableControlAction(0,142,true)
           DisableControlAction(0,143,true)
           DisableControlAction(0, 1, true)
           DisableControlAction(0, 2, true)
        
        
           DrawRect(0.50,0.50,0.2,0.3,0,0,0,180)
           DrawRect(0.50,0.50,0.15,0.25,rentColor[1],rentColor[2],rentColor[3],180)
           DrawSprite("carIcon","carIcon",0.50,0.50,0.15,0.25,0.0,255,255,255,255)
           drawScreenText(0.50, 0.663+0.0010, 0,0, 0.5, "CLOSE", 255, 255, 255, 230, 1, 7, 1)
           drawScreenText(0.50, 0.345, 0,0, 0.35, "~w~Price: ~s~" ..carPrice.. " $", 0, 255, 21, 230, 1, 4, 1)
           drawScreenText(0.50, 0.30, 0,0, 0.8, "Rent a car", 0, 255, 238, 230, 1, 7, 1)
           DrawRect(0.50,0.68 + 0.002,0.06,0.03,closeColor[1],closeColor[2],closeColor[3],150)
        
        
            if isCursorInPosition(0.50,0.68 + 0.002,0.06,0.03)then
                SetCursorSprite(5)
                closeColor = {0, 255, 238}
                if(IsDisabledControlJustPressed(0, 24))then
                  isCursor = not isCursor
                  FreezeEntityPosition(GetPlayerPed(-1), false)
                end
            elseif isCursorInPosition(0.50,0.50,0.15,0.25)then
                SetCursorSprite(5)
                rentColor = {47, 161, 37}
                if(IsDisabledControlJustPressed(0, 24))then
                	if(rented == false)then
                  	  isCursor = not isCursor
                  	  vRPSrent.verificaMoney({carPrice})
                  	  vRPCrent.spawnVeh("stanier")
                  	  rented = true
                  	  FreezeEntityPosition(GetPlayerPed(-1), false)
              		else
              	  	  vRP.notify({"~g~[RENT] ~r~Poti inchiria doar o masina."})
              	  	end
                end
            else
			          closeColor = {0,0,0}
			        	rentColor = {128,128,128}
            end
        end
       Citizen.Wait(0)  
    end
end)

function DrawText3D(x,y,z, text, scl, font) 

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(font)
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

function drawScreenText(x,y ,width,height,scale, text, r,g,b,a, outline, font, center)
  SetTextFont(font)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextCentre(center)
  if(outline)then
      SetTextOutline()
  end
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x - width/2, y - height/2 + 0.005)
end
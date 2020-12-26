vRPCds = {}
Tunnel.bindInterface("vRP_dealership",vRPCds)
Proxy.addInterface("vRP_dealership",vRPCds)
vRPSds = Tunnel.getInterface("vRP_dealership","vRP_dealership")
vRP = Proxy.getInterface("vRP")

loadingMod = nil
rotateVeh = false
openDoors = false
dsVeh = nil
noCarModel = false
local showing = false
previewPos = {-75.413948059082,-819.11840820312,325.91040039062,60.962993621826}
vehCamPosition = {-74.955284118652,-818.83612060546,325.75100708008}
vehSr = {-33.226928710938,-1101.9810791016,26.422372817994}
carColor = nil
culori = {
    ['Red'] = {0.4,0.45,"~r~Rosu",255,0,0,27},
    ['Green'] = {0.45,0.45,"~g~Verde",0,255,0,92},
    ['Blue'] = {0.5,0.45,"~b~Albastru",0,0,255,61},
    ['Yellow'] = {0.55,0.45,"~y~Galben",255,255,0,89},
    ['Orange'] = {0.6,0.45,"~o~Portocaliu",255,100,0,36},

    ['White'] = {0.45,0.6,"~w~Alb",255,255,255,111},
    ['Black'] = {0.50,0.6,"Negru",0,0,0,0},
    ['Gray'] = {0.55,0.6,"~m~Gri",200,200,200,13}
}

vRP.addBlip({vehSr[1],vehSr[2],vehSr[3],642,1,'Dealership'})
Citizen.CreateThread(function()

    local model = GetHashKey("ig_paper")
    RequestModel(model)
    while (not HasModelLoaded(model)) do
      Citizen.Wait(1)
    end
    licenseNpc = CreatePed(1, model, vehSr[1], vehSr[2], vehSr[3]-1.0, 30.0, false, false)
	SetModelAsNoLongerNeeded(model)
	SetEntityHeading(licenseNpc, 80.0)
	FreezeEntityPosition(licenseNpc, true)
	SetEntityInvincible(licenseNpc, true)
    SetBlockingOfNonTemporaryEvents(licenseNpc, true)


end)

local masina = 1
local masini = {}
--RegisterNetEvent("sendDbVehs")
--AddEventHandler("sendDbVehs",function(data)
vRPCds.getVehz = function(data)
    if type(data) == "table" then
        --for i,v in pairs(data)do
        --    table.insert(masini,{nume=v.nume,price=v.price,curentModel=v.curentModel,colectie=v.colectie,type=v.type})
        --end
        masini = {}
        SetTimeout(1000, function()
            masini = data
        end)
        print("[DEALERSHIP] Masinile au fost reimprospatate!")
    end
end
--end)
function crescator(a,b)

    return a.price < b.price
end

function descrescator(a,b)
    return a.price > b.price
end
function vRPCds.openDs()
        if #masini > 0 then
            FreezeEntityPosition(GetPlayerPed(-1),true)
            SetEntityCoords(GetPlayerPed(-1),vehCamPosition[1],vehCamPosition[2],vehCamPosition[3])
            SetEntityVisible(GetPlayerPed(-1),false)
            spawndsVeh()
            showing = true
            masina = 1
        else
            vRP.notify({"~r~Nu sunt disponibile masini in Showroom!"})
        end
end

function vRPCds.returnDs()
    showing = true
end

function vRPCds.leaveDs()
	SetEntityCoords(GetPlayerPed(-1), -38.848526000976,-1109.6365966796,26.437786102294)
	SetEntityHeading(GetPlayerPed(-1), 166.00965881348)
	FreezeEntityPosition(GetPlayerPed(-1),false)
    SetEntityVisible(GetPlayerPed(-1),true)

    DeleteVehicle(dsVeh)
    TriggerEvent("aratainpulameajobgoal",true)
    showing = false
    loadingMod = nil
	rotateVeh = false
	dsVeh = nil
	masina = 1
end

function drawSubtitleText(m_text, showtime)
    ClearPrints()
    SetTextEntry_2("STRING")
    SetTextFont(fontId)
    AddTextComponentString(m_text)
    DrawSubtitleTimed(showtime, 1)
  end

Citizen.CreateThread(function()
    while true do
        while(Vdist(GetEntityCoords(GetPlayerPed(-1)),vehSr[1],vehSr[2],vehSr[3]) <= 5.0)do
            drawSubtitleText("Apasa ~g~[E]~w~ pentru a vedea ~r~expozitia de masini")
            DrawText3D(vehSr[1],vehSr[2],vehSr[3]+1.1, "Ion Tiriac", 0.9, 1)
            DrawText3D(vehSr[1],vehSr[2],vehSr[3]+1.0, "[ ~g~Agent Vanzari ~w~]", 0.9, 4)
            if(IsDisabledControlJustPressed(0,38))then
                vRPCds.openDs()
            end
            Wait(0)
        end
        Citizen.Wait(3000)
    end
end)

function drawtxt(x,y,scale,text,r,g,b,a,font)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextCentre(1)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.0/2, y - 0.0/2 + 0.005)
end

function _LoadModel(mdl)
    local i = 0
    while ( not HasModelLoaded(mdl) ) and (i < 500) do 
        RequestModel( mdl )
        Citizen.Wait( 5 )
		i = i + 1
    end 
end 

function spawndsVeh()
	hashModel = GetHashKey(masini[masina].curentModel)
	lastHeading = 0
	if(DoesEntityExist(dsVeh)) then
		lastHeading = GetEntityHeading(dsVeh)
		DeleteVehicle(dsVeh)
		dsVeh = nil
	end
	
    _LoadModel(hashModel)
	
	if HasModelLoaded(hashModel) then
		dsVeh = CreateVehicle(hashModel,previewPos[1],previewPos[2],previewPos[3],previewPos[4],false,false)
		SetModelAsNoLongerNeeded(hashModel)
		SetEntityHeading(dsVeh, lastHeading)
		SetVehicleEngineOn(dsVeh, true, true)
        SetEntityInvincible(dsVeh,true)
        SetEntityAlpha(GetPlayerPed(-1),0)
		SetVehicleDoorsLocked(dsVeh,4)
		SetVehicleOnGroundProperly(dsVeh)
		FreezeEntityPosition(dsVeh,true)
		TaskWarpPedIntoVehicle(GetPlayerPed(-1),dsVeh,-1)
		for i = 0,24 do
			SetVehicleModKit(dsVeh,0)
			RemoveVehicleMod(dsVeh,i)
		end
		SetVehicleRadioEnabled(dsVeh, false)
		openDoors = false
		noCarModel = false
	else
		noCarModel = true
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2500)
		
        while(rotateVeh == true) and (DoesEntityExist(dsVeh))do
            
			SetEntityHeading(dsVeh, GetEntityHeading(dsVeh)+1 %360)
            Wait(25)
		end
	end
end)

function seteazanmortimaticeculoarevreaudacanumapispemata(culoare)
    ceculoarepuninplm = culoare
end

masinaTest = nil
testDriveSeconds = 60
isInTestDrive = false

function destroymasinaTest()
	if(masinaTest ~= nil)then
		if(DoesEntityExist(masinaTest))then
			Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(masinaTest))
		end
		masinaTest = nil
        loadingMod = nil
		isInTestDrive = false
	end
	testDriveSeconds = 60
	SetEntityCoords(GetPlayerPed(-1),-38.848526000976,-1109.6365966796,26.437786102294)
	SetEntityHeading(GetPlayerPed(-1), 180.0)
    vRP.notify({"Test driveul a luat sfarsit!"})
    showing = false
    SetEntityVisible(GetPlayerPed(-1),true)
    FreezeEntityPosition(GetPlayerPed(-1),false)
end

AddEventHandler("playerDropped", function()
	if(masinaTest ~= nil)then
		destroymasinaTest()
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1100)
		if(masinaTest ~= nil) and (isInTestDrive == false) then
			isInTestDrive = true
		else
			isInTestDrive = false
		end
		while(masinaTest ~= nil)do
			local IsInVehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
			if(IsInVehicle ~= nil)then
				if(masinaTest == IsInVehicle)then
					if(testDriveSeconds > 0)then
						testDriveSeconds = testDriveSeconds - 1
					else
						destroymasinaTest()
					end
					isInCar = true
				else
					isInCar = false
				end
			end
            Wait(1000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        local coords = GetEntityCoords(GetVehiclePedIsIn(GetPlayerPed(-1),false))
        if(testDriveSeconds < 60)then
            DrawText3D(coords.x,coords.y,coords.z+1.5,testDriveSeconds.." ~g~Secunde\n~w~Apasa ~g~E ~w~pentru a termina", 1.0, 4)
            if IsControlJustPressed(1, 51) then
                destroymasinaTest()
            end
		end
		if(isInTestDrive) then
			if(isInCar == false)then
				destroymasinaTest()
			end
		end
	end
end)
local function RGBRainbow( frequency )
    local result = {}
    local curtime = GetGameTimer() / 1000

    result.r = math.floor( math.sin( curtime * frequency + 0 ) * 127 + 128 )
    result.g = math.floor( math.sin( curtime * frequency + 2 ) * 127 + 128 )
    result.b = math.floor( math.sin( curtime * frequency + 4 ) * 127 + 128 )
    
    return result
end
Citizen.CreateThread(function()
    table.sort(masini,crescator)
    masina = 1

    while true do
        if(showing == true)then
            if #masini > 0 then
                rgb = RGBRainbow(2)
                local culoareButoane = {
                    Dreapta = {0,0,0},
                    Stanga = {0,0,0}
                }
    
                local sprites = {
                    Dreapta = "dsRight",
                    Stanga = "dsLeft"
                }
    
                culoareButoane.Dreapta = {0,0,0}
                culoareButoane.Stanga = {0,0,0}
                aRight = 150
                aLeft = 150
                openDoorsAlpha = 130
                rotateAlpha = 130
                if(loadingMod ~= nil)then
                    drawtxt(0.50,0.955,0.39,"~r~Incarcare Mod: ~w~"..loadingMod.."~r~...",255,255,255,255,0)
                end
                ShowCursorThisFrame()
                SetCursorSprite(0)
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
                DisableControlAction(0, 27, true)
                DisableControlAction(0, 172, true)
                DisableControlAction(0, 173, true)
                DisableControlAction(0, 174, true)
                DisableControlAction(0, 175, true)
                DisableControlAction(0, 176, true)
                DisableControlAction(0, 177, true)
    
    
                local player = GetPlayerPed(-1)
                SetRadarZoomLevelThisFrame(200.0)
    
                DrawRect(0.50,0.85,0.4,0.15,0,0,0,130)
                DrawRect(0.50,0.75,0.4,0.03,0,0,0,130)
                --- BUY DRAWRECTS
                DrawRect(0.665,0.95,0.07,0.03,0,0,0,130)
                drawtxt(0.665,0.95 - 0.023,0.48,"Cumpara",0,255,0,255,4)
                --- CLOSE DRAWRECTS
                DrawRect(0.335,0.95,0.07,0.03,0,0,0,130)
                drawtxt(0.335,0.95 - 0.023,0.48,"Inchide",255,0,0,255,4)
                --- OPEN DOORS DRAWRECTS
                DrawRect(0.435,0.95,0.07,0.03,0,0,0,openDoorsAlpha)
                drawtxt(0.435,0.95 - 0.023,0.48,"~o~Open Doors",0, 174, 255,255,4)
                --- ROTATE DRAWRECTS
                DrawRect(0.555,0.95,0.07,0.03,0,0,0,rotateAlpha)
                drawtxt(0.555,0.95 - 0.023,0.48,"~y~Rotate",85, 0, 255,255,4)
                --- TEST DRIVE
                DrawRect(0.45,0.70,0.07,0.03,0,0,0,130)
                drawtxt(0.45,0.70 - 0.023,0.48,"~g~Test Drive",85, 0, 255,255,4)
    
                --- CULOARE VEHICUL
                DrawRect(0.55,0.70,0.07,0.03,0,0,0,130)
                drawtxt(0.55,0.70 - 0.023,0.48,"~s~Culoare",rgb.r, rgb.g, rgb.b,255,4)
    
                drawtxt(0.50,0.75 - 0.023,0.42,"~b~Dealership ~w~Menu",255,255,255,255,0)
                    if showing then
                    if(isCursorInPosition(0.555,0.95,0.07,0.03))then
                        rotateAlpha = 180
                        SetCursorSprite(5)
                        if(IsDisabledControlJustPressed(0,24))then
                            if(rotateVeh == true)then
                                rotateVeh = false
                                DisableControlAction(0, 1, true)
                            else
                                rotateVeh = true
                                EnableControlAction(0, 1, true)
                            end
                        end
                    elseif(isCursorInPosition(0.665,0.95,0.07,0.03))then
                        SetCursorSprite(5)
                        if(IsDisabledControlJustPressed(0,24))then
                            --if masini[masina].stock > 0 then
                                showing = false
                                Citizen.CreateThread(function()
                                    while true do
                                        ShowCursorThisFrame()
                                        SetCursorSprite(0)
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
                                        DisableControlAction(0, 27, true)
                                        DisableControlAction(0, 172, true)
                                        DisableControlAction(0, 173, true)
                                        DisableControlAction(0, 174, true)
                                        DisableControlAction(0, 175, true)
                                        DisableControlAction(0, 176, true)
                                        DisableControlAction(0, 177, true)
            
                                        local srConfirm = {
                                            OK = {68, 68, 68},
                                            NotOK = {68, 68, 68}
                                        }
                                    
                                        srConfirm.OK = {68, 68, 68}
                                        srConfirm.NotOK = {68, 68, 68}
                                    
                                        if isCursorInPosition(0.550,0.515,0.065,0.035) then
                                            SetCursorSprite(5)
                                            srConfirm.OK = {0,255,0}
                                            if(IsDisabledControlJustPressed(0, 24))then
                                                if(masini[masina].type ~= nil)then
                                                    vRPSds.tryBuyCar({masini[masina].curentModel,masini[masina].price,"bike",tostring(masini[masina].nume)})
                                                else
                                                    print(carColor)
                                                    if carColor	~= nil then
                                                    	vRPSds.tryBuyCar({masini[masina].curentModel,masini[masina].price,"car",tostring(masini[masina].nume),ceculoarepuninplm})
                                                    else
                                                    	vRPSds.tryBuyCar({masini[masina].curentModel,masini[masina].price,"car",tostring(masini[masina].nume),0})
                                                	end
                                                end
                                                masina = 1
                                                loadingMod = nil
                                            
                                                culoareButoane.Dreapta = {0,0,0}
                                                culoareButoane.Stanga = {0,0,0}
                                                aRight = 150
                                                aLeft = 150
                                                openDoorsAlpha = 130
                                                rotateAlpha = 130
            
                                                break
                                            end
                                        elseif isCursorInPosition(0.45,0.515,0.065,0.035) then 
                                            SetCursorSprite(5)
                                            srConfirm.NotOK = {255,0,0}
                                            if(IsDisabledControlJustPressed(0, 24))then
                                                --if DoesEntityExist(dsVeh) then
                                                --    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(dsVeh))
                                                --end
                                            
                                            
                                                showing = true
                                            
                                            
                                                break
                                            end
                                        else
                                            SetCursorSprite(1)
                                        end
                                        DrawRect(0.50,0.45,0.20,0.20,0,0,0,150)
                                        DrawRect(0.50,0.365,0.20,0.03,81,154,193, 255)
                                    
                                        drawtxt(0.50,0.365 - 0.017,0.33,"Achizitionare Masina",255,255,255,255,0)
                                        drawtxt(0.50,0.390,0.455,"Esti sigur ca vrei sa cumperi vehiculul",255,255,255,255,4)
            
                                        drawtxt(0.50,0.445,0.455,"~g~"..masini[masina].nume.." ~w~ pentru ~r~ "..formatMoney(tonumber(masini[masina].price)).. " $",255,255,255,255,4)
                                    
                                        DrawRect(0.45,0.515,0.065,0.035,srConfirm.NotOK[1],srConfirm.NotOK[2],srConfirm.NotOK[3], 180)
                                        drawtxt(0.45,0.500 - 0.005,0.445,"NU",255,0,0,255,4)
                                    
                                        DrawRect(0.550,0.515,0.065,0.035,srConfirm.OK[1],srConfirm.OK[2],srConfirm.OK[3], 180)
                                        drawtxt(0.550,0.500 - 0.005,0.445,"DA",0,255,0,255,4)
                                    Wait(0)
                                    end
                                end)
                            --else
                            --    vRP.notify({"~r~Aceasta masina nu este in stock!"})
                            --end
                        end
                    elseif(isCursorInPosition(0.435,0.95,0.07,0.03))then
                        SetCursorSprite(5)
                        if(IsDisabledControlJustPressed(0,24))then
                            if(openDoors)then
                                SetVehicleDoorsShut(dsVeh, false)
                                openDoors = false
                            else
                                openDoors = true
                                SetVehicleDoorOpen(dsVeh, 0, false, false)
                                SetVehicleDoorOpen(dsVeh, 1, false, false)
                                SetVehicleDoorOpen(dsVeh, 2, false, false)
                                SetVehicleDoorOpen(dsVeh, 3, false, false)
                                SetVehicleDoorOpen(dsVeh, 4, false, false)
                                SetVehicleDoorOpen(dsVeh, 5, false, false)
                                SetVehicleDoorOpen(dsVeh, 6, false, false)
                                SetVehicleDoorOpen(dsVeh, 7, false, false)
                            end
                        end
                    elseif(isCursorInPosition(0.335,0.95,0.07,0.03))then
                        SetCursorSprite(5)
                        if(IsDisabledControlJustPressed(0,24))then
                            vRPCds.leaveDs()
                        end
                    elseif(isCursorInPosition(0.55,0.70,0.07,0.03))then
                        SetCursorSprite(5)
                        if(IsDisabledControlJustPressed(0,24))then
                            showing = false
                            menuCuloare = true
                            local ped = GetPlayerPed(-1)
                            Citizen.CreateThread(function()
                                while true do
                                    if menuCuloare then
                                        ShowCursorThisFrame()
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
                                        DisableControlAction(0, 27, true)
                                        DisableControlAction(0, 172, true)
                                        DisableControlAction(0, 173, true)
                                        DisableControlAction(0, 174, true)
                                        DisableControlAction(0, 175, true)
                                        DisableControlAction(0, 176, true)
                                        DisableControlAction(0, 177, true)
                                        local vehicle = GetVehiclePedIsUsing(ped)
                                        FreezeEntityPosition(vehicle,true)
                                        SetCursorSprite (0)
                                        drawtxt(0.5,0.3,1.0,"~g~Culoare Masina",255,255,255,255,1)
                                        DrawRect(0.5,0.51,0.3,0.3,0,0,0,150)
                                        -- inapoi
                                        DrawRect(0.5,0.7,0.06,0.03,0,0,0,150)
                                        drawtxt(0.5,0.7 - 0.023,0.48,"~r~Inapoi",255,255,255,255,4)
                                        for i,v in pairs(culori)do
                                            DrawRect(v[1],v[2],0.042, 0.072,v[4],v[5],v[6],255)
                                            if isCursorInPosition(v[1],v[2],0.042,0.072) then
                                                SetCursorSprite(5)
                                                showToolTip("~w~Seteaza culoare ~g~>> ~s~"..v[3],4,0.4)
                                                if IsDisabledControlJustPressed(0,24)then
                                                    if vehicle then
                                                        seteazanmortimaticeculoarevreaudacanumapispemata(v[7])
                                                        SetVehicleColours(vehicle,v[7],0)
                                                        print(ceculoarepuninplm)
                                                    end
                                                end
                                            elseif(isCursorInPosition(0.5,0.7,0.06,0.03))then
                                                SetCursorSprite(5)
        
                                                if IsDisabledControlJustPressed(0,24)then
                                                    showing = true
                                                    menuCuloare = false
                                                    break
                                                end
                                            end
                                        end
                                    else
                                        break
                                    end
                                    Wait(0)
                                end
                            end)
                        end
        
                    elseif(isCursorInPosition(0.45,0.70,0.07,0.03))then
                        SetCursorSprite(5)
                        if(IsDisabledControlJustPressed(0,24))then
                            if(masinaTest == nil)then
                                hash = GetHashKey(masini[masina].curentModel)
                                while not HasModelLoaded(hash) do
                                    RequestModel(hash)
                                    Citizen.Wait(10)
                                end
                                if HasModelLoaded(hash) then
                                    TriggerEvent("aratainpulameajobgoal",true)
                                    masinaTest = CreateVehicle(hash,-914.83026123046,-3287.1538085938,13.521618843078,false,false)
                                    SetModelAsNoLongerNeeded(hash)
                                    TaskWarpPedIntoVehicle(GetPlayerPed(-1),masinaTest,-1)
                                    -- vRP.notify({"Ai 1 Minut pentru a testa masina!"})
                                    for i = 0,24 do
                                        SetVehicleModKit(masinaTest,0)
                                        RemoveVehicleMod(masinaTest,i)
                                    end
                                    if(masinaTest)then
                                        showing = false
                                        SetEntityVisible(GetPlayerPed(-1),true)
                                        FreezeEntityPosition(GetPlayerPed(-1),false)
                                    end
                                end
                            end
                        end
        
                    end
                end
                
                drawtxt(0.50,0.80,0.45,"~w~Masina: ~b~"..masini[masina].nume,255,255,255,255,0)
                drawtxt(0.50,0.83,0.40,"~w~Pret: ~g~"..formatMoney(tonumber(masini[masina].price)).."$",255,255,255,255,0)
                drawtxt(0.50,0.86,0.38,"~w~Top Speed: ~b~"..math.floor(GetVehicleModelMaxSpeed(GetHashKey(masini[masina].curentModel))*3.6).." ~w~km/h",255,255,255,255,0)
                --if(masini[masina].colectie ~= false and masini[masina].colectie ~= nil)then
                --drawtxt(0.5,0.89,0.34,"Stock: ~o~"..masini[masina].stock,255,255,255,255,0)
                --end
    
    
                if(isCursorInPosition(0.75,0.85,0.09,0.15) and (masina ~= #masini))then
                    aRight = 255
                    culoareButoane.Dreapta = {56,255,0}
                    SetCursorSprite(5)
                    if(IsDisabledControlJustPressed(0, 24))then
                        --print(masina)
                        masina = masina + 1
                        spawndsVeh()
                        --if(masina == nil)then
                        --    masina = 1
                        --end
                    end
                elseif(isCursorInPosition(0.25,0.85,0.09,0.15) and (masina ~= 1))then
                    aLeft = 255
                    culoareButoane.Stanga = {56,255,10}
                    SetCursorSprite(5)
                    if(IsDisabledControlJustPressed(0,24))then
                        --print(masina)
                        masina = masina - 1
                        spawndsVeh()
                        --if(masina == nil)then
                        --    masina = 1
                        --end
                    end
                
                end
                DrawSprite(sprites.Dreapta,sprites.Dreapta,0.75,0.85,0.08,0.12,90.0,255,255,255,aRight)
                DrawSprite(sprites.Dreapta,sprites.Dreapta,0.25,0.85,0.08,0.12,-90.0,255,255,255,aLeft)
            else
                vRP.notify({"~r~Nu sunt masini disponibile in showroom!"})
                vRPCds.leaveDs()
            end
            
        end
        Wait(0)
    end
end)

function formatMoney(amount)
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
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

local icons = {
    {"dsLeft"},
    {"gtavDealership"},
    {"bmwDealership"},
    {"dsRight"}
}
function loadAllIcons()
	for i, v in pairs(icons) do
		local txd = CreateRuntimeTxd(v[1])
		CreateRuntimeTextureFromImage(txd, v[1], "icons/"..v[1]..".png")
	end
end

Citizen.CreateThread(function()
	loadAllIcons()
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
function showToolTip(text, font, size)
    local sx, sy = GetActiveScreenResolution()
    local cx, cy = GetNuiCursorPosition()
    local cx, cy = ( cx / sx ) + 0.008, ( cy / sy ) + 0.027

    SetTextScale(size, size)
    SetTextFont(font)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(0, 0, 0, 0, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(cx, cy + 0.007)
    local lenght = string.len(text) * 0.003
    DrawRect(cx,cy + 0.02,lenght,0.03,128,128,128,200)
end

local taxiVehicles = {`taxi`}
local onDuty = false
local fareAmount = nil
local inTaxi = false

-- passager
local paidAmount = nil
local driverName = nil

-- driver
local clientName = nil
local earnings = nil
local pasagerPlyPed = nil



local vRP = Proxy.getInterface('vRP')
local vRPCtaxi = {}
local fontId = RegisterFontId('Freedom Font')
Tunnel.bindInterface("vRP_taxi",vRPCtaxi)
RegisterFontFile('wmk')

function vRPCtaxi.isInTaxiVeh()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh then
        for i = 1 , #taxiVehicles do
            if taxiVehicles[i] == GetEntityModel(veh) then
                return VehToNet(veh)
            end
        end
    end
    return false
end

function drawText(x,y,scale, text, r,g,b,a, outline, font, centre, right,up)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
	SetTextCentre(centre)
    if(outline)then
	    SetTextOutline()
	end
	if(right)then
		SetTextRightJustify(true)
		SetTextWrap(0,x)
	end
    if (up) then
        text = text:upper()
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y + 0.005)
end


function vRPCtaxi.updateNameAndEarnings(cName,paidAmount)
    clientName = tostring(cName)
    earnings = vRP.formatMoney({paidAmount})
end

function vRPCtaxi.updateNameAndPaid(dName,pAmount)
    driverName = tostring(dName)
    paidAmount = vRP.formatMoney({pAmount})
end


function vRPCtaxi.showOnScreenHud(dn,paid,fare,vehicleId,driverId)
    inTaxi = true
    vehicleId = NetToVeh(vehicleId)
    fareAmount = fare
    driverName = dn
    paidAmount = paid
    while (inTaxi and GetVehiclePedIsIn(PlayerPedId(),false) == vehicleId) do
        drawText(0.9,0.5,0.35, "~w~Tarif: ~g~"..fareAmount.."$ / KM", 255,255,255,255, false, fontId, 1)
        DrawRect(0.9,0.5,0.05,0.002,255,255,255,255)
        if driverName ~= nil then
            drawText(0.9,0.45,0.35, "~b~"..driverName, 255,255,255,255, false, fontId, 1)
            if paidAmount then
                drawText(0.9,0.47,0.25, "Platit: ~g~"..paidAmount.."$", 255,255,255,255, false, fontId, 1)
            end
        end
        Wait(1)
    end
    fareAmount = nil
    paidAmount = nil
    driverName = nil
    inTaxi = false
    TriggerServerEvent('taxi:passagerLeft',driverId)
end

function vRPCtaxi.startClock()
    CreateThread(function()
        while clientName ~= nil do
            TriggerServerEvent('taxi:checkPosition')
            Wait(2500)
        end
    end)
end

function vRPCtaxi.passagerLeft()
    pasagerPlyPed = nil
    clientName = nil
    earnings = nil
end

function vRPCtaxi.onTaxiDuty(vehicleId,amount)
    onDuty = true
    fareAmount = vRP.formatMoney({amount})
    vehicleId = NetToVeh(vehicleId)
    while (onDuty and GetVehiclePedIsIn(PlayerPedId(),false) == vehicleId) do
        drawText(0.9,0.5,0.35, "~w~Tarif: ~g~"..fareAmount.."$ / KM", 255,255,255,255, false, fontId, 1)
        DrawRect(0.9,0.5,0.05,0.002,255,255,255,255)
        if clientName ~= nil then
            drawText(0.9,0.45,0.35, "~b~"..clientName, 255,255,255,255, false, fontId, 1)
            if earnings then
                drawText(0.9,0.47,0.25, "Castig: ~g~"..earnings.."$", 255,255,255,255, false, fontId, 1)
            end
        end
        if clientName == nil then
            -- if clientPosition then
            --     distance = #(GetEntityCoords(PlayerPedId()) - clientPosition)
            --     if distance < 25.0 then
            --         drawText(0.9,0.55,0.35, "~o~SHIFT~w~ - Anunta clientul ca ai ajuns", 255,255,255,255, false, fontId, 1,false,false)
            --     else
            --         drawText(0.9,0.45,0.35, math.floor(distance).." metri pana la client", 255,255,255,255, false, fontId, 1)
            --     end
            -- else
                drawText(0.9,0.45,0.35, "~b~Asteapta cursa!", 255,255,255,255, false, fontId, 1)
            -- end
            while GetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(),false)) <= 300.0 do
                drawText(0.5,0.8,0.35, "~s~Nu poti sa iei comenzi cat timp taxiul tau este \nstricat", 255,0,0,255, false, fontId, 1,false,false)
                Wait(1)
            end
        end
        if pasagerPlyPed == nil then
            for i = 0 , GetVehicleModelNumberOfSeats(GetEntityModel(vehicleId)) do
                if (IsVehicleSeatFree(vehicleId,i) == false) then
                    local thePasager = GetPedInVehicleSeat(vehicleId,i)
                    if thePasager ~= 0 then
                        local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(thePasager))
                        TriggerServerEvent('taxi:setFirstPasager',serverId)
                        pasagerPlyPed = thePasager
                        break
                    end
                end
            end
        end
        Wait(1)
    end
    pasagerPlyPed = nil
    clientName = nil
    fareAmount = nil
    earnings = nil
    onDuty = false
    TriggerServerEvent('taxi:setState',false)
end
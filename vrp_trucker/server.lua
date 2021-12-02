local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_trucker")
vRPCtruck = Tunnel.getInterface("vRP_trucker","vRP_trucker")

vRPtruck = {}
Tunnel.bindInterface("vRP_trucker",vRPtruck)
Proxy.addInterface("vRP_trucker",vRPtruck)

local distanceMultiplier = 18.5
x, y, z = 20.78282737732,-2486.6345214844,6.0067796707154

trailerCoords = {
	[1] = {45.078811645508,-2475.0646972656,6.3240194320678, 1},
	[2] = {42.933082580566,-2476.9184570312,6.905936717987, 1},
	[3] = {41.984375,-2479.5810546875,6.9055109024048, 1},
	[4] = {40.802635192872,-2482.0200195312,5.9073495864868, 1},
	[5] = {38.894924163818,-2483.9655761718,5.9065561294556, 1}
}

trucks = {"kamaz", "k54115", "daf", "man", "haulmaster2", "nav9800", "phantom3", "ramvan"}
trailers = {"TANKER", "TRAILERS", "TRAILERS2"}
activeDeliveries = {}

unloadLocations = {
	{"Tesco Extra", 186.87092590332,6614.294921875,31.82873916626, "Benzina", 9102}, --Blaine
	{"Middlemore Farm", 2015.2478027344,4979.3334960938,41.288940429688, "Fertilizator", 7728}, --Ferma
	{"Fishing Triton", 3806.3562011718,4457.3383789062,4.3696641921998, "Componente barci", 7909}, --Iesirea inspre mare partea dreapta 
	{"Motor Wood", -577.99694824218,5325.5283203125,70.263298034668, "Componente motoare", 7835}, -- Blaine cherestea
	{"Golden Fish", 1309.264038086,4328.076171875,38.1669921875, "Unelte pescarie", 6936}, -- Pescarie lacul din mijloc
	{"Secret Army", -2069.2082519532,3386.5070800782,31.282091140748, "Uraniu", 6234}, -- Blaine cherestea
	{"Ardmore Construction", 870.50927734375,2343.2783203125,51.687889099122, "Caramizi", 4904}, -- Aproape de armata
	{"Los Santos Government", 2482.4860839844,-443.32431030274,92.992576599122, "Componente arme", 3299}, -- facilitate secreta los santos dreapta
    {"Trevor Airport", 1744.2651367188,3289.7778320312,41.102840423584, "Componente avioane", 6028}, -- aeroport trevor 
	{"Pet Shop", 562.17309570312,2722.1853027344,42.060230255126, "Mancare de animale", 5237}, -- petshop xtremezone
	{"Gallery Mall", -2318.4116210938,280.80227661132,169.467086792, "Mobila", 3627}, -- mall Xtremezone 
	{"The Cement Factory", 1215.9357910156,1877.8912353516,78.845520019532, "Piatra", 4526}, -- Fabrica de ciment la iesire din los santos
	{"Peregrine Farm", -50.683254241944,1874.984008789,196.8624572754, "Fertilizator", 4366}, -- Langa Poacher 
	{"SPAM", -64.300018310546,6275.9194335938,31.35410118103, "Porumbei", 8763}, -- Langa Poacher
	{"Super Tools", 2672.3757324218,3518.2490234375,52.712032318116, "Unelte", 6564}, -- Paralel cu Human Labs
	{"Lance Industry", 849.52270507812,2201.7373046875,51.490081787116, "Pesticide", 4761}, -- Langa constructia din mijloc
	{"Aircraft Cemetery", 2333.0327148438,3137.6437988282,48.178939819336, "Componente", 6081}, -- 
	{"Saskia Water Plant", -1921.7559814454,2045.240234375,140.73533630372, "Sticla", 4932}, -- Podgorie 
	{"Seven Gas Station", 2563.6311035156,419.98919677734,108.45681762696, "GPL", 3863} --Benzinarie
}

deliveryDistances = {}

deliveryCompany = {"ACI SRL", "ACC", "EuroAcres", "EuroGoodies", "GlobeEUR", "Renar Logistik", "S.A.L S.R.L", "TE Logistica", "Tesoro Gustoso", "Tradeaux"}


AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	vRPclient.addBlip(source,{x, y, z, 318, 3, "Job: Trucker"})
end)

function vRPtruck.getTrucks()
	return trucks, trailers
end

function vRPtruck.finishTruckingDelivery(distance)
	local player = source
	local user_id = vRP.getUserId({player})

	if activeDeliveries[user_id] then
		local ped = GetPlayerPed(player)
		local coords = GetEntityCoords(ped)

		local winMoney = math.floor(distance * distanceMultiplier)
		local location = vec3(activeDeliveries[user_id][2],activeDeliveries[user_id][3],activeDeliveries[user_id][4])
		
		local distance = #(coords - location)
		if distance <= 35.0 then
			vRPclient.notify(player, {"Ai primit ~g~"..vRP.formatMoney({winMoney}).."$~w~ pentru livrarea facuta la ~y~"..activeDeliveries[user_id][1].."~w~!"})
			vRP.giveMoney({user_id, winMoney})
			activeDeliveries[user_id] = nil
		else
			DropPlayer(player, "Reilable Network Event Overflow.")
		end	
	else
		DropPlayer(player, "Reilable Network Event Overflow.")
	end	
end

function vRPtruck.payTrailerFine()
	thePlayer = source
	local user_id = vRP.getUserId({thePlayer})
	if(vRP.tryFullPayment({user_id, 5000}))then
		vRPclient.notify(thePlayer, {"Ai avariat ~r~incarcatura tirului~w~, ai platit o taxa de ~r~5.000$~w~."})
	end
end

function vRPtruck.updateBayStats(theBay, stats)
	trailerCoords[theBay][4] = stats
end

local function takeDeliveryJob(player, theDelivery)
	lBay = 0
	for i, v in pairs(trailerCoords) do
		if(v[4] == 1)then
			lBay = i
			trailerCoords[lBay][4] = 0
			break
		end
	end
	if(lBay ~= 0)then
		local user_id = vRP.getUserId({player})
		if not activeDeliveries[user_id] then
			vRPCtruck.spawnTrailer(player, {lBay, trailerCoords[lBay]})
			activeDeliveries[user_id] = unloadLocations[theDelivery]
			vRPCtruck.saveDeliveryDetails(player, {activeDeliveries[user_id]})
			vRPclient.notify(player, {"Indreapta-te catre ~y~"..activeDeliveries[user_id][1].."~w~ pentru a livra ~g~"..activeDeliveries[user_id][5]})
			vRP.closeMenu({player})
		else
			vRPclient.notify(player, {"~r~Deja ai o cursa de tirist activa."})
		end
	else	
		vRPclient.notify(player, {"~r~Momentan nu este niciun loc liber pentru remorca ta, intoarce-te mai tarziu."})
		return
	end
end

trucker_menu = {name="Logistics Deliveries",css={top="75px", header_color="rgba(0,125,255,0.75)"}}

RegisterServerEvent("openTruckerJobs")
AddEventHandler("openTruckerJobs", function()
	thePlayer = source
	local user_id = vRP.getUserId({thePlayer})
	for i, v in ipairs(unloadLocations) do
		deliveryName = tostring(v[1])
		dX, dY, dZ = v[2], v[3], v[4]
		deliveryType = v[5]
		deliveryDistance = v[6]
		deliveryMoney = math.floor(deliveryDistance * distanceMultiplier) 
		theCompany = deliveryCompany[math.random(1, #deliveryCompany)]
		trucker_menu[deliveryName] = {function() takeDeliveryJob(thePlayer, i) end, "Companie: <font color='yellow'>"..theCompany.."</font><br>Tip incarcatura: <font color='red'>"..deliveryType.."</font><br>Distanta: <font color='red'>"..(deliveryDistance/1000).." KM</font><br>Castiguri: <font color='green'>"..vRP.formatMoney({deliveryMoney}).."$</font>"}
	end
	vRP.openMenu({thePlayer,trucker_menu})
end)

AddEventHandler("vRP:playerLeave", function(user_id, player)
	if activeDeliveries[user_id] then
		activeDeliveries[user_id] = nil
	end
end)

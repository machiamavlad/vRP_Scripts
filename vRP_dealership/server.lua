local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_dealership")
vRPCds = Tunnel.getInterface("vRP_dealership","vRP_dealership")

vRPSds = {}
Tunnel.bindInterface("vRP_dealership",vRPSds)
Proxy.addInterface("vRP_dealership",vRPSds)


print("^2[DEALERSHIP]^0 machiamavlad's dealership loaded ;3")


prefix = {
	["AB"] = "Alba",
	["AR"] = "Arad",
	["AG"] = "Arges",
	["BC"] = "Bacau",
	["BH"] = "Bihor",
	["BN"] = "Bistrita-Nasaud",
	["BT"] = "Botosani",
	["BR"] = "Braila",
	["BV"] = "Brasov",
	["BZ"] = "Buzau",
	["CL"] = "Calarasi",
	["CS"] = "Caras-Severin",
	["CJ"] = "Cluj",
	["CT"] = "Constanta",
	["CV"] = "Covasna",
	["DB"] = "Dambovita",
	["DJ"] = "Dolj",
	["GL"] = "Galati",
	["GR"] = "Giurgiu",
	["GJ"] = "Gorj",
	["HR"] = "Harghita",
	["HD"] = "Hunedoara",
	["IL"] = "Ialomita",
	["IS"] = "Iasi",
	["IF"] = "Ilfov",
	["MM"] = "Maramures",
	["MH"] = "Mehedinti",
	["MS"] = "Mures",
	["NT"] = "Neamt",
	["OT"] = "Olt",
	["PH"] = "Prahova",
	["SJ"] = "Salaj",
	["SM"] = "Satu Mare",
	["SB"] = "Sibiu",
	["SV"] = "Suceava",
	["TR"] = "Teleorman",
	["TM"] = "Timis",
	["TL"] = "Tulcea",
	["VL"] = "Valcea",
	["VS"] = "Vaslui",
	["VN"] = "Vrancea",
	["B"] = "Bucuresti"
}

local charset = {}  do -- [0-9a-zA-Z]
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

local function randomString(length)
    if not length or length <= 0 then return '' end
    math.randomseed(os.clock()^5)
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end

function vRPSds.generateRandomString()
	local ultimele3 = string.upper(randomString(3))
	local cifre = math.random(10,99)
	cityPrefix = {}
	for i, v in pairs(prefix) do
		table.insert(cityPrefix, i)
	end
	return cityPrefix[math.random(#cityPrefix)]..""..cifre..""..ultimele3
end





function vRPSds.tryBuyCar(vehicle,price,veh_type,masina,culoare)

	local user_id = tonumber(vRP.getUserId({source}))
    local player = vRP.getUserSource({user_id})
	exports["GHMattiMySQL"]:QueryResultAsync("SELECT * FROM vrp_showroom_vehicles WHERE curentModel = @vehicle", {['vehicle'] = vehicle},function(vehicles)
		for i,v in pairs(vehicles)do
				local actPrice = v.price
				if actPrice == nil then
					print("^1Seteaza pretul la masina ^2"..vehicle.."^0.")
					vRPclient.notify(player,{"~r~Aceasta masina nu are pret setat."})
        		    vRPCds.returnDs(player,{})
					return 
				end
				if  actPrice ~= price then
					print( "^2[DEALERSHIP] ^0Jucatorul cu IDul "..user_id.. " este posibil sa aiba hack!")
        		    --TriggerEvent("vAC:Sa-miIeiPula-NGuraDeCodat",5) [[You can change this and replace with your AntiCheat function]]
        		    vRPclient.notify(player,{"~r~Aceasta masina nu are pret setat."})
        		    vRPCds.returnDs(player,{})
        		    return 
				end	
				if vRP.tryFullPayment({user_id,actPrice}) then
        		    if culoare then
					    exports["GHMattiMySQL"]:QueryAsync("INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,vehicle_plate,veh_type,vehicle_colorprimary) VALUES(@user_id,@vehicle,@vehicle_plate,@veh_type,@culoare)",{
					    	["user_id"] = user_id, 
							["vehicle"] = vehicle, 
							["vehicle_plate"] = "B "..math.random(10000,99999), 
							["veh_type"] = veh_type,
							['culoare'] = culoare
						})
        		    else
        		        exports["GHMattiMySQL"]:QueryAsync("INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,vehicle_plate,veh_type,vehname) VALUES(@user_id,@vehicle,@vehicle_plate,@veh_type)",{
        		        	["user_id"] = user_id, 
        		    		["vehicle"] = vehicle, 
        					["vehicle_plate"] = "B "..math.random(10000,99999), 
        					["veh_type"] = veh_type
    					})
        		    end
        		    vRPCds.leaveDs(player,{})
        		    vRP.addNewLog({user_id, 1, "Buy Car: "..GetPlayerName(player).." -> "..v.nume.. " Pret -> "..formatMoney(tonumber(actPrice))})
        		    vRPclient.notifyPicture(player,{"CHAR_SIMEON", 9, "Ion Tiriac", false, "Ai platit ~r~$"..formatMoney(tonumber(actPrice)).."~w~ pentru masina ~g~"..v.nume})
				else
					vRPclient.notify(player,{"~r~Not enough money."})
					vRPCds.returnDs(player,{})
				end
		end
	end)
    
end

function formatMoney(amount)
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

cars = {}

function updateShowroomCars()
	cars = {}
    exports["GHMattiMySQL"]:QueryResultAsync("SELECT * FROM vrp_showroom_vehicles ORDER BY price ASC",{}, function(vehicles)
        for i,v in pairs(vehicles)do
            table.insert(cars,{nume=v.nume,price=v.price,curentModel=v.curentModel,colectie=v.colectie,type=v.type})
        end
        vRPCds.getVehz(-1,{cars})
    end)
end
function getDBCars(player)
	theCars = {}
	exports["GHMattiMySQL"]:QueryResultAsync("SELECT * FROM vrp_showroom_vehicles ORDER BY price ASC",{},function(dbv)
		for i,v in pairs(dbv)do
			table.insert(theCars,{nume=v.nume,price=v.price,curentModel=v.curentModel,colectie=v.colectie,type=v.type})
		end
		vRPCds.getVehz(player,{theCars})
	end)
end
RegisterCommand("getdbvehs",function(source)
	updateShowroomCars()
end)

RegisterCommand("addveh",function(source)
	local user_id = vRP.getUserId({source})
	player = source
	if vRP.hasPermission({user_id,'dealership.addvehicleinshowroom'}) then
		vRP.prompt({player,"Nume: ","",function(player,nume)
			nume = tostring(nume)
			if nume ~= nil and nume ~= "" then
				vRP.prompt({player,"Pret:","",function(player,price)
					price = parseInt(price)
					if price ~= nil and price > 0 then
						vRP.prompt({player,"Model:","",function(player,curentModel)
							curentModel = tostring(curentModel)
							if curentModel ~= nil and curentModel ~= "" then
			
								vRPclient.notify(player,{"~y~[DEALERSHIP]~g~ Ai adaugat o masina noua in showroom!"})
								vRPclient.notify(player,{"~y~[SHOWROOM] ~r~Masina: ~g~"..nume})
								vRPclient.notify(player,{"~y~[SHOWROOM] ~r~Pret: ~g~"..vRP.formatMoney({tonumber(price)}).."$"})
								exports["GHMattiMySQL"]:QueryAsync("INSERT IGNORE INTO vrp_showroom_vehicles(nume,price,curentModel) VALUES(@nume,@price,@curentModel)",{
									['nume'] = nume,
									['price'] = price,
									['curentModel'] = curentModel
								})
    							updateShowroomCars()
		
							else
								vRPclient.notify(player,{"~r~Model invalid"})
							end
		
						end})
					else
						vRPclient.notify(player,{"~r~Pret invalid"})
					end
				end})
			else
				vRPclient.notify(player,{"~r~Nume invalid"})
			end
		end})
	else
		vRPclient.notify(player,{"~r~Te crezi fondator in pula mea de gras?"})
	end

end)


AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	if first_spawn then
		getDBCars(source)
	end
end)
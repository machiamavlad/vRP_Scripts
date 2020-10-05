local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vRP_policeDocs")

local show_policeDoc = {function(player,choice)
	user_id = vRP.getUserId({player})
	vRPclient.getNearestPlayers(player,{15}, function(nplayers)
		userList = ""
		for i,v in pairs(nplayers) do
			userList = userList.. "[".. vRP.getUserId({i}) .."]".. GetPlayerName(i).. " | "
		end
		if userList ~= "" then
			vRP.prompt({player,"Jucatori Apropriati: "..userList.."","", function(player,nearestId)
				nearestId = parseInt(nearestId)
				if nearestId ~= nil then
					local playerSource = vRP.getUserSource({nearestId})
					if playerSource ~= nil then
						vRP.getUserIdentity({user_id, function(identity)
							if identity then
								name = identity.name
								firstname = identity.firstname
								age = identity.age
    		    				vRP.getUserAddress({user_id, function(address)
    		    				  local home = ""
    		    				  local number = ""
    		    				  if address then
    		    				    home = address.home
    		    				    number = address.number
    		    				  else
    		    				  	home = "Fara Domiciliu"
    		    				  	number = 0
    		    				  end
									--TriggerClientEvent("showPoliceDocument", source, {name = "Comsa", firstname = "Mafiotu", age = 30, address = "Strada AmPulaMare Nr. 23"})
									vRP.request({playerSource, "<font color= 'red'>"..GetPlayerName(player).."</font> <font color= 'green'>["..vRP.getUserId({player}).."]</font> vrea sa-ti arate legitimatia. Accepti?",50, function(player,ok)
										if ok then
											if address then
												TriggerClientEvent("showPoliceDocument", playerSource, {name = name, firstname = firstname, age = age, address = home.." Nr. "..number})
											else
												TriggerClientEvent("showPoliceDocument", playerSource, {name = name, firstname = firstname, age = age, address = "Fara Domiciliu"})
											end
										end
									end})
								end})
							end
		
						end})
					else
						vRPclient.notify(player,{"~r~Acest jucator nu este in aproprierea ta."})
					end
				else
					vRPclient.notify(player, {"~r~Invalid value"})
				end
			end})
		end
	end)
end,"Show your Police Document to nearest player!"}


vRP.registerMenuBuilder({"police", function(add,data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
	
    if vRP.isUserInFaction({user_id,"cop.whitelisted"}) then
      choices["Show Document"] = show_policeDoc -- transforms money in wallet to money in inventory to be stored in houses and cars
    end
	
    add(choices)
  end
end})

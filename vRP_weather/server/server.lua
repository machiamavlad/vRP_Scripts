local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vRP_weather")

actWeather = 'NEUTRAL'
availableWeatherTypes = {
    'EXTRASUNNY', 
    'CLEAR', 
    'NEUTRAL', 
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT', 
    'XMAS', 
    'HALLOWEEN',
}

local choice_changeWeather = {function(player,choice)
	local user_id = vRP.getUserId({player})
	valid = false
	vRP.prompt({player,"Weather","EXTRASUNNY / CLEAR / NEUTRAL / SMOG / FOGGY / OVERCAST / CLOUDS / CLEARING / RAIN / THUNDER / SNOW / BLIZZARD / SNOWLIGHT / XMAS / HALLOWEEN",function(player,weather) 
		local theWeather = string.upper(weather)
		if theWeather ~= nil then
			for index,value in pairs(availableWeatherTypes) do
				if value == string.upper(theWeather)then
					valid = true
				end
			end
			if valid then
				TriggerClientEvent('machiamavlad:SetTheWeather', -1, theWeather)
				TriggerClientEvent("chatMessage", -1 , "^1[WEATHER]^0 Admin ^1"..GetPlayerName(player).."^0 has changed the weather to ^1"..theWeather)
			else
				vRPclient.notify(player,{"~r~Invalid weather type!"})
			end
		else
			vRPclient.notify(player,{"~r~Invalid syntax!"})
		end
	end})
end,"Change the current server weather!"}

vRP.registerMenuBuilder({"admin", function(add,data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
	
    if vRP.hasPermission({user_id,"change.weather"}) then
      choices["Change Weather"] = choice_changeWeather
    end
	
    add(choices)
  end
end})
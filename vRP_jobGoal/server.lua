local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_jobGoal")
fcJobG = Tunnel.getInterface("vRP_jobGoal","vRP_jobGoal")


fsJobG = {}
Tunnel.bindInterface("vRP_jobGoal",fsJobG)
Proxy.addInterface("vRP_jobGoal",fsJobG)

local facut = 0
local jobGoal = 150000 -- that's the value of the job goal
local permission = "" -- Permision to up the job goal


function formatMoney(amount)
  local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function fsJobG.cresteJobGoal(amount)
    facut = facut + amount
    if(facut >= jobGoal)then
      facut = 0
      local users = vRP.getUsers({})
      for machiamavlad,zeu in pairs(users) do
        local uSource = vRP.getUserSource({machiamavlad}) 
        local randomMoney = math.random(500,9500)
        SetTimeout(6000, function()
          fcJobG.jobGoalCompletat(uSource,{tonumber(randomMoney)})
          vRP.giveBankMoney({machiamavlad,randomMoney})
          vRPclient.notify(uSource,{"~o~[JOB GOAL] ~y~Job Goal has been finished!"})
        end)
      end
    end
end

RegisterCommand("jgup",function(source,args)
  local user_id = vRP.getUserId({source})
  if vRP.hasPermission({user_id,permission}) then
    if(args[1] ~= nil and tonumber(args[1]) > 0)then
      TriggerClientEvent("chatMessage", -1, "^1[JobGoal] ^2"..GetPlayerName(source).."^0 has raised the job goal with ^1"..formatMoney(tonumber(args[1])).."$^0!")
      fsJobG.cresteJobGoal(tonumber(args[1]))
    else
      vRPclient.notify(source,{"~r~Invalid number"})
    end
  else
    vRPclient.notify(source,{"~r~You don't have permission to execute this command!"})
  end
end)

RegisterCommand("jgreset", function(source)
  local user_id = vRP.getUserId({source})
  if(vRP.isUserFondator({user_id}))then
    local users = vRP.getUsers({})
    for i,v in pairs(users) do
      facut = 0
      TriggerClientEvent("chatMessage", -1, "^1[JobGoal] ^2"..GetPlayerName(source).."^0 has reseted the ^1Job Goal")
    end
  else
    vRPclient.notify(source,{"~r~You don't have permission to execute this command!"})
  end
end)

function fsJobG.getDate()
    
    local jobGoal = tonumber(jobGoal)
    local facut = tonumber(facut)

    if(facut == nil) then facut = 0 end
    local date = {
      ["facut"] = facut,
      ["jobGoal"] = jobGoal
    }
    return date
end

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
      facut = facut
      jobGoal = jobGoal
    end
end)

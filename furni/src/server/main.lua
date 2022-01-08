local Proxy = module('vrp','lib/Proxy')
local Tunnel = module('vrp','lib/Tunnel')

vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vrp','furni')
vRPSfurniture = {}
Tunnel.bindInterface('furni',vRPSfurniture)

vRPSfurniture.getCash = function()
  local user_id = vRP.getUserId({source})
  if user_id ~= nil then
    local cash = vRP.getMoney({user_id})
    if cash ~= nil then
      return cash
    end
  end
  return false
end
vRPSfurniture.canPlayerAfford = function(price)
  local user_id = vRP.getUserId({source})
  if user_id ~= nil then
    if vRP.tryFullPayment({user_id,tonumber(price)}) then
      return true
    end
  end
  return false
end

furni.givePlayerMoney = function(source,price)
  local user_id = vRP.getUserId({source})
  vRP.giveMoney({user_id,price})
end
furni.priceLookup = {}
CreateThread(function()
  for _,cat in pairs(furni.objects) do
    for k,v in pairs(cat) do
      furni.priceLookup[v.object] = v.price
    end
  end
end)
furni.placeFurniture = function(source,houseData,itemData,pos,rot,object)
  local truePrice = (furni.priceLookup[itemData.object] and furni.priceLookup[itemData.object] or false)
  if truePrice then
    exports.ghmattimysql:execute("SELECT * FROM `housing`",{},function(retData)
      for _,data in pairs(retData) do
        entry = json.decode(data.entry)
        if (math.floor(tonumber(houseData.entry.x)) == math.floor(tonumber(entry.x)) and math.floor(tonumber(houseData.entry.y)) == math.floor(tonumber(entry.y)) and math.floor(tonumber(houseData.entry.z)) == math.floor(tonumber(entry.z))) then
          local furniture = json.decode(data.furniture)
          local newPos = {x = pos.x, y = pos.y, z = pos.z}
          local newRot = {x = rot.x, y = rot.y, z = rot.z}
          table.insert(furniture,{pos = newPos, rot = newRot, model = itemData.object})
          local jTab = {}
          for k,v in pairs(furniture) do
            jTab[k] = {
              pos = {x = v.pos.x, y = v.pos.y, z = v.pos.z},
              rot = {x = v.rot.x, y = v.rot.y, z = v.rot.z},
              model = v.model,
            }
          end
          exports.ghmattimysql:execute("UPDATE `housing` SET furniture=@furniture WHERE id=@id",{['@furniture'] = json.encode(jTab),['@id'] = data.id})
          TriggerEvent('machiamavlad:SyncAllPlayers',data.id)
          TriggerEvent("machiamavlad:SetFurni",houseData,furniture)
          return
        end
      end
    end)
  end
end
Vdist = function(v1,v2)  
  if not v1 or not v2 or not v1.x or not v2.x or not v1.z or not v2.z then return 0; end
  return math.sqrt( ((v1.x - v2.x)*(v1.x-v2.x)) + ((v1.y - v2.y)*(v1.y-v2.y)) + ((v1.z-v2.z)*(v1.z-v2.z)) )
end
furni.deleteFurniture = function(source,houseData,itemData,pos,rot)
  if not itemData then return; end
  exports.ghmattimysql:execute("SELECT * FROM `housing`",{},function(retData)
    for _,data in pairs(retData) do
      entry = json.decode(data.entry)
      if (math.floor(tonumber(houseData.entry.x)) == math.floor(tonumber(entry.x)) and math.floor(tonumber(houseData.entry.y)) == math.floor(tonumber(entry.y)) and math.floor(tonumber(houseData.entry.z)) == math.floor(tonumber(entry.z))) then
        local furniture = json.decode(data.furniture)
        local jTab = {}
        local closest,closestDist
        for k,v in pairs(furniture) do
          local _p = vector3(v.pos.x + houseData.entry.x, v.pos.y + houseData.entry.y, v.pos.z + houseData.entry.z)
          local dist = Vdist(_p,pos)
          if not closestDist or dist < closestDist then
            closest = k
            closestDist = dist
          end
          jTab[k] = {
            pos = {x = v.pos.x, y = v.pos.y, z = v.pos.z},
            rot = {x = v.rot.x, y = v.rot.y, z = v.rot.z},
            model = v.model,
          }            
        end
        if closest and closestDist and closestDist < 1.0 then
          local truePrice = (furni.priceLookup[itemData.object] and furni.priceLookup[itemData.object] or false)
          if truePrice then
            table.remove(furniture,closest)
            table.remove(jTab,closest)
            furni.givePlayerMoney(source,math.floor(truePrice / 0.75))
            exports.ghmattimysql:execute("UPDATE `housing` SET furniture=@furniture WHERE id=@id",{['@furniture'] = json.encode(jTab),['@id'] = data.id})
            TriggerEvent('machiamavlad:SyncAllPlayers',data.id)
            TriggerEvent("machiamavlad:SetFurni",houseData,furniture)
          end
        end
        return
      end
    end
  end)
end
furni.replaceFurniture = function(source,houseData,itemData,pos,rot,object,lastObject)
  exports.ghmattimysql:execute("SELECT * FROM `housing`",{},function(retData)
    for _,data in pairs(retData) do
      entry = json.decode(data.entry)
      if (math.floor(tonumber(houseData.entry.x)) == math.floor(tonumber(entry.x)) and math.floor(tonumber(houseData.entry.y)) == math.floor(tonumber(entry.y)) and math.floor(tonumber(houseData.entry.z)) == math.floor(tonumber(entry.z))) then
        local furniture = json.decode(data.furniture)
        local newPos = {x = pos.x, y = pos.y, z = pos.z}
        local newRot = {x = rot.x, y = rot.y, z = rot.z}
        local jTab = {}
        for k,v in pairs(furniture) do
          if math.floor(v.pos.x + houseData.entry.x) == math.floor(lastObject.pos.x) and math.floor(v.pos.y + houseData.entry.y) == math.floor(lastObject.pos.y) and math.floor(v.pos.z + houseData.entry.z) == math.floor(lastObject.pos.z) and v.model == itemData.object then
            furniture[k].pos = newPos
            furniture[k].rot = newRot
          end
          table.insert(jTab,{
            pos = {x = v.pos.x, y = v.pos.y, z = v.pos.z},
            rot = {x = v.rot.x, y = v.rot.y, z = v.rot.z},
            model = v.model,
          })
        end
        exports.ghmattimysql:execute("UPDATE `housing` SET furniture=@furniture WHERE id=@id",{['@furniture'] = json.encode(jTab),['@id'] = data.id})
        TriggerEvent('machiamavlad:SyncAllPlayers',data.id)
        TriggerEvent("machiamavlad:SetFurni",houseData,furniture)
        return
      end
    end
  end)
end
RegisterNetEvent('furni:PlaceFurniture')
AddEventHandler('furni:PlaceFurniture', function(...) furni.placeFurniture(source,...); end)
RegisterNetEvent('furni:ReplaceFurniture')
AddEventHandler('furni:ReplaceFurniture', function(...) furni.replaceFurniture(source,...); end)
RegisterNetEvent('furni:DeleteFurniture')
AddEventHandler('furni:DeleteFurniture', function(...) furni.deleteFurniture(source,...); end)
AddEventHandler("Allhousing.Furni:GetPrices", function(cb) cb(furni.priceLookup); end)
Citizen.CreateThread(function()
  if LoadCallback then
    LoadCallback()
  end
end)
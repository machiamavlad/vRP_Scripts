local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","playerhousing")

vRPShousing = {}
Tunnel.bindInterface("playerhousing",vRPShousing)
Proxy.addInterface("playerhousing",vRPShousing)

shells = {
  ['Hotel'] = {
    prop = "shell_v16low",
    exit = vector4(-4.7,6.5,28.9,0.4)
  },
  ['Apartment'] = {
    prop = "shell_v16mid",
    exit = vector4(-1.4,13.9,28.85,0.8)
  },
  ['Trailer'] = {
    prop = "shell_trailer",
    exit = vector4(1.3,2.0,27.1,0.4)
  },
  ['Trevor'] = {
    prop = "shell_trevor",
    exit = vector4(-0.2,3.5,27.5,0.0)
  },
  ['Lester'] = {
    prop = "shell_lester",
    exit = vector4(1.5,5.8,28.1,3.1)
  },
  ['Ranch'] = {
    prop = "shell_ranch",
    exit = vector4(1.0,5.3,27.4,270.0)
  },
  ['HighEndV1'] = {
    prop = "shell_highend",
    exit = vector4(22.1,0.4,22.7,271.0)
  },
  ['HighEndV2'] = {
    prop = "shell_highendv2",
    exit = vector4(10.2,-0.9,23.4,270.0)
  },
  ['Michaels'] = {
    prop = "shell_michael",
    exit = vector4(9.3,-5.6,20.0,259.0)
  }
}
function inTable(k,table)
    if type(table) == 'table' then
        for kv,v in pairs(table) do
            if k:lower() == kv:lower() then return true end 
        end
    end
    return false
end
function GetShellData(shell)
  for kv,v in pairs(shells) do
    if shell:lower() == kv:lower() then return kv end
  end
  return false;
end
function table.fromvec(vec)   
    if not vec or (type(vec) ~= "vector3" and type(vec) ~= "vector4" and type(vec) ~= "vector2") or not vec.x then 
        return vec 
    end   
    if (vec.w) then     
        return {x = vec.x, y = vec.y, z = vec.z, w = vec.w}   
    elseif (vec.z) then     
        return {x = vec.x, y = vec.y, z = vec.z}   
    else     
        return {x = vec.x, y = vec.y}   
    end 
end


function table.tovec(tab)   
    if not tab or type(tab) ~= "table" or not tab.x then 
        return tab 
    end   
    if (tab.w or tab.h or tab.heading or tab.head) then     
        return vector4(tab.x,tab.y,tab.z,(tab.w or tab.h or tab.heading or tab.head))   
    elseif (tab.z) then     
        return vector3(tab.x,tab.y,tab.z)   
    else     
        return vector2(tab.x,tab.y)   
    end
end

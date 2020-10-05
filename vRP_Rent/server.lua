local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
MySQL = module("vrp_mysql", "MySQL")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_rent")

vRPSrent = {}
Tunnel.bindInterface("vRP_rent",vRPSrent)
Proxy.addInterface("vRP_rent",vRPSrent)
vRPCrent = Tunnel.getInterface("vRP_rent","vRP_rent")

function vRPSrent.verificaMoney(money)
    local id = vRP.getUserId({source})

    if vRP.tryFullPayment({id, tonumber(money)})then
        vRPclient.notify(source, {"~b~[RENT] ~w~Ai inchiriat ~y~Ford Crown Victoria ~w~."})
    else
        vRPclient.notify(source, {"~b~[RENT] ~r~Nu ai suficienti bani pentru a inchiria masina."})
    end
end
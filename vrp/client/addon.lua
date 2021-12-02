-----------------------------------------------------------------------
--           Cine fura ma-sa-i curva, semnat machiamavlad.           --
--               www.fantasyrp.ro | fivem.fantasyrp.ro               --
--                      discord.fantasyrp.ro                         --
-----------------------------------------------------------------------
--                  _._     _,-'""`-._                               --
--                  (,-.`._,'(       |\`-/|                          --
--                      `-.-' \ )-`( , o o)                          --
--                            `-    \`_`"'-                          --
-----------------------------------------------------------------------

function tvRP.executeCommand(s)
    if type(s) == "string" then
        ExecuteCommand(s)
    end
end
_G["PED"] = _G["PlayerPedId"]()
_G["COORDS"] = _G["GetEntityCoords"](_G["PED"])

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(1000)
        _G["PED"] = _G["PlayerPedId"]()
        _G["COORDS"] = _G["GetEntityCoords"](_G["PED"])
    end

end)
function drawTxt(text)
    SetTextFont(6)
    SetTextScale(0.40, 0.40)
    SetTextWrap(0.0, 1.0)
    SetTextCentre(false)
    SetTextDropshadow(2, 2, 0, 0, 0)
    SetTextEdge(1, 0, 0, 0, 205)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.905, 0.955)
end

local tickets = 0
RegisterNetEvent("TicketsUpdate", function(amm)
    tickets = amm
end)

function tvRP.setAdmin()
    Citizen.CreateThread(function()
        while true do
            drawTxt(string.format("~y~%02d ~w~Tickete", tickets))
            Citizen.Wait(1)
        end
    end)
end

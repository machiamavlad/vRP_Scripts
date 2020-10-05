local actWeather = 'EXTRASUNNY'
local lastWeather = actWeather
RegisterNetEvent('machiamavlad:SetTheWeather')
AddEventHandler('machiamavlad:SetTheWeather', function(theWeather)
    actWeather = theWeather
    Citizen.CreateThread(function()
        if lastWeather ~= actWeather then
            lastWeather = actWeather
            SetWeatherTypeOverTime(actWeather, 15.0)
            Citizen.Wait(15000)
        end
        while true do
            Citizen.Wait(100)
            ClearOverrideWeather()
            ClearWeatherTypePersist()
            SetWeatherTypePersist(lastWeather)
            SetWeatherTypeNow(lastWeather)
            SetWeatherTypeNowPersist(lastWeather)
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
    end)
end)
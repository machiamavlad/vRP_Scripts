local handsup = false
RegisterCommand("+handsup", function(...)
    if not IsPedInAnyVehicle(_GPED, false) and not IsPedSwimming(_GPED) and not IsPedShooting(_GPED) and not IsPedClimbing(_GPED) and not IsPedCuffed(_GPED) and not IsPedDiving(_GPED) and not IsPedFalling(_GPED) and not IsPedJumping(_GPED) and not IsPedJumpingOutOfVehicle(_GPED) and IsPedOnFoot(_GPED) and not IsPedRunning(_GPED) and not IsPedUsingAnyScenario(_GPED) and not IsPedInParachuteFreeFall(_GPED) then
        if DoesEntityExist(_GPED) then
            SetCurrentPedWeapon(_GPED, 0xA2719263, true)
            Citizen.CreateThread(function()
                RequestAnimDict("random@mugging3")
                while not HasAnimDictLoaded("random@mugging3") do
                    Citizen.Wait(100)
                end
                if not handsup then
                    handsup = true
                    TaskPlayAnim(_GPED, "random@mugging3", "handsup_standing_base", 8.0, -8, -1, 49, 0, 0, 0, 0)
                end   
            end)
        end
    end
end)

RegisterCommand("-handsup", function(...)
    if not IsPedInAnyVehicle(_GPED, false) and not IsPedSwimming(_GPED) and not IsPedShooting(_GPED) and not IsPedClimbing(_GPED) and not IsPedCuffed(_GPED) and not IsPedDiving(_GPED) and not IsPedFalling(_GPED) and not IsPedJumping(_GPED) and not IsPedJumpingOutOfVehicle(_GPED) and IsPedOnFoot(_GPED) and not IsPedRunning(_GPED) and not IsPedUsingAnyScenario(_GPED) and not IsPedInParachuteFreeFall(_GPED) then
        if DoesEntityExist(_GPED) then
            Citizen.CreateThread(function()
                RequestAnimDict("random@mugging3")
                while not HasAnimDictLoaded("random@mugging3") do
                    Citizen.Wait(100)
                end
                if handsup then
                    handsup = false
                    ClearPedSecondaryTask(_GPED)
                end
            end)
        end
    end
end)

RegisterKeyMapping("+handsup", "Ridica mainile", 'keyboard', 'X')
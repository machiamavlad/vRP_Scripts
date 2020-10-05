Citizen.CreateThread(function()

  local pdDoc = CreateRuntimeTxd("pdDoc")
  CreateRuntimeTextureFromImage(pdDoc, "pdDoc", "icons/pdDoc.png")
  
end)

someVariable = false
howMuchToWait = 10000

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function drawScreenText(x,y ,width,height,scale, text, r,g,b,a, outline, font, center)
  SetTextFont(font)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextCentre(center)
  if(outline)then
      SetTextOutline()
  end
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent("showPoliceDocument")
AddEventHandler("showPoliceDocument", function(data)
	local name = firstToUpper(data.name)
	local firstname = firstToUpper(data.firstname)
	local age = data.age
	local adresa = data.address -- let me think how i'll do this.
		someVariable = false
		if type(data) == "table" then
			Citizen.CreateThread(function()
				while not someVariable do
					Wait(1)
					DrawSprite("pdDoc","pdDoc",0.50,0.50,0.4,0.5,0.0,255,255,255,255) -- that's a random width and height only for test :))
					drawScreenText(0.5,0.42,0.0,0.0,0.6,name,255,255,255,255,1,1,1)
					drawScreenText(0.5,0.475,0.0,0.0,0.6,firstname,255,255,255,255,1,1,1)
					drawScreenText(0.5,0.535,0.0,0.0,0.6,age,255,255,255,255,1,1,1)
					drawScreenText(0.5,0.59,0.0,0.0,0.6,adresa,255,255,255,255,1,1,1)

				end
			end)
			Wait(howMuchToWait)
			someVariable = true
		end
end)
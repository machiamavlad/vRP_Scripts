fcJobG = {}
Tunnel.bindInterface("vRP_jobGoal",fcJobG)
Proxy.addInterface("vRP_jobGoal",fcJobG)
fsJobG = Tunnel.getInterface("vRP_jobGoal","vRP_jobGoal")
vRP = Proxy.getInterface("vRP")

local facut = 0
local showing = true
local jobGoal = 0


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
      
        fsJobG.getDate({},function(date)
            facut = date["facut"]
            jobGoal = date["jobGoal"]
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
            if showing then
                drawHudText(0.5,0.92,0.0,0.0,0.45,"~w~"..formatMoney(facut).." $~w~ / ~w~"..formatMoney(jobGoal).."$",255,255,255,255,1,4,1)
                local procent = math.floor((facut *100) / jobGoal)
                local jgw = math.floor(tonumber(procent/100)*100)
                if(jgw > 100)then
		    		jgw = 100
		    	end
                drawHudText(0.50, 0.895,0.0,0.0,0.3,"~w~Progres Job Goal ~s~"..procent.." %",0,255,0,255,1,0,1)
                DrawRect(0.50,0.94, 0.21,0.031,0,0,0,180)
                DrawRect(0.50, 0.94, (jgw/100)*0.2, 0.025, 0,255,0, 200)
            end
        Wait(0)
    end
end)

function drawHudText(x,y ,width,height,scale, text, r,g,b,a, outline, font, center)
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

local alpha = 255

function fcJobG.jobGoalCompletat(suma)
	arataRespect = not arataRespect
	TriggerEvent('InteractSound_CL:PlayOnOne', 'pass', 0.15)
	Citizen.CreateThread(function()
		while true do
			if alpha <= 5 then
				alpha = 180
				break
			end		
			if(arataRespect)then
                drawHudText(0.5, 0.40, 0,0, 2.0, "JOB GOAL PASSED!", 255, 183, 0, alpha, 1, 7, 1)
                
                drawHudText(0.5, 0.50, 0,0, 1.2, "RESPECT +", 255, 255, 255, alpha, 1, 7, 1)
				drawHudText(0.5, 0.55, 0,0, 1.3, "AI CASTIGAT ~g~" ..suma .."$", 255, 255, 255, alpha, 1, 7, 1)
			end
			SetTimeout(5000, function()
				alpha = alpha -1
			end)
			Citizen.Wait(0)
        end
        SetTimeout(4000, function()
		    arataRespect = false
            alpha = 255
        end)
	end)
end

function formatMoney(amount)
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

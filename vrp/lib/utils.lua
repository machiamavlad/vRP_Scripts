function returnDays(time)
	if (time / (time / 60) < 24) then
		return time .." ore"
	end
	return math.floor(tonumber(time / (24 * 60))) .. " zile si "..math.floor(tonumber(time % (24 * 60) / 60)).." ore"
end
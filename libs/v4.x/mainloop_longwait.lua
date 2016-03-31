local nbHeure = 12

local i = 0
while true do
	if (i >= (nbHeure*2) or i == 0) then
    	i = 0
                -- votre code ici
		-- fibaro:call(fibaro:getSelfId(), "pressButton", "11")
	end
	fibaro:sleep(30*60*1000)
  	i = i + 1
end
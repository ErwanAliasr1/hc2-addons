-- Copyright Erwan Velu 2015
-- This code is under GPL
--
--
-- Dependencies: none
--
-- Notes:
-- Please create an Water_total global variable to make this script working
-- Create a new channel on thingspeak with one field 
-- Update the <YOURAPIWRITEKEY> with the WRITE API KEY from thingspeak
-- Adjust the amount of water that was used everytime this script is triggered : this depend on your device
thingspeak = Net.FHttp('api.thingspeak.com')

amount_of_water_per_wakeup=1

payload = 'key=YOURWRITEAPIKEY&field1=' .. amount_of_water_per_wakeup
fibaro:setGlobal("Water_Total", fibaro:getGlobalValue('Water_Total') + 1)

local loops = 0
while true do
	response, status, errorCode = thingspeak:POST('/update', payload)
  	if tonumber(status) == 200 then
    	break;
    end
  	if loops == 10 then
    	fibaro:setGlobal("Water_Fail", fibaro:getGlobalValue('Water_Fail') + 1)
    	fibaro:log("Failed at updating water consumption")
    	loops = 0
    	break;
    else
    	fibaro:debug("Failed at sending info, retrying " .. loops .. "/10")
    end
    fibaro:sleep(500)
    loops = loops + 1
end

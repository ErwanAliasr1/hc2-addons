-- Copyright Erwan Velu 2015
-- This code is under GPL
--
--
-- Dependencies: none
--
-- Notes:
-- Please create an EDF_LAST_GLOBAL global variable to make this script working
-- Create a new channel on thingspeak with two fields : 1st for HP (high price hours), 2nd for HC (low cost hours)
-- The EDF_HC value is set by a simple block scene that set it up depending on the hour of the day
-- Update the <YOURAPIWRITEKEY> with the WRITE API KEY from thingspeak
thingspeak = Net.FHttp('api.thingspeak.com')
 
while true do
    local current_kwh = fibaro:getValue(89,'value')
    local last_kwh = fibaro:getGlobalValue('EDF_LAST_GLOBAL')
    local kwh_to_report = current_kwh - last_kwh
    fibaro:setGlobal('EDF_LAST_GLOBAL', current_kwh)
 
    local field_nb = 1
  	local other_field= 2
    if fibaro:getGlobalValue("EDF_HC") == "1" then
    	field_nb=2
    	other_field=1
    end
 
    payload = 'key=YOURAPIWRITEKEY&field'.. field_nb .. '='..kwh_to_report .. "&field" ..other_field.."=0"
    fibaro:debug("About to report " .. kwh_to_report .. "KWh (" .. current_kwh .. " - " .. last_kwh .. ")")
 
    current_date = os.date("%x")
 
 
    local loops = 0
    while true do
        response, status, errorCode = thingspeak:POST('/update', payload)
        if tonumber(status) == 200 then
            break;
        end
        if loops == 10 then
            fibaro:setGlobal("Elec_Fail", fibaro:getGlobalValue('Elec_Fail') + kwh_to_report)
            fibaro:log("Failed at updating elec consumption")
            loops = 0
            break;
        else
            fibaro:debug("Failed at sending info, retrying " .. loops .. "/10")
        end
        fibaro:sleep(500)
        loops = loops + 1
    end
  	fibaro:debug("Sleeping before retrying")
  	fibaro:sleep(1800000)
end

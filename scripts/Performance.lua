--[[
%% properties
%% globals
--]]

-- Parameters --
local id_exist = 56
local global_exist = "Chauffage"
local nbIteration = 1000

-- Do not touch please ---
local id_not_exist = 100056
local global_not_exist = "AABBCCDDEEFFGGHHIIFFF"

function log(name, start, cpu)
  	if (start) then
		fibaro:debug(string.format("<span style=\"font-family:monospace; white-space:pre; clear:both; float:right\">  %s instruction time : %ds | cpu time : %gs </span>", name, os.time()-start, os.clock()-cpu))
	else
		fibaro:debug(string.format("<span style=\"font-family:monospace; white-space:pre; clear:both; float:right\">  %s </span>", name))
    end
end

function execute(name, func)
  if (not pcall(function() 
        local start = os.time()
        local cpu = os.clock()
        for i= 1,nbIteration do
            func()
        end
        log(name, start, cpu)
    end)) then
  	fibaro:debug("ERROR : " .. name)
  end
end  

log("Nb runs : " .. nbIteration .. " | id : " .. id_exist .. " | G.Variable : " .. global_exist)
log("----------------------------------------------")
log("")

-- Tests ---
execute("getValue Exist      :", function() fibaro:getValue(id_exist, "value") end)
execute("getValue Not Exist  :", function() fibaro:getValue(id_not_exist, "value") end)
execute("setValue            :", function() fibaro:call(id_exist, "setValue", fibaro:getValue(id_exist, "value")) end)
execute("getGlobal Exist     :", function() fibaro:getGlobalValue(global_exist) end)
execute("getGlobal Not Exist :", function() fibaro:getGlobalValue(global_not_exist) end)
execute("setGlobal           :", function() fibaro:setGlobal(global_exist, fibaro:getGlobalValue(global_exist)) end)
execute("getType             :", function() fibaro:getType(id_exist) end)
execute("getName             :", function() fibaro:getName(id_exist) end)
execute("getRoomID           :", function() fibaro:getRoomID(id_exist) end)
execute("getRoomName         :", function() fibaro:getRoomName(fibaro:getRoomID(id_exist)) end)
execute("getSunrise          :", function() fibaro:getValue(1, "sunsetHour") end)
execute("boucle 1000         :", function() for j=1,1000 do k=j end end)

log("")
log("----------------------------------------------")
log("ALL DONE")

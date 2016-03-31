-- Paramètre en provenance de Netatmo DEV --
local n_client_id = ""
local n_client_secret = ""
local n_username = ""
local n_password = ""

--local hc2_module_virtuel = 139  -- le module virtuel "Pluie"

local debug = true -- affiche ou non les message dans la console

local long_lat_adjust = 0.1 -- ajustement de la distance pour trouvé un pluviomètre

local version = 2.0


-- ------------------------------------------------------------------------
-- Exécuté après chaque requète HTTP
-- Remplacer les commentaires par vos propres actions
-- ex : mettre la valeur dans une variable global ou 
-- l'afficher dans un MV
-- ------------------------------------------------------------------------
function afterHttpRequest()
	if (temperature_interieure > -1000) then end
	if (temperature_exterieure > -1000) then 
  		--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblTemp.value", temperature_exterieure .. "°C")     
  	end
	if (co2 > -1000) then
    	fibaro:setGlobal("CO2", co2)
  	end
	if (humidite_interne > -1000) then end
	if (humidite_externe > -1000) then 
  		--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblHum.value", humidite_externe .. "%") 
	end
	if (pression > -1000) then end
	if (bruit > -1000) then end
	if (rains["hour"] > -1000) then 
    	if (rains["hour"] == -1) then 
      		--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblHeure.value", "n/a") 
     	else
    		--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblHeure.value", " "..rains["hour"]) 
     	end
  	end
	if (rains["day"] > -1000) then 
    	if (rains["day"] == -1) then 
      		--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblJour.value", "n/a")
      	else
    		--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblJour.value", " "..rains["day"])
    	end
    end
	if (rains["week"] > -1000) then 
  		if (rains["week"] == -1) then 
    		--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblSemaine.value", "n/a")
    	else
  			--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblSemaine.value", " "..rains["week"])
  		end
    end
	if (rains["month"] > -1000) then 
		if (rains["month"] == -1) then 
			--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblMois.value", "n/a")
		else
			--fibaro:call(hc2_module_virtuel, "setProperty", "ui.lblMois.value", " "..rains["month"])
		end
   	end
end



-- ------------------------------------------------------------------------
--   NE PAS TOUCHER
-- ------------------------------------------------------------------------
local force_use_rain_public = true
local loc = api.get("/settings/location")
local lat_ne = loc.latitude + long_lat_adjust
local lon_ne = loc.longitude + long_lat_adjust
local lat_sw = loc.latitude - long_lat_adjust
local lon_sw = loc.longitude - long_lat_adjust

local token = ""
local int_id = ""
local ext_id = ""
local ext_bat = 0
local rain_id = ""
local rain_bat = 0

local temperature_interieure = -1000
local temperature_exterieure = -1000
local co2 = -1000
local humidite_interne = -1000
local humidite_externe = -1000
local pression = -1000
local bruit = -1000
local rains = {hour = -1000, day = -1000, week = -1000, month = -1000}

-- ------------------------------------------------------------------------
-- Affichage dans la console
-- ------------------------------------------------------------------------
function log(message, force)
  	force = force or false
	if (debug or force) then
		print(__convertToString(message))
   	end
end

-- ------------------------------------------------------------------------
-- Retourne le niveau de batterie en pourcent
-- ------------------------------------------------------------------------
function calcBat(bat, ext)
	local max = 6000
    local min = 4200 
    if (ext) then
       max = 6000
       min = 3600      
    end
    if (bat > max) then bat = max end
    return math.floor(bat * 100 / max)
end

-- ------------------------------------------------------------------------
-- Arrondi
-- ------------------------------------------------------------------------
local function roundToNthDecimal(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- ------------------------------------------------------------------------
-- Interrogation de l'API
-- ------------------------------------------------------------------------
function getResponseData(url, body, func)
	local http = net.HTTPClient()
	http:request(url, { 
		options = { 
			method = 'POST', 
        	headers = {
				["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
			},
			data = body
		},
		success = function(response) 
			func(json.decode(response.data)) 
			afterHttpRequest()
		end,
		error = function(response) log(" ERROR !!! " .. url, true) end,
	})   
end

-- ------------------------------------------------------------------------
-- Mesures de l'unité interne
-- ------------------------------------------------------------------------
function getMesuresInt()
	getResponseData("https://api.netatmo.net/api/getmeasure","access_token="..token.."&device_id="..int_id.."&scale=max&type=Temperature,CO2,Humidity,Pressure,Noise&date_end=last", 
		function(data)
			log("----------========== Module intérieur ==========----------")
			temperature_interieure = data.body[1].value[1][1]
			co2 = data.body[1].value[1][2]
			humidite_interne = data.body[1].value[1][3]
			pression = data.body[1].value[1][4]
			bruit = data.body[1].value[1][5]
			log("temperature_interieure = " .. temperature_interieure)
			log("co2 = " .. co2)
			log("humidite_interne = " .. humidite_interne)
			log("pression = " .. pression)
			log("bruit = " .. bruit)
		end
	)
end
 
-- ------------------------------------------------------------------------
-- Mesure de l'unité externe
-- ------------------------------------------------------------------------
function getMesuresExt()
	getResponseData("https://api.netatmo.net/api/getmeasure","access_token="..token.."&device_id="..int_id.."&module_id="..ext_id.."&scale=max&type=Temperature,Humidity&date_end=last", 
		function(data)
			log("----------========== Module extérieur ==========----------")
			temperature_exterieure = data.body[1].value[1][1]
			humidite_externe = data.body[1].value[1][2]
			log("temperature_exterieure = " .. temperature_exterieure)
			log("humidite_externe = " .. humidite_externe)
		end
	)
end

-- ------------------------------------------------------------------------
-- Obtention des informations sur un pluviomètre proche
-- ------------------------------------------------------------------------
function getRainNear()
	getResponseData("https://api.netatmo.net/api/getpublicdata","access_token="..token .. "&lat_ne="..lat_ne.."&lon_ne="..lon_ne.."&lat_sw="..lat_sw.."&lon_sw="..lon_sw, 
		function(data)
      		--log(data)
      		rains["week"] = -1
      		rains["month"] = -1
      		rains["hour"] = -1
      		rains["day"] = -1
			log("----------==========     D  e  v  i  c  e  s    =========----------")
      		for _, v in pairs(data.body) do
              for l, w in pairs(v.measures) do
                  if (type(w.rain_24h) ~= "nil") then
            		rains["day"] = w.rain_24h
            		rains["hour"] = w.rain_60min
                  end
              end
        	end
      		if (rains["day"] == -1000) then
        		log("Impossible de trouver un pluviomètre à proximité, augmentez [long_lat_adjust]", true)
        	else
               log("Pluie jour : " .. rains["day"])
               log("Pluie heure : " .. rains["hour"])
	       	end
		end
    )
end

-- ------------------------------------------------------------------------
-- Mesure du détecteur de pluie historique
-- ------------------------------------------------------------------------
function getMesuresRain(duree, variable)
	local now = os.time();
	getResponseData("https://api.netatmo.net/api/getmeasure","access_token="..token.."&device_id="..int_id.."&module_id="..rain_id.."&scale=1hour&type=sum_rain&real_time=true&date_begin="..os.date("!%c", (now - duree)), 
		function(data)
     		log("----------========== Pluie histo ==========----------")
			local cumul  = 0
            for k, v in pairs(data.body) do
              for l, w in pairs(v.value) do
                  cumul = cumul + w[1]
              end
            end
      		cumul = roundToNthDecimal(cumul, 2)
			rains[variable] = cumul
			log("rain["..variable.."] = " .. rains[variable])
		end
	)
end

-- ------------------------------------------------------------------------
-- Obtention des informations sur les devices
-- ------------------------------------------------------------------------
function getDevices()
	getResponseData("https://api.netatmo.net/api/devicelist","access_token="..token, 
		function(data)
			log("----------==========     D  e  v  i  c  e  s    =========----------")
      		for _, v in pairs(data.body.modules) do
       			if (v.data_type[1] == "Rain") then
           			rain_id = v._id
           			rain_bat = calcBat(v.battery_vp, true)
          		else
          			ext_id = v._id
          			ext_bat = calcBat(v.battery_vp, true)
           		end
        	end
      		int_id = data.body.devices[1]._id
      		getMesuresInt()
			getMesuresExt()
      		if (rain_id ~= "" and not force_use_rain_public) then
      			getMesuresRain(60 * 60, "hour")
      			getMesuresRain(60 * 60 * 24, "day")
      			getMesuresRain(60 * 60 * 24 * 7, "week")
      			getMesuresRain(60 * 60 * 24 * 30, "month")
        	else
        		getRainNear()
        	end
		end
    )
end

-- ------------------------------------------------------------------------
-- Authentification
-- ------------------------------------------------------------------------
function auth(nextFunction)
	local request_body = "grant_type=password&client_id=" .. n_client_id .. "&client_secret=" .. n_client_secret .. "&username=" .. n_username .. "&password=" .. n_password .. "&scope=read_station"
	getResponseData("https://api.netatmo.net/oauth2/token", request_body, 
    	function(data) 
			token = data.access_token
      		log(token)
        	nextFunction()
		end
	)
end
    
auth(getDevices)
log("Last request : "  .. os.date("%x - %X"), true)

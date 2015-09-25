
local hidden = false --- true pour exporter les devices cachés
local dead = false -- true pour exporter les devices morts
local useSections = false

local excludeType = {"com.fibaro.zwaveDevice", "weather", "HC_user", "iOS_device", "com.fibaro.voipUser"}
local excludeID = {}


local generateur = {

	devices = {},
	names = {},
	rooms = {},
	sections = {},

	devicesJSon = api.get("/devices"),
	roomsJSon = api.get("/rooms"),
	sectionsJSon = api.get("/sections"),

	-- Retourne la section souhaitée
	getSection = function(self, id)
		if (not useSections) then
			return ""
		end
		if (#self.sections == 0) then
			for k, v in ipairs(self.sectionsJSon) do
				self.sections[v.id] = v.name
			end
		end
		id = tonumber(id)
		if (type(self.sections[id]) == "nil") then
			return "inconnu"
		else
			return self.sections[id]
		end
	end,
	
	-- Retourne la pièce souhaitée
	getRoom = function(self, id) 
		if (#self.rooms == 0) then
			for k, v in ipairs(self.roomsJSon) do  
				self.rooms[v.id] = {}
				self.rooms[v.id].name = v.name
				self.rooms[v.id].sectionId = v.sectionID
				self.rooms[v.id].sectionName = self:getSection(v.sectionID)
			end 
		end
		id = tonumber(id)
		if (type(self.rooms[id]) == "nil") then
			return "inconnu", "inconnu", 0
		else
			return self.rooms[id].name, self.rooms[id].sectionName, self.rooms[id].sectionId
		end
	end,

	-- Retourne un nom unique
	addName = function(self, name, roomname)
		if (type(self.names[name]) == "nil") then
			self.names[name] = true
			return name
		else 
			return self:addName(name.."_"..roomname, roomname)
		end
	end,
	
	-- Supprime les caractères indésirables et rend le nom unique
	rename = function(self, name, roomname)
		local name = name:upper():gsub("[éêèë]", "E"):gsub("EE", "E"):gsub("[ûüù]", "U"):gsub("UU", "U"):gsub("[àâä]", "A"):gsub("AA", "A"):gsub("[öô]", "O"):gsub("OO", "O"):gsub("[îï]", "I"):gsub("II", "I"):gsub("%W", "_")
		local roomname = roomname:upper():gsub("[éêèë]", "E"):gsub("EE", "E"):gsub("[ûüù]", "U"):gsub("UU", "U"):gsub("[àâä]", "A"):gsub("AA", "A"):gsub("[öô]", "O"):gsub("OO", "O"):gsub("[îï]", "I"):gsub("II", "I"):gsub("%W", "_")
		return self:addName(name, roomname)
	end,
	
	proceed = function(self)
		for k, v in pairs(self.devicesJSon) do
			local doit = (hidden or v.visible) and (dead or not v.dead)
			if (doit) then  
				for h, w in pairs(excludeType) do
					if (v.type == w) then
						doit = false
					end
				end
				if (doit) then
					for h, w in pairs(excludeID) do
						if (v.id == w) then
							doit = false
						end
					end
				end
			end
			if (doit) then
				v.roomname, v.sectionname, v.sectionID = self:getRoom(v.roomID)
				table.insert(self.devices, v)
			end
		end	
		table.sort(self.devices, function(a,b) 
			if (not useSections) then 			
				return a.roomID < b.roomID 
			else
				return a.sectionname..a.roomname < b.sectionname..b.roomname
			end
		end)
		return self.devices;
	end

}

local result = "<BR><BR>-- IDs générés le : " .. os.date("%d/%m/%y à %X")
local room = ""
local section = ""
local lastinfo = ""


result = result .. "<BR><BR>local id = {"

local devices = generateur:proceed()
print(#devices)
for k, v in ipairs(devices) do
  	if (section ~= v.sectionname and useSections) then
    	section = v.sectionname
    	result = result .. "<BR><BR>-- SECTION :  "..v.sectionname	
	end
  	if (room ~= v.roomname) then
    	room = v.roomname
		if (not useSections) then
			result = result .. "<BR>"
		end
    	result = result .. "<BR>-- ROOM : "..v.roomname.."<BR>"
    end
  	lastinfo = generateur:rename(v.name, v.roomname)
	result = result .. lastinfo .. " = " .. v.id .. ", "
end
result = result .. "<BR>}"
result = result .. "<BR>"
result = result .. "<BR>-- usage :"
result = result .. "<BR>--     fibaro:getValue(id[\""..lastinfo .."\"], \"value\")"
result = result .. "<BR>--     GEA.add(id[\""..lastinfo .."\"], 30, \"\")"
print(result)
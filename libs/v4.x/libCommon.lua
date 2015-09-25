-- ===============================================
-- libCommon
-- ===============================================
-- Description :
--    Utilitaires divers de manipulations LUA
-- ===============================================
-- Version du firmeware : 4.x
-- Destination : Scénarios
-- ===============================================
libCommon = {
 
  	-- -----------------------------------------------
	-- Vérifie le type de variable et lève une 
        -- erreur au cas ou cela ne correspond pas
	-- -----------------------------------------------
	-- Paramètres :
	--    what : la variable 
  	--    typeOf : le type souhaité
	-- Retour :
	--    <none>
	-- Exemple :
	--    libCommon:assertType("Texte", "string")
        --    libCommon:assertType(maTable, "table")
	-- -----------------------------------------------
	assertType = function(self, what, typeOf)
		if (type(what) ~= typeOf) then error("Assert erreur " .. typeOf .. " attendu", 2) end
	end,
		
  	-- -----------------------------------------------
	-- Sépare une chaîne selon un séparateur
	-- -----------------------------------------------
	-- Paramètres :
	--    text : le texte à séparer
  	--    sep : le séparateur (, par défaut)
	-- Retour :
	--    un tableau de valeur
	-- Exemple :
	--    local lesC = libCommon:split("C1,C2,C3")
        --    local lesC = libCommon:split("C1-C2-C3", "-")
	-- -----------------------------------------------	
	split = function(self, text, sep)
		local sep, fields = sep or ":", {}
		local pattern = string.format("([^%s]+)", sep)
		text:gsub(pattern, function(c) fields[#fields+1] = c end)
		return fields
	end		
 
   	-- -----------------------------------------------
	-- Vérifie la condition et effectue l'une ou l'autre
        -- fonction selon le résultat
	-- -----------------------------------------------
	-- Paramètres :
	--    condition : la condition à tester
  	--    ifTrue : la function a exécuter si la condition est respectée
        --    ifFalse : la function a exécuter si la condition n'est pas respectée
	-- Retour :
	--    <none>
	-- Exemple :
	--    libCommon:iif(100<200, function() print("plus petit") end, function() print("plus grand") end)
	-- -----------------------------------------------
	iif = function(self, condition, ifTrue, ifFalse)
		self:assertType(condition, "boolean")
		self:assertType(ifTrue, "function")
		self:assertType(ifFalse, "function")
		if (condition) then return ifTrue() else return ifFalse() end
	end,
 
     	-- -----------------------------------------------
	-- Affiche un message dans la console de debug
        -- avec possibilité de couleur
	-- -----------------------------------------------
	-- Paramètres :
	--    msg : le message à afficher
  	--    color : la couleur (html) à utiliser
	-- Retour :
	--    <none>
	-- Exemple :
	--    libCommon:debug("Message en rouge", "red")
	-- -----------------------------------------------
	debug = function(self, msg, color)
		print("<span style=\"color:"..(color or "white")..";\">"..msg.."</span>")
	end,
 
       	-- -----------------------------------------------
	-- Converti un objet en chaîne pour le débug
	-- -----------------------------------------------
	-- Paramètres :
	--    what : la variable à afficher
	-- Retour :
	--    la variable sous forme de chaine
	-- Exemple :
	--    libCommon:stringOf(maTable)
        --    libCommon:stringOf(100=100)
	-- -----------------------------------------------
	stringOf = function(self, what)
		if (type(what) == "boolean") then
			if (what) then return "true" else return "false" end
		elseif (type(what) == "table") then
			if (json) then
				return json.encode(what)
			else
				return "table found"
			end
		else
			return tostring(what)
		end
	end,
 
}
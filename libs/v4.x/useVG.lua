-- ===============================================
-- Variables Globales
-- ===============================================
-- Description :
--    Fonctions permettant la manipulation des 
--    variables globales
-- ===============================================
-- Version du firmeware : 4.x
-- Destination : Scénarios
-- ===============================================

local VG = {

	-- -----------------------------------------------
	-- Retourne la valeur stockée dans une variable
	-- -----------------------------------------------
	-- Paramètres :
	--    nom : le nom de la variable à interroger
	-- Retour :
	--    la valeur de la varibale
	-- Exemple :
	--    VG:getValue("Test")
	-- -----------------------------------------------
	getValue = function(self, nom)
		return fibaro:getGlobalValue(nom)
	end,

	-- -----------------------------------------------
	-- Stocke la valeur dans une variable
	-- -----------------------------------------------
	-- Paramètres :
	--    nom : le nom de la variable à interroger
	--    valeur : la valeur à stocker
	-- Exemple :
	--    VG:setValue("Test", 100)
	-- -----------------------------------------------
	setValue = function(self, nom, valeur)
		fibaro:setGlobal(nom, valeur)
	end,

	-- -----------------------------------------------
	-- Retourne la date/heure de modification de la 
	-- variable
	-- -----------------------------------------------
	-- Paramètres :
	--   nom : le nom de la variable à interroger
	-- Retour :
	--    date/heure de la dernière modification
	--    c.f : http://www.lua.org/pil/22.1.html
	-- Exemple :
	--    local modif = VG:getDateModification("Test")
	--    modif.year, modif.hour, modif.min, ...
	-- -----------------------------------------------
	getDateModification = function(self, nom)
		return os.date("*t", fibaro:getGlobalModificationTime(nom))
	end,

	-- -----------------------------------------------
	-- Supprime une variable
	-- -----------------------------------------------
	-- Paramètres :
	--    nom : le nom de la variable à supprimer
	-- Exemple :
	--    VG:supprimer("Test")
	-- -----------------------------------------------
	supprimer = function(self, nom)
		api.delete("/globalVariables/" .. nom)
	end,

	-- -----------------------------------------------
	-- Modifie une variable
	-- -----------------------------------------------
	-- Paramètres :
	--    nom : le nom de la variable à modifier
	--    valeur : nouvelle valeur de la variable
	--    choix : un tableau des choix possible
	-- Exemples :
	--    VG:modifier("Endroit", "Maison", {"Maison", "Travail"})
	--    VG:modifier("NombreJours", 100)
	-- -----------------------------------------------
	modifier = function(self, nom, valeur, choix)
		local variable = {}
		variable.value = tostring(valeur)
		variable.isEnum = false
		if (type(choix) ~= "nil") then
			variable.isEnum = true
			variable.enumValues = choix
		end
		api.put("/globalVariables/" .. nom, variable)
	end,

	-- -----------------------------------------------
	-- Ajoute une variable
	-- -----------------------------------------------
	-- Paramètres :
	--    nom : le nom de la variable à ajouter
	--    valeur : la valeur de la variable
	--    choix : un tableau des choix possible
	-- Exemples :
	--    VG:ajouter("Endroit", "Maison", {"Maison", "Travail"})
	--    VG:ajouter("NombreJours", 100)
	-- -----------------------------------------------
	ajouter = function(self, nom, valeur, choix)
		local enum = 0
		if (type(choix) ~= "nil") then
			enum = 1
		end
		api.post("/globalVariables", {name=nom, isEnum=enum}) 
		self:modifier(nom, valeur, choix)
	end,

	-- -----------------------------------------------
	-- Voir si une variable existe ou non
	-- et la modifier ou créer
	-- -----------------------------------------------
	-- Paramètres :
	--    nom : le nom de la variable à traiter
	--    valeur : la valeur de la variable
	--    choix : un tableau des choix possible
	-- Exemples :
	--    VG:traiter("Endroit", "Maison", {"Maison", "Travail"})
	--    VG:traiter("NombreJours", 100)
	-- -----------------------------------------------
	traiter = function(self, nom, valeur, choix)
		if (fibaro:getGlobalValue(nom) == nil) then
			self:ajouter(nom, valeur, choix)
		elseif (type(choix) == "nil") then
			self:setValue(nom, valeur)
		else
			self:modifier(nom, valeur, choix)
		end
	end,
	
	-- -----------------------------------------------
	-- Retourne toutes les informations d'une variables
	-- -----------------------------------------------
	-- Paramètres :
	--    nom : le nom de la variable à traiter
	-- Exemples :
	--    local info = VG:getInfo("Test")
	--    info.value, info.name, info.readOnly,
	--    info.isEnum, info.enumValues, ...
	-- -----------------------------------------------
	getInfo = function(self, nom)
	  return api.get("/globalVariables/" .. nom)
	end,
		
}
-- ===============================================
-- libHour
-- ===============================================
-- Description :
--    Fonctions permettant la manipulation des 
--    dates / heures
-- ===============================================
-- Version du firmeware : 4.x
-- Destination : Scénarios
-- ===============================================
libHour = {

  	-- -----------------------------------------------
	-- Retourne une heure exploitable en lua
	-- -----------------------------------------------
	-- Paramètres :
	--    hour : l'heure souhaitée ex. 20:35
	-- Retour :
	--    un objet date/heure lua
	-- Exemple :
	--    libHour:toTime("20:35")
	-- -----------------------------------------------
	toTime = function(self, hour)
		if (libCommon) then libCommon:assertType(hour, "string") end
		local h,m = string.match(hour, "(%d+):(%d+)")
		local d = os.date("*t")
		local t = os.time{year=d.year, month=d.month, day=d.day, hour=h, min=m, sec=0}
		if (t < os.time()) then
			t= os.time{year=d.year, month=d.month, day=(d.day+1), hour=h, min=m, sec=0}
		end
		return t
	end,
	
  	-- -----------------------------------------------
	-- Retourne vrai si la date/heure est échue
	-- -----------------------------------------------
	-- Paramètres :
	--    time : l'objet date/time de référence
	-- Retour :
	--    vrai si la date/heure est échue
	-- Exemple :
	--    libHour:isPast(os.time()-10)
	-- -----------------------------------------------  
	isPast = function(self, time)
		if (libCommon) then libCommon:assertType(time, "number") end
		return time < os.time()
	end,
	
  	-- -----------------------------------------------
	-- Retourne vrai si l'heure est maintenant
	-- -----------------------------------------------
	-- Paramètres :
	--    hour : l'heure souhaitée ex. 20:35
	-- Retour :
	--    vrai si l'heure est maintenant
	-- Exemple :
	--    libHour:isNow("20:35")
	-- -----------------------------------------------   
	isNow = function(self, hour)
		if (libCommon) then libCommon:assertType(hour, "string") end
		local h,m = string.match(hour, "(%d+):(%d+)")
		local d = os.date("*t")
		local t = os.time{year=d.year, month=d.month, day=d.day, hour=h, min=m, sec=0}
		local now = os.time{year=d.year, month=d.month, day=d.day, hour=d.hour, min=d.min, sec=0}
		return t	== now
	end,
  
    	-- -----------------------------------------------
	-- Retourne la date et l'heure sous forme de chaine
	-- -----------------------------------------------
	-- Paramètres :
	--    <none>
	-- Retour :
	--    la date/heure au format "22/05/2015 - 20:35"
	-- Exemple :
	--    libHour:toString()
	-- ----------------------------------------------- 
	toString = function(self, hour)
		return os.date("%d/%m/%Y - %H:%M:%S")
	end,  
}
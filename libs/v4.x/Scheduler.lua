-- ===============================================
-- Scheduler
-- ===============================================
-- Description :
--    Un micro et basic scheduler
-- ===============================================
-- Version du firmeware : 4.x
-- Destination : Scénarios
-- ===============================================
Scheduler = {	

	events = {},
	started = false,
	
	-- -----------------------------------------------
	-- Retourne une durée exploitable par le sleep de fibaro
	-- -----------------------------------------------
	-- Paramètres :
	--    time : le nombre de secondes souhaité
	-- Retour :
	--    le nombre de millisecondes
	-- Exemple :
	--    Scheduler:getSleepDuration(10)
	-- -----------------------------------------------  
	getSleepDuration = function(self, time)
		return (time-t) * 1000 
	end,
	
	-- -----------------------------------------------
	-- !!! Insert un événement dans la liste !!!
        -- Utiliser Scheduler:add()
	-- -----------------------------------------------
	-- Paramètres :
	--    event : l'événement à ajouter
	-- Retour :
	--    <none>
	-- Exemple :
	--    Scheduler:insert(10)
	-- -----------------------------------------------    
	insert = function(self, event)
		local done = false
		local i = 1
		while not done and i <= #self.events do
			if (self.events[i].runAt > event.runAt) then
				table.insert(self.events, i, event)
				done = true
			end
			i = i + 1
		end
		if (not done) then
			self.events[#self.events+1] = event
		end
		table.sort(self.events, function(a,b) return a.runAt < b.runAt end)
	end,
	
  	-- -----------------------------------------------
	-- Ajoute un événement dans la liste
	-- -----------------------------------------------
	-- Paramètres :
	--    event : l'événement à ajouter
	-- Retour :
	--    <none>
	-- Exemple :
	--    Scheduler:add({time="20:35", func=function() print("") end, auto=true})
	-- -----------------------------------------------   
	add = function(self, event)
		if (type(event.time) == "string") then
				local d = os.date("*t")
				local h,m = string.match(time, "(%d+):(%d+)")
				event.runAt = os.time{year=d.year, month=d.month, day=d.day, hour=h, min=m, sec=0}
				if (event.runAt < os.time()) then
					event.runAt = os.time{year=d.year, month=d.month, day=(d.day+1), hour=h, min=m, sec=0}
				end
		elseif (not event.runAt) then
			event.runAt = os.time() + event.time
		end
		self:insert(event)
	end,
	
  	-- -----------------------------------------------
	-- !!! Execute le scheduler  !!!
        -- Utiliser Scheduler:start()
	-- -----------------------------------------------
	-- Paramètres :
	--    <none>
	-- Retour :
	--    <none>
	-- Exemple :
	--    Scheduler:run()
	-- -----------------------------------------------     
	run = function(self)
		while self.started do
			if (#self.events > 0) then
				local event = self.events[1]
				fibaro:sleep(self:getSleepDuration(event.runAt))
				if (self.started) then 
					event.func()
					if (event.auto) then
						self:add({time=event.time, func=event.func, auto=event.auto})
					end
					table.remove(self.events, 1)
				end
			end
		end
	end,
	
  	-- -----------------------------------------------
        -- Démarre le scheduler
	-- -----------------------------------------------
	-- Paramètres :
	--    <none>
	-- Retour :
	--    <none>
	-- Exemple :
	--    Scheduler:start()
	-- -----------------------------------------------     
	start = function(self)
		if (not Scheduler.started) then
			self.started = true
			self:run()
		end
	end,
	
  	-- -----------------------------------------------
        -- Stop le scheduler
	-- -----------------------------------------------
	-- Paramètres :
	--    <none>
	-- Retour :
	--    <none>
	-- Exemple :
	--    Scheduler:stop()
	-- -----------------------------------------------     
	stop = function(self)
		self.started = false
	end,
	
  	-- -----------------------------------------------
        -- Vide le scheduler de ses évennements
	-- -----------------------------------------------
	-- Paramètres :
	--    <none>
	-- Retour :
	--    <none>
	-- Exemple :
	--    Scheduler:clear()
	-- -----------------------------------------------     
	clear = function(self)
		self.events = {}
	end,

}
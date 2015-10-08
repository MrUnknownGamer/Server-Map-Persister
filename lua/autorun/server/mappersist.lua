local function ServerPrint(Message)
	print("[Map Persister] " .. Message)
end

if(game.IsDedicated()) then //CHANGE THIS WHEN FINISHED

	ServerPrint("Loaded.")
	 
	local Dir = "map_persist"
	local FileDir = Dir.."/settings.txt"
	
	//Check if settings file exists, if not, create one.
	if(!file.Exists(FileDir,"DATA"))then
	
		local Defaults = {safeshutdown = 1, lastmap = game.GetMap()}
	
		file.CreateDir(Dir)
		file.Write(FileDir, util.TableToJSON(Defaults, false))
		
		ServerPrint("Created settings file.")
		
	end
	
	//File read and writes
	local function getSettings()
		return util.JSONToTable(file.Read(FileDir,"DATA"))
	end
	local function setSettings(Table)
		file.Write(FileDir, util.TableToJSON(Table, false))
	end
	
	//Init
	//hook.Add( "Initialize", "mappersistinit", function()
		local Settings = getSettings()
		local SafeShut = Settings["safeshutdown"]
		local LastMap = Settings["lastmap"]
		
		if(SafeShut == 1)then
			ServerPrint("Server shutdown safely, not auto changing map.")
			SafeShut = 0
			LastMap = game.GetMap()
		else
			if(LastMap == game.GetMap())then
				ServerPrint("Current map is previous map, auto map change not needed.")
				SafeShut = 0
			else
				ServerPrint("Server did not shutdown correctly, map will soon change to ".. LastMap)
				
				hook.Add( "InitPostEntity", "some_unique_name", function()
					player.CreateNextBot("Map Changer")			
					ServerPrint( "Spawning bot to change map." )
				end)
				
				timer.Create( "persistmapchange", 3, 10, function()
		
					ServerPrint("Attempting to change map to " .. LastMap)
					RunConsoleCommand("changelevel", LastMap)
		
				end)
			end
		end
		
		//Save settings
		Settings["safeshutdown"] = SafeShut
		Settings["lastmap"] = LastMap
		setSettings(Settings)
	
	//end)
	
	hook.Add( "ShutDown", "shafeshutmappersist", function()
		ServerPrint("Safe shutdown detected.")
		local Settings = getSettings()
		Settings["safeshutdown"] = 1
		
		setSettings(Settings)
		
	end)

else

	ServerPrint("Map Persist is disabled. This server is not a dedicated server.")
	
end
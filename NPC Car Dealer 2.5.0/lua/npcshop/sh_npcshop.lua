
NPCSHOP = NPCSHOP or {}
NPCSHOP.Vehicles = {}
NPCSHOP.VehicleLookup = {}
NPCSHOP.PlayerVehicles = {}

/*
NPCSHOP.AddVehicle(name, class, model, price, jobrestriction, donatoronly)
*/
function NPCSHOP.AddVehicle(name, class, model, price, job, donatoronly)
	if not name or not class or not model or not price then
		local txt = "Invalid NPCShop Vehicle! ("..(name or "Unknown")..")"
		MsgN(txt)
		hook.Add("PlayerInitialSpawn", "NPCSHOPERRORVEH"..txt, function(ply)
			if ply:IsAdmin() then
				ply:PrintMessage(HUD_PRINTTALK, txt)
			end
		end)
		return
	end
	if NPCSHOP.VehicleLookup[class] then
		MsgN("Invalid NPCShop Vehicle! Duplicate vehicle! ("..name..")")
		return
	end
	
	job = job or {}
	if type(job) != "table" then job = {job} end
	donatoronly = donatoronly or false
	
	NPCSHOP.VehicleLookup[class] = table.insert(NPCSHOP.Vehicles, {name = name, class = class, model = model, price = price, job = job, donatoronly = donatoronly})
end

local meta = FindMetaTable("Player")
function meta:OwnsVehicle(class)
	if SERVER then
		local sid = self:SteamID()
		
		if not NPCSHOP.PlayerVehicles[sid] then
			return false
		end
		
		if NPCSHOP.PlayerVehicles[sid][class] then
			return true
		end
	else
		if not self.Vehicles then
			return false
		end
		
		if self.Vehicles[class] then
			return true
		end
	end
	
	return false
end


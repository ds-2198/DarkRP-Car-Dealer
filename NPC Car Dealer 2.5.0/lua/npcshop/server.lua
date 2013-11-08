
if not SERVER then return end

util.AddNetworkString( "npcshop_senddata" )

function SpawnnpcShop()
		local shop = ents.Create("npc_shop")
			shop:SetPos( Vector(-868.878723, -12786.181641, 74.968750) ) --Don't forget spawn vectors here!
			shop:SetAngles( Angle(9.002390, -1.786602, 0.000000) )
			shop:Spawn()
			shop:DropToFloor()
end

hook.Add("InitPostEntity", "SpawnnpcShop", SpawnnpcShop)

hook.Add("EntityTakeDamage", "PReventNPCfromdying", function( target, dmginfo )
	if target:IsNPC() and target:GetClass() == "npc_shop" then
		dmginfo:ScaleDamage(0)
	end
end)

local function IsDonator(ply)
	local isdonator = false
	for k,v in pairs(NPCSHOP.UserGroups) do
		if ply:GetUserGroup() == v then
			isdonator = true
			break
		end
	end
	return isdonator
end

//Utilizes darkrp's notify
local function Notify(ply, text)
	if not IsValid(ply) then return end
	umsg.Start("_Notify", ply)
		umsg.String(text)
		umsg.Short(0)
		umsg.Long(4)
	umsg.End()
end

local function SaveVehicles()
	local str = util.TableToJSON(NPCSHOP.PlayerVehicles)
	file.Write( "npcshopsaves.txt", str )
end
local function LoadVehicles()
	local str = file.Read( "npcshopsaves.txt", "DATA" ) or "[]"
	NPCSHOP.PlayerVehicles = util.JSONToTable(str)
end
LoadVehicles()
function SendVehicles(ply)
	local sid = ply:SteamID()
	local cars = NPCSHOP.PlayerVehicles[sid] or {}
	
	net.Start("npcshop_senddata")
		net.WriteTable(cars)
	net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "plyinitspawnnpcshop", function(ply)
	timer.Simple(2, function()
		SendVehicles(ply)
	end)
end)

local meta = FindMetaTable("Player")
function meta:AddVehicle( class )
	local sid = self:SteamID()
	if not NPCSHOP.PlayerVehicles[sid] then NPCSHOP.PlayerVehicles[sid] = {} end
	
	NPCSHOP.PlayerVehicles[sid][class] = true
	SaveVehicles()
	SendVehicles(self)
end

local function SpawnVehicle(ply, class)
	if not NPCSHOP.VehicleLookup[class] then return end
	if not NPCSHOP.Vehicles[NPCSHOP.VehicleLookup[class]] then return end
	
	if IsValid(ply.currentcar) then
		local d = ply.currentcar:GetDriver()
		if IsValid(d) and d != ply then
			Notify(d, "This car has been removed by its owner!")
		end
		ply.currentcar:Remove()
	end
	
	local vehicle = list.Get("Vehicles")[class]
	if not vehicle then return end
	
	local car = ents.Create(vehicle.Class)
		if not car then return end
		
		car:SetModel(vehicle.Model)
		
		if vehicle.KeyValues then
			for k, v in pairs(vehicle.KeyValues) do
				car:SetKeyValue(k, v)
			end
		end
	
		car.VehicleName = class
		car.VehicleTable = vehicle
		car.Owner = ply
	
	local carspawns = NPCSHOP.CarSpawn[game.GetMap()]
	local pos = carspawns.pos
	local ang = carspawns.ang
	
	car:SetPos(pos)
	car:SetAngles(ang)
	
	car:Spawn()
	car:Activate()
	car:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	car.SID = ply.SID
	car.ClassOverride = vehicle.Class
	if vehicle.Members then
		table.Merge(car, vehicle.Members)
	end
	car:keysOwn(ply)
	gamemode.Call("PlayerSpawnedVehicle", ply, car)
	
	ply.currentcar = car
end

concommand.Add("_npcshopbtnclick", function(ply, _, args)
	if #args != 1 then return end
	if not IsValid(ply) then return end
	
	if ply:GetPos():Distance(ents.FindByClass("npc_shop")[1]:GetPos()) > 80 then return end
	
	local class = args[1]
	if not NPCSHOP.VehicleLookup[class] then return end
	if not NPCSHOP.Vehicles[NPCSHOP.VehicleLookup[class]] then return end
	
	local cltbl = NPCSHOP.Vehicles[NPCSHOP.VehicleLookup[class]]
	
	if #cltbl.job > 0 then
		if not table.HasValue(cltbl.job, ply:Team()) then
			Notify(ply, "You're not in the correct job to spawn/purchase this!")
			return
		end
	end
	
	if ply:OwnsVehicle(class) then
		SpawnVehicle(ply, class)
		return
	end
	
	if cltbl.donatoronly and not IsDonator(ply) then
		Notify(ply, "You need to be Donator to buy this vehicle!")
		return
	end
	
	if not ply:canAfford(cltbl.price) then
		Notify(ply, "You do not have sufficient funds to purchase this!")
		return
	end
	
	ply:addMoney(-cltbl.price)
	Notify(ply, "You've bought the '" .. cltbl.name .. "' for "..(CUR or "$")..(cltbl.price).."!")
	ply:AddVehicle(class)
	
	umsg.Start("_updatenpcshopgui", ply)
		umsg.String(class)
	umsg.End()
end)

// DarkRP doesn't give me any way to check for job changes, then this shit is needed!

local bkp = meta.SetTeam
meta.SetTeam = function(self, job)
	bkp(self, job)
	
	if IsValid(self.currentcar) then
		local class = self.currentcar.VehicleName
		local cltbl = NPCSHOP.Vehicles[NPCSHOP.VehicleLookup[class]]
		
		if #cltbl.job > 0 then
			if not table.HasValue(cltbl.job, self:Team()) then
				self.currentcar:Remove()
				Notify(self, "Your current car isn't allowed for your new job!")
				return
			end
		end
	end
end

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

NPCSHOP = NPCSHOP or {}
function ENT:Initialize()
	self:SetModel( NPCSHOP.NPCModel or "models/humans/group01/female_01.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )
	self:CapabilitiesAdd( bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD) )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
 
	self:SetMaxYawSpeed( 90 )
end

function ENT:AcceptInput(name, activator, caller, data)
	if name == "Use" and IsValid(caller) and caller:IsPlayer() then
		umsg.Start("npcshop_openmenu", caller)
		umsg.End()
	end
end

hook.Add("PlayerInitialSpawn", "NPCSHOPDORENDEROVERRIDE", function(ply)
	for k,v in pairs(ents.FindByClass("npc_shop")) do
		umsg.Start("donpcshoprender", ply)
			umsg.Entity(v)
		umsg.End()
	end
end)

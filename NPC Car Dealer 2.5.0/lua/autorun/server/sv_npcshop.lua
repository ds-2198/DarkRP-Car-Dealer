
if not SERVER then return end

AddCSLuaFile('autorun/client/cl_npcshop.lua')
AddCSLuaFile('npcshop/config.lua')
AddCSLuaFile('npcshop/sh_npcshop.lua')
AddCSLuaFile('npcshop/gui.lua')
AddCSLuaFile('npcshop/drawnpctext.lua')

//hook.Add("InitPostEntity", "NPCSHOPSETUP", function()
	//if not FindMetaTable( "Player" ).GetUserGroup then error("NPCShop requires ULib!") return end
	//if not RPExtraTeams then error("NPCShop requires DarkRP!") return end
	
	MsgN("Starting NPCShop")
	include('npcshop/sh_npcshop.lua')
	include('npcshop/config.lua')
	include('npcshop/server.lua')
//end)

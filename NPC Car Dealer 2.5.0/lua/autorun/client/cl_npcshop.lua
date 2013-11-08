
if not CLIENT then return end

//hook.Add("InitPostEntity", "NPCSHOPSETUP", function()
	//if not FindMetaTable( "Player" ).GetUserGroup then error("NPCShop requires ULib!") return end
	//if not RPExtraTeams then error("NPCShop requires DarkRP!") return end
	
	MsgN("Starting NPCShop")
	include('npcshop/sh_npcshop.lua')
	include('npcshop/config.lua')
	include('npcshop/gui.lua')
	include('npcshop/drawnpctext.lua')
//end)
LocalPlayer().Vehicles = {}
net.Receive( "npcshop_senddata", function()
	LocalPlayer().Vehicles = net.ReadTable() or {}
end)

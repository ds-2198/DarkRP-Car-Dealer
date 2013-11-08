
surface.CreateFont("npcshop_large", {
		font = "Tahoma",
		size = 20,
		weight = 600,
		antialias = true
	})
surface.CreateFont("npcshop_small", {
		font = "Tahoma",
		size = 12,
		weight = 600,
		antialias = true
	})
	
local function IsPlyDonator()
	local isdonator = false
	for k,v in pairs(NPCSHOP.UserGroups) do
		if LocalPlayer():GetUserGroup() == v then
			isdonator = true
			break
		end
	end
	return isdonator
end

	
BUTTONTYPE_PURCHASE = 1
BUTTONTYPE_SPAWN = 2
local frame, pnllist

surface.SetFont("DermaDefault")
local txtw, txth = surface.GetTextSize("Donator")
txtw = 64 - txtw/2
txth = 10 - txth/2
local function AddVehicle(name, model, price, class, donatoronly, jobs)
	local pnl = vgui.Create("DPanel")
		pnl:SetTall(138)
		pnl.items = {}
		pnl.vehclass = class
	
	local icon = vgui.Create("DModelPanel", pnl)
		icon:SetSize(128, 128)
		icon:SetPos(5, 5)
		icon:SetModel(model)
		//icon:SetDirectionalLight(BOX_TOP, Color(100, 0, 255))
		icon:SetCamPos( Vector( 140, 140, 100 ) )
		icon:SetLookAt( Vector( 0, 0, 60 ) )
		icon.hovered = false
		icon.speed = 0
		icon.isdonator = donatoronly
		local paint = icon.Paint
		icon.Paint = function(self)
			surface.SetDrawColor(Color(0, 0, 0, 255))
			//surface.DrawRect(-2, -2, 132, 130)
			local x,y = self:LocalToScreen(0, 0)
			local parent = self:GetParent():GetParent():GetParent()
			local _,py = parent:LocalToScreen(0,0)
			local pytall = py + parent:GetTall()
			
			
			render.SetScissorRect(x, py, x + 128, y + math.max(pytall-y, 0), true)
			paint(self)
			render.SetScissorRect(0,0,0,0,false)
			
			if self.isdonator then
				surface.SetDrawColor(Color(129, 0, 0, 255))
				surface.DrawRect(0, 0, 128, 20)
				
				surface.SetTextColor(Color(255, 255, 255, 255))
				surface.SetFont("DermaDefault")
				surface.SetTextPos(txtw, txth)
				surface.DrawText("Donator")
			end
		end
		icon.OnCursorEntered = function(self) self.hovered = true end
		icon.OnCursorExited = function(self) self.hovered = false end
		icon.LayoutEntity = function(self, ent)
			if self.hovered then
				self.speed = math.min(self.speed + 0.05, 1)
			else
				self.speed = math.max(self.speed - 0.01, 0)
			end
			ent:SetAngles( ent:GetAngles() + Angle(0, self.speed, 0) )
		end
	pnl.items.icon = icon
	
	local wide = pnl:GetWide()
	local half = (wide - 128)/2
	
	surface.SetFont("npcshop_large")
	local headlblw, npcshoplargeh = surface.GetTextSize(name)
	headlblw = (half - headlblw/2) + 128
	
	local headlbl = vgui.Create("DLabel", pnl)
		headlbl:SetPos(headlblw, 5)
		headlbl:SetFont("npcshop_large")
		headlbl:SetColor(Color(50,50,50,255))
		headlbl:SetText(name)
		headlbl:SizeToContents()
		headlbl.txt = name
	pnl.items.headlbl = headlbl
	
	local pricelbl = vgui.Create("DLabel", pnl)
		pricelbl:SetPos(133, 50)
		pricelbl:SetText("Price: "..price)
		pricelbl:SetFont("npcshop_large")
		pricelbl:SetColor(Color(50,50,50,255))
		pricelbl:SizeToContents()
	pnl.items.pricelbl = pricelbl
	
	if #jobs > 0 then
		local jobsstring = ""
		for _,job in ipairs(jobs) do
			jobsstring = jobsstring .. team.GetName(job) .. ", "
		end
		jobsstring = string.sub(jobsstring, 1, -3)
		local jobslbl = vgui.Create("DLabel", pnl)
			jobslbl:SetPos(133, 50 + npcshoplargeh + 5)
			jobslbl:SetText("Jobs: "..jobsstring)
			jobslbl:SetFont("npcshop_large")
			jobslbl:SetColor(Color(50,50,50,255))
			jobslbl:SizeToContents()
		//pnl.items.jobslbl = jobslbl
	end
	
	local okbtn = vgui.Create("DButton", pnl)
		okbtn:SetText("Purchase")
		okbtn:SetSize(wide - 143, 30)
		okbtn:SetFont("npcshop_large")
		okbtn:SetPos(138, 103)
		okbtn.btntype = BUTTONTYPE_PURCHASE
		okbtn.DoClick = function(self)
			if self.btntype == BUTTONTYPE_PURCHASE then
				Derma_Query("Are you sure you want to buy '"..name.."'?", "Are you sure?", "Yes!", 
				function() 
					RunConsoleCommand("_npcshopbtnclick", class)
				end)
			else
				RunConsoleCommand("_npcshopbtnclick", class)
				self:GetParent():GetParent():GetParent():GetParent():Close()
			end
		end
		//print("IsPlyDonator?"..tostring(IsPlyDonator()))
		if not IsPlyDonator() and donatoronly then
			okbtn:SetDisabled(true)
		end
	pnl.items.okbtn = okbtn
	
	pnllist:AddItem(pnl)
end

local function CreateFrame()
	frame = vgui.Create("DFrame")
		frame:SetSize(600, 1000)
		frame:Center()
		frame:SetDeleteOnClose(false)
		frame:ShowCloseButton(true)
		frame:SetSizable(true)
		frame:SetDraggable(true)
		frame:SetTitle("NPC Vehicle Shop")
		frame:MakePopup()
		frame:DockPadding(5, 48, 5, 5)
		frame:SetMinWidth( 220 )
		frame:SetMinHeight( 200 )
	
	local lbl = vgui.Create("DLabel", frame)
		lbl:SetText("Hello, how can I help you?")
		lbl:SetPos(5, 28)
		lbl:SizeToContents()
	
	pnllist = vgui.Create("DPanelList", frame)
		pnllist:Dock(FILL)
		pnllist:EnableVerticalScrollbar(true)
		pnllist.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, Color(150, 150, 150, 255))
		end
		pnllist:SetSpacing(10)
		
		local perf = pnllist.PerformLayout
		pnllist.PerformLayout = function(self)
			perf(self)
			
			local wide = self:GetWide()
			local half = (wide - 128)/2
			surface.SetFont("DermaDefault")
			
			for k,v in pairs(self:GetItems()) do
				local headlblw = surface.GetTextSize(v.items.headlbl.txt)
				headlblw = half - headlblw/2 + 128
				v.items.headlbl:SetPos(headlblw, 5)
				
				v.items.okbtn:SetSize(wide - 143, 30)
			end
		end
		
	for _,v in pairs(NPCSHOP.Vehicles) do
		AddVehicle(v.name, v.model, v.price, v.class, v.donatoronly, v.job)
	end
end
local function UpdateFrame()
	for k,v in pairs(pnllist:GetItems()) do
		if LocalPlayer():OwnsVehicle(v.vehclass) then
			v.items.okbtn:SetText("Deploy")
			v.items.okbtn.btntype = BUTTONTYPE_SPAWN
		else
			v.items.okbtn:SetText("Purchase")
			v.items.okbtn.btntype = BUTTONTYPE_PURCHASE
		end
		
		//print("IsPlyDonator?"..tostring(IsPlyDonator()))
		if not IsPlyDonator() and v.items.icon.isdonator then
			v.items.okbtn:SetDisabled(true)
		else
			v.items.okbtn:SetDisabled(false)
		end
	end
end
local function OpenMenu()
	if not frame then
		CreateFrame()
		UpdateFrame()
	else
		UpdateFrame()
		frame:SetVisible(true)
	end
end
usermessage.Hook("npcshop_openmenu", OpenMenu)

usermessage.Hook("_updatenpcshopgui", function( um )
	local class = um:ReadString()
	
	for k,v in pairs(pnllist:GetItems()) do
		if v.vehclass == class then
			v.items.okbtn:SetText("Deploy")
			v.items.okbtn.btntype = BUTTONTYPE_SPAWN
		end
	end
end)

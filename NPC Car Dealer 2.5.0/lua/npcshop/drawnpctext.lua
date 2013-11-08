
surface.CreateFont("npctext_large", {
		font = "Tahoma",
		size = 100,
		weight = 600,
		antialias = true
	})
	
surface.SetFont("npctext_large")
local w,h = surface.GetTextSize("Shop")
local function Draw(self)
	self:DrawModel()
	
	local p = self:GetPos() + Vector(0,0,100 + math.sin(CurTime()*3)*5)
	
	for _,yaw in pairs({0, 180}) do
	
		local a = Angle(0, 0, 0)
		a:RotateAroundAxis(a:Forward(), 90)
		a:RotateAroundAxis(a:Right(), yaw)
		a:RotateAroundAxis(a:Right(), CurTime()*15)
		
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		cam.Start3D2D(p, a, 0.3)
			draw.DrawText("Car Dealer", "npctext_large", 0, 0, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
		render.PopFilterMag()
		render.PopFilterMin()
	end
end

usermessage.Hook("donpcshoprender", function(um)
	local ent = um:ReadEntity()
	if not IsValid(ent) then return end
	
	ent.RenderOverride = Draw
	
	local min,max = ent:GetRenderBounds()
	max = max + Vector(0,0,60)
	ent:SetRenderBounds(min, max)
end)

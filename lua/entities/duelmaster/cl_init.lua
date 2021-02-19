--Code by Magnus Tymoteus, all rights reserved
surface.CreateFont( "duelfont", {
	font = "CloseCaption_Normal", 
	extended = false,
	size = 40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = true,
} )
include("shared.lua")
function ENT:Draw()
    self:DrawModel()
end
hook.Add("HUDPaint", "dm_hud", function() 
    local eyetrace = LocalPlayer():GetEyeTrace()
    if(eyetrace.Entity:GetClass() == "duelmaster") then
    local playerPos_x = LocalPlayer():GetPos()[1]
    local playerPos_y = LocalPlayer():GetPos()[2]
    local entPos_x = eyetrace.Entity:GetPos()[1]
    local entPos_y = eyetrace.Entity:GetPos()[2]
    local distance = math.sqrt(math.pow((entPos_x - playerPos_x), 2) + math.pow((entPos_y - playerPos_y), 2))
    if(distance < 108) then
        draw.SimpleText("Duel Master", "duelfont", ScrW()/2, ScrH()/2, Color(255,255,255,61), 1, 1)
    end
end
end)
net.Receive("dm_used", function(len) 
    local frame = vgui.Create("DFrame")
    frame:SetSize(500,500)
    frame:Center()
    frame:SetTitle("Duel Master")
    frame.Paint = function(s,w,h) 
        draw.RoundedBox(5,0,0,w,h,Color(0,0,0, 240))end
    frame:SetVisible(true)
    frame:MakePopup()
end)
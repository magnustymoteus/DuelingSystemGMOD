--Made by Magnus Tymoteus, all rights reserved

surface.CreateFont( "panelfont", {
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
	shadow = false,
	additive = false,
	outline = false,
} )
function cutstring(string)
	if(string != nil) then
		if(string:sub(#string) == "\n") then
			string = string:sub(1, #string-1)
	end
end
	return string
end
function getConfigInfo(ent)
	if(ent:GetClass() == "duelpanel") then 
		duel_status = "disabled"
		duel_command = ""
		duel_reward = 0
		net.Start("drawn")
		net.SendToServer()
		net.Receive("duelConfig", function(len)
		duel_status = net.ReadString()
		duel_command = net.ReadString()
		duel_reward = net.ReadInt(16) 
end) end end
AddCSLuaFile("imgui.lua")
local imgui = include("imgui.lua")
include("shared.lua")
hook.Add("OnEntityCreated", "entCreated", getConfigInfo)
function ENT:Draw()
	self:DrawModel()
	local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Right(), 180)
    ang:RotateAroundAxis(ang:Forward(), 180)
	ang:RotateAroundAxis(ang:Up(), 180)
	if imgui.Entity3D2D(self, Vector(0,0,2), Angle(0,0,0), 0.1) then
	draw.RoundedBox(2, 0, -500,835,500,Color(0,0,0,245))
	draw.RoundedBox(2, 0, -500,835,20,Color(0,0,0,250))
	draw.RoundedBox(2, 355, -95,120,75,Color(0,255,0))
	draw.RoundedBox(2, 315, -275,200,50,Color(0,255,0))
	draw.RoundedBox(2, 315, -175,200,50,Color(0,255,0))
	draw.SimpleText("Duel Panel", "panelfont", 425,-455, Color(255,255,255), 1, 1)
	if cutstring(duel_status) == "enabled" then
		draw.RoundedBox(2, 315, -375,200,50,Color(255,0,0))
		dueling_btn = imgui.xTextButton("Disable", "panelfont", 315, -375, 200, 50, 1, Color(0,0,0), Color(0,255,0), Color(0,255,0))
	elseif cutstring(duel_status) == "disabled" then
		draw.RoundedBox(2, 315, -375,200,50,Color(0,255,0))
		dueling_btn = imgui.xTextButton("Enable", "panelfont", 315, -375, 200, 50, 1, Color(0,0,0), Color(255,0,0), Color(255,0,0))
	end
	draw.SimpleText("Dueling: "..cutstring(duel_status), "panelfont", 415,-400, Color(255,255,255), 1, 1)
	acttext = draw.SimpleText("Activation Command: "..duel_command, "panelfont", 420,-320, Color(255,255,255), 1, 0)
	draw.SimpleText("Reward Amount: "..tostring(duel_reward), "panelfont", 425,-200, Color(255,255,255), 1, 1)
	local act_btn = imgui.xTextButton("Change", "panelfont", 315, -275, 200, 50, 1, Color(0,0,0), Color(220,255,0), Color(255,0,0))
	local rew_btn = imgui.xTextButton("Change", "panelfont", 315, -175, 200, 50, 1, Color(0,0,0), Color(220,255,0), Color(255,0,0))
	if imgui.xTextButton("Submit", "panelfont", 355, -95, 120, 75, 1, Color(0,0,0), Color(220,255,0), Color(255,0,0)) then
		net.Start("duelconfig_clientsend")
		net.WriteString(cutstring(duel_status))
		net.WriteString(cutstring(duel_command))
		net.WriteInt(duel_reward, 16)
		net.SendToServer()
		chat.AddText("Settings submitted")
	end
	if dueling_btn then
		if cutstring(duel_status) == "enabled" then
			duel_status = "disabled"
		elseif cutstring(duel_status) == "disabled" then
			duel_status = "enabled"
		end
	end
	if act_btn then
		local frame = vgui.Create("DFrame")
		frame:SetSize(250,125)
		frame:SetTitle("Duel Command")
		frame:Center()
		local button = vgui.Create("DButton", frame)
		local actentry = vgui.Create("DTextEntry", frame)
		button:SetText("Enter")
		button:SetPos(95, 90)
		actentry:SetSize(150, 20)
		actentry:Center()
		frame:SetVisible(true)
		frame:MakePopup()
		button.DoClick = function() 
			duel_command = actentry:GetValue()
			frame:Close()
		end
	end
	if rew_btn then
		local frame = vgui.Create("DFrame")
		frame:SetSize(250,125)
		frame:SetTitle("Reward Amount")
		frame:Center()
		local button = vgui.Create("DButton", frame)
		local rewentry = vgui.Create("DTextEntry", frame)
		local rewwang = vgui.Create("DNumberWang", rewentry)
		rewwang:SetMinMax(0, 100000000)
		rewwang:SetValue(duel_reward)
		rewentry:SetSize(100,20)
		rewwang:SetSize(100,20)
		button:SetText("Enter")
		button:SetPos(95, 90)
		rewentry:Center()
		frame:SetVisible(true)
		frame:MakePopup()
		button.DoClick = function() 
			duel_reward = rewwang:GetValue()
			frame:Close()
		end
	end
	imgui.End3D2D()
end

end

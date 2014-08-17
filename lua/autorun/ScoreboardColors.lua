if SERVER then
	-- when the server loads this script, tell it to send it to clients
	AddCSLuaFile("ScoreboardColors.lua")
else
-- when a client runs it, add the hook
	function ScoreboardColor(ply)

		--Get a custom color
		if ply:GetPData("scoreboard_red") then
			red = tonumber(ply:GetPData("scoreboard_red"))
			green = tonumber(ply:GetPData("scoreboard_green"))
			blue = tonumber(ply:GetPData("scoreboard_blue"))
			
			return Color(red, green, blue)
		end


		-- Admins 
		if ply:IsUserGroup("admin") then
			return Color(205,55,230)
		-- Moderator
		elseif ply:IsUserGroup("moderator") then
			return Color(238,255,46)
		end


	end
	hook.Add("TTTScoreboardColorForPlayer", "SetSBColor", ScoreboardColor)
	
	net.Receive("playercolor", 
		function()
			steamid = net.ReadString()
			red = net.ReadUInt(8)
			green = net.ReadUInt(8)
			blue = net.ReadUInt(8)
			
			
			p = nil
			for _,v in pairs(player.GetAll()) do
				if steamid == v:SteamID() then
					p = v
					break
				end
			end
			
			if p then
				p:SetPData("scoreboard_red", red)
				p:SetPData("scoreboard_green", green)
				p:SetPData("scoreboard_blue", blue)
			end
		end
	)
	
	
end
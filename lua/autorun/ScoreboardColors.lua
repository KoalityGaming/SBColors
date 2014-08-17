if SERVER then
	-- when the server loads this script, tell it to send it to clients
	AddCSLuaFile("ScoreboardColors.lua")
else
	--Keep track of players with custom colors
	local colors = {}
	--Sometimes a connecting player will miss the initial broadcast when they join, track if they receive "playercolor"
	local recievedBroadcast = false

	function ScoreboardColor(ply)
	
		--Request a rebroadcast if nothing has been recieved.
		if not recievedBroadcast then
			net.Start("rebroadcast")
			net.SendToServer()
		end
			

		--Get a custom color
		if colors[ply:SteamID()] then
			red = tonumber(colors[ply:SteamID()][1])
			green = tonumber(colors[ply:SteamID()][2])
			blue = tonumber(colors[ply:SteamID()][3])
			
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
			
			
			for _,v in pairs(player.GetAll()) do
				if steamid == v:SteamID() then
					colors[steamid] = {red, green, blue}
					break
				end
			end
			

			recievedBroadcast = true
		end
	)
	
	net.Receive("removecolor",
		function()
			steamid = net.ReadString()
			colors[steamid] = nil
		end
	)
	
	
end
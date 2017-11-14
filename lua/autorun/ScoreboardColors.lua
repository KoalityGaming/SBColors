if SERVER then
	-- when the server loads this script, tell it to send it to clients
	AddCSLuaFile("ScoreboardColors.lua")
	util.AddNetworkString("rebroadcast")
	util.AddNetworkString("rebroadcast_users")
	util.AddNetworkString("rebroadcast_groups")
else
	--Keep track of players with custom colors
	local playerColors = {}
	--Keep track of group colors
	local groupColors = {}
	--Sometimes a connecting player will miss the initial broadcast when they join, track if they receive "playercolor"
	local receivedUserBroadcast = false
	local receivedGroupBroadcast = false

	function ScoreboardColor(ply)
	
		--Request a rebroadcast if no users have been received.
		if not receivedUserBroadcast then
			net.Start("rebroadcast_users")
			net.SendToServer()
		end
		
		--Request a rebroadcast if no groups have been received
		if not receivedGroupBroadcast then
			net.Start("rebroadcast_groups")
			net.SendToServer()
		end
			

		--Get a custom color
		if playerColors[ply:SteamID()] then
			red = tonumber(playerColors[ply:SteamID()][1])
			green = tonumber(playerColors[ply:SteamID()][2])
			blue = tonumber(playerColors[ply:SteamID()][3])
			
			return Color(red, green, blue)
		end
		
		--Get a group color (if no custom player color)
		if groupColors[ply:GetUserGroup()] then
			group = ply:GetUserGroup()
			red = tonumber(groupColors[group][1])
			green = tonumber(groupColors[group][2])
			blue = tonumber(groupColors[group][3])
			
			return Color(red, green, blue)
		end


	end
	hook.Add("TTTScoreboardColorForPlayer", "SetSBColor", ScoreboardColor)
	
	net.Receive("playercolor", 
		function()
			steamid = net.ReadString()
			red = net.ReadUInt(8)
			green = net.ReadUInt(8)
			blue = net.ReadUInt(8)
			
			
			playerColors[steamid] = {red, green, blue}
			receivedUserBroadcast = true
		end
	)
	
	
	net.Receive("removecolor",
		function()
			steamid = net.ReadString()
			playerColors[steamid] = nil
		end
	)
	
	net.Receive("removegroupcolor",
		function()
			group_name = net.ReadString()
			groupColors[group_name] = nil
		end
	)
	
	net.Receive("groupcolor",
		function()
			group_name = net.ReadString()
			red = tonumber(net.ReadUInt(8))
			green = tonumber(net.ReadUInt(8))
			blue = tonumber(net.ReadUInt(8))
			
			groupColors[group_name] = {red, green, blue}
			receivedGroupBroadcast = true
		end
	)
	
	
end
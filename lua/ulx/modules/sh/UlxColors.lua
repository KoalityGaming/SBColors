--[[
	Sets your scoreboard color to the provided r,g,b color code.
]]--
function ulx.color( calling_ply, red, green, blue)

	calling_ply:SetPData("scoreboard_red", red)
	calling_ply:SetPData("scoreboard_blue", blue)
	calling_ply:SetPData("scoreboard_green", green)
	
	sendSinglePlayer(calling_ply:SteamID(), red, green, blue)
	message = "#A changed their scoreboard color to ("..red..", "..green..", "..blue..")"
	
	
	ulx.fancyLogAdmin(calling_ply, message)
end
local color = ulx.command("Scoreboard Colors", "ulx color", ulx.color, "!color")
color:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="red"}
color:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="green"}
color:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="blue"}
color:defaultAccess( ULib.ACCESS_ADMIN )
color:help( "Sets your scoreboard color to an r,g,b color code." )

function ulx.givecolor( calling_ply, target_ply, red, green, blue)

	target_ply:SetPData("scoreboard_red", red)
	target_ply:SetPData("scoreboard_blue", blue)
	target_ply:SetPData("scoreboard_green", green)
	
	sendSinglePlayer(target_ply:SteamID(), red, green, blue)
	message = "#A changed #T scoreboard color to ("..red..", "..green..", "..blue..")"
	
	
	ulx.fancyLogAdmin(calling_ply, message, target_ply)
end
local givecolor = ulx.command("Scoreboard Colors", "ulx givecolor", ulx.givecolor, "!givecolor")
givecolor:addParam{ type=ULib.cmds.PlayerArg, hint="Target" }
givecolor:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="red"}
givecolor:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="green"}
givecolor:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="blue"}
givecolor:defaultAccess( ULib.ACCESS_SUPERADMIN )
givecolor:help( "Sets a players scoreboard color to an r,g,b color code." )

function ulx.uncolor(calling_ply, target_ply)

	target_ply:RemovePData("scoreboard_red")
	target_ply:RemovePData("scoreboard_green")
	target_ply:RemovePData("scoreboard_blue")
	
	message = "#A removed the scoreboard color from #T"
	ulx.fancyLogAdmin(calling_ply, message, target_ply)
	
	removeColor(target_ply:SteamID())
end
local uncolor =  ulx.command("Scoreboard Colors", "ulx uncolor", ulx.uncolor, "!uncolor")
uncolor:addParam{ type=ULib.cmds.PlayerArg, hint="Target" }
uncolor:defaultAccess( ULib.ACCESS_SUPERADMIN )
uncolor:help( "Removes someone's scoreboard color." )

function ulx.ungroupcolor(calling_ply, group_name)
	removeGroupColor(group_name)
	
end
local ungroupcolor =  ulx.command("Scoreboard Colors", "ulx ungroupcolor", ulx.ungroupcolor, "!ungroupcolor")
ungroupcolor:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
ungroupcolor:defaultAccess( ULib.ACCESS_SUPERADMIN )
ungroupcolor:help( "Removes a groups scoreboard color." )

function ulx.groupcolor(calling_ply, group_name, red, green, blue)
	setGroupColor(group_name, red, green, blue)
	sendGroupColor(group_name, red, green, blue)
end
local groupcolor = ulx.command("Scoreboard Colors", "ulx groupcolor", ulx.groupcolor, "!groupcolor")
groupcolor:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
groupcolor:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="red"}
groupcolor:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="green"}
groupcolor:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="blue"}
groupcolor:defaultAccess( ULib.ACCESS_SUPERADMIN )
	

if SERVER then
	util.AddNetworkString( "playercolor" )
	--Send a players color out
	function sendSinglePlayer(id, red, green, blue)
		net.Start( "playercolor" ) 
			net.WriteString(id)
			net.WriteUInt(red, 8)
			net.WriteUInt(green, 8)
			net.WriteUInt(blue, 8)
		net.Broadcast()
	end
	
	util.AddNetworkString("removecolor")
	--Remove a color from the clients
	function removeColor(id)
		net.Start("removecolor")
			net.WriteString(id)
		net.Broadcast()
	end
	
	util.AddNetworkString("removegroupcolor")
	--Remove a groups color
	function removeGroupColor(group_name)
	
		createTable()
		query = "DELETE FROM group_colors WHERE group_name=\'"..group_name.."\'"
		sql.Query(query)
	
		net.Start("removegroupcolor")
			net.WriteString(group_name)
		net.Broadcast()
	end
	
	function setGroupColor(group_name, red, green, blue)
		--Make sure the table exsts
		createTable()
		
		query = "SELECT * FROM group_colors WHERE group_name = \'" .. group_name .. "\'"
		result = sql.Query(query)
		
		--Getting a result means that there is an entry for this group
		if result then
			query = "UPDATE group_colors SET red="..red..",green="..green..",blue="..blue.. " WHERE group_name=\'" ..group_name.."\'"
			sql.Query(query)
		else
			query = "INSERT INTO group_colors VALUES(\'" .. group_name .. "\'," .. red .. "," .. green.. ",".. blue .. ")"
			sql.Query(query)
		end
	
	end
	
	function createTable()
		if (!sql.TableExists("group_colors")) then
			query = "CREATE TABLE group_colors ( group_name varchar(255), red int, green int, blue int )"
			result = sql.Query(query)
			if not result then
				return
			
			
			end
		end
	
	end
	
	util.AddNetworkString("groupcolor")
	function sendGroupColor(group_name, red, green, blue)
		net.Start("groupcolor")
			net.WriteString(group_name)
			net.WriteUInt(red, 8)
			net.WriteUInt(green, 8)
			net.WriteUInt(blue, 8)
		net.Broadcast()
	end

	--Send all the colors because someone doesn't have them
	util.AddNetworkString("rebroadcast_users")
	net.Receive("rebroadcast_users", 
		function() 
			for _,v in pairs(player.GetAll()) do
				if v:GetPData("scoreboard_red") then
					red = tonumber(v:GetPData("scoreboard_red"))
					green = tonumber(v:GetPData("scoreboard_green"))
					blue = tonumber(v:GetPData("scoreboard_blue"))
					
					sendSinglePlayer(v:SteamID(), red, green, blue)
				end
			end
		end
	)
	
	util.AddNetworkString("rebroadcast_groups")
	net.Receive("rebroadcast_groups", 
		function ()
			createTable()
			query = "SELECT * FROM group_colors"
			local result = sql.Query(query)
			
			if not result then return end
			i = 1
			while i <= #result do
				group_name = result[i]["group_name"]
				red = result[i]["red"]
				green = result[i]["green"]
				blue = result[i]["blue"]
				sendGroupColor(group_name, red, green, blue)
				
				i = i+1
			end
		end
	)
			

end
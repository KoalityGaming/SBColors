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
givecolor:defaultAccess( ULib.ACCESS_ADMIN )
givecolor:help( "Sets your scoreboard color to an r,g,b color code." )

function ulx.uncolor(calling_ply, target_ply)
	print(target_ply:SteamID())

	target_ply:RemovePData("scoreboard_red")
	target_ply:RemovePData("scoreboard_green")
	target_ply:RemovePData("scoreboard_blue")
	
	removeColor(target_ply:SteamID())
end
local uncolor =  ulx.command("Scoreboard Colors", "ulx uncolor", ulx.uncolor, "!uncolor")
uncolor:addParam{ type=ULib.cmds.PlayerArg, hint="Target" }
uncolor:defaultAccess( ULib.ACCESS_SUPERADMIN )
uncolor:help( "Removes somones scoreboard color." )

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
	function removeColor(id)
		net.Start("removecolor")
			net.WriteString(id)
		net.Broadcast()
	end

	--Send all the colors because someone doesn't have them
	util.AddNetworkString("rebroadcast")
	net.Receive("rebroadcast", 
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

end
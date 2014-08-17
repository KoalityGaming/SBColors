--[[
	Sets your scoreboard color to the provided r,g,b color code.
]]--


function ulx.sbcolor( calling_ply, red, green, blue)
	message = ""
	if Color(red, green, blue) then
		calling_ply:SetPData("scoreboard_red", red)
		calling_ply:SetPData("scoreboard_blue", blue)
		calling_ply:SetPData("scoreboard_green", green)
		
		sendSinglePlayer(calling_ply:SteamID(), red, green, blue)
		message = "#A changed their scoreboard color to ("..red..", "..green..", "..blue..")"
	else
		message = "#A attempted to set their scoreboard color to an invalid color: ("..red..", "..green..", "..blue..")"
		ULib.tsayError( calling_ply, "That is not a valid r,g,b color.", true )
	end
	
	ulx.fancyLogAdmin(calling_ply, message)
end
local sbcolor = ulx.command("Scoreboard Colors", "ulx sbcolor", ulx.sbcolor, "!sbcolor")
sbcolor:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="red"}
sbcolor:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="green"}
sbcolor:addParam{type = ULib.cmds.NumArg, min=0, max=255, hint="blue"}
sbcolor:defaultAccess( ULib.ACCESS_ADMIN )
sbcolor:help( "Sets your scoreboard color to an r,g,b color code." )

if SERVER then
	util.AddNetworkString( "playercolor" )

	function sendSinglePlayer(id, red, green, blue)
		net.Start( "playercolor" ) 
			net.WriteString(id)
			net.WriteUInt(red, 8)
			net.WriteUInt(green, 8)
			net.WriteUInt(blue, 8)
		net.Broadcast()
	end

	function SendColors() 
		for _,v in pairs(player.GetAll()) do
			if v:GetPData("scoreboard_red") then
				red = tonumber(v:GetPData("scoreboard_red"))
				green = tonumber(v:GetPData("scoreboard_green"))
				blue = tonumber(v:GetPData("scoreboard_blue"))
				
				sendSinglePlayer(v:SteamID(), red, green, blue)
			end
		end
	end

	hook.Add( "PlayerInitialSpawn", "colorAlert", SendColors )
end
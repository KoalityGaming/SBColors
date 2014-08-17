if SERVER then
	AddCSLuaFile("scoreboardranks.lua")
else

	function ScoreBoardRanks(board)
		
		board:AddColumn("Rank", RankPrint, 100)


	end
	
	function RankPrint(ply, label)
	
		label:SetTextColor(hook.Call("TTTScoreboardColorForPlayer", GAMEMODE, ply))

		--Some ranks are too long to fit, give them a different name
		if ply:IsUserGroup("user") then
			return "Guest"
			
		--For everyone else just capitalize the first letter 
		else
			s = ply:GetUserGroup()
			return s:sub(1,1):upper()..s:sub(2)
		end
			
		
	end
	hook.Add("TTTScoreboardColumns", "ScoreBoardRanks", ScoreBoardRanks)

	

end
function CreatePattern(pattern)
	pattern = string.gsub(pattern, "[%(%)%-%+%[%]]", "%%%1")
  	pattern = string.gsub(pattern, "%%s", "(.-)")
	pattern = string.gsub(pattern, "%%d", "%(%%d-%)")
	pattern = string.gsub(pattern, "%%%d%$s", "(.-)")
	pattern = string.gsub(pattern, "%%%d$d", "%(%%d-%)")
	
	return pattern
end

function RaiderCompare(a, b)
	return a.GUID < b.GUID
end

function PrintRaiderList(raidTable)
	SendChatMessage("----Raid roller member list----", "RAID", "common", nil)
	for i=1, #raidTable do
		SendChatMessage(i..": "..raidTable[i].Name.." ("..raidTable[i].GUID..")", "RAID", "common", nil)
	end
end

local rolledObject = ""

function GetRaidTable(memberCount)
	local raidTable = {};

	for i=1, memberCount, 1 do
		local name = GetRaidRosterInfo(i)
		local guid = UnitGUID(name)

		local temp = {}
		for w in guid:gmatch("([^-]+)") do 
			table.insert(temp, w)
		end

		local raider = {};
		raider.Name = name
		raider.GUID = tonumber(temp[#temp], 16)

		table.insert(raidTable, raider);
	end

	table.sort(raidTable, RaiderCompare)

	return raidTable;
end

function FindWinner(roll, low, high)
	roll = tonumber(roll)
	high = tonumber(high)
	local raidTable = GetRaidTable(high)
	SendChatMessage(raidTable[roll].Name.." wins "..rolledObject, "RAID_WARNING", "common", nil)
end

local frame = CreateFrame("Frame")
local rollPattern =  CreatePattern(RANDOM_ROLL_RESULT)
local guidPattern = CreatePattern("%s")
local playerName = UnitName("player")
local performedRaidRoll = false

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_SYSTEM");
frame:SetScript("OnEvent", function(addonLoadedFrame, event, arg1)
	if event == "PLAYER_LOGIN" then
		print("|cFF32a3beRaid roller:|r Type /rr <item> to roll")
		print("|cFF32a3beRaid roller:|r Type /rr list to show sorted raider list")
	elseif event == "CHAT_MSG_SYSTEM" then		
		if performedRaidRoll == true then
			for name, roll, low, high in string.gmatch(arg1, rollPattern) do
				if name == playerName then
					FindWinner(roll, low, high)
				end
			end
		end
		performedRaidRoll = false
	end
end)

SlashCmdList['RAIDROLLER_SLASHCMD'] = function(msg)
	local memberCount = GetNumGroupMembers()
	if memberCount == 0	then
		print("|cFF32a3beRaid roller:|r You are not in a party")
	else
		if msg == "list" then
			PrintRaiderList(GetRaidTable(memberCount))
		else
			if msg == "" or msg == nil then
				print("|cFF32a3beRaid roller:|r Missing item to roll for")
			else
				performedRaidRoll = true
				rolledObject = msg
				SendChatMessage("Raid rolling "..rolledObject, "RAID_WARNING", "common", nil)
				RandomRoll(1, memberCount);
			end
		end
	end
end
SLASH_RAIDROLLER_SLASHCMD1 = '/raidroller'
SLASH_RAIDROLLER_SLASHCMD2 = '/rr'
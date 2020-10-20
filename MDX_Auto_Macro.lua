local _, playerClass= UnitClass("player")
if playerClass == "HUNTER" or playerClass == "ROGUE" or playerClass == "DRUID" then
	local icon, spell, defaultTarget, role
	if playerClass == "HUNTER" then
		icon = 132180
		spell = "Misdirection"
		defaultTarget = "pet"
		role = "TANK"
	elseif playerClass == "ROGUE" then
		icon = 236283
		spell = "Tricks of the Trade"
		defaultTarget = "party1"
		role = "TANK"
	else -- DRUID
		icon = 136048
		spell = "Innervate"
		defaultTarget = "party1"
		role = "HEALER"
	end
	local needUpdate = false
	local iterateGroup = function(func)
		if IsInGroup() then
			local groupType = "raid"
			local numGroup = GetNumGroupMembers()
			if not IsInRaid() then
				groupType = "party"
				numGroup = numGroup -1
				func("player")
			end
			for i=1, numGroup do
				func(groupType..i)
			end
		else
			func("player")
		end
	end

	local updateMacros = function()
		local targets = {}
		local targetNumber = 0
		iterateGroup(function(member) 
			if UnitGroupRolesAssigned(member) == role then
				targetNumber = targetNumber +1
				targets[targetNumber] = member
			end
		end)
		for i=1, 4, 1 do
			local macroName = "MD"..i.."_Auto"
			if GetMacroInfo(macroName) then
				local body = "/use [@"..(targets[i] or defaultTarget).."]"..spell
				--EditMacro(index or macroName, name, icon, body, local, perCharacter)
				EditMacro(macroName, nil, icon, body)
			end
		end
	end

	local frame = CreateFrame("FRAME")

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")

	frame:SetScript("OnEvent", function(_, event, ...) frame[event](...) end)
	frame.PLAYER_ENTERING_WORLD = function()
		if UnitAffectingCombat("player") then
			needUpdate = true
		else
			updateMacros()
		end
	end
	frame.GROUP_ROSTER_UPDATE = frame.PLAYER_ENTERING_WORLD

	frame.PLAYER_REGEN_ENABLED = function()
		if needUpdate then
			updateMacros()
			needUpdate = false
		end
	end
	C_Timer.After(10, frame.GROUP_ROSTER_UPDATE)
end
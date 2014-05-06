// RAWR!

local PLUGIN = PLUGIN

local OPTION = {}
OPTION.active = true
OPTION.name = "Tie"
OPTION.icon = "icon16/link.png"
OPTION.desc = "Tie down the player"
OPTION.runCheck = function(client, target)
	if (target:GetNetVar("tied")||target:GetNutVar("beingTied")||target:GetNutVar("beingUnTied")) then
		return false
	end
	return true
end
OPTION.run = function(client, target)
	local i = 0
	
	target:SetMainBar("You are being tied by "..client:Name()..".", 5)
	target:SetNutVar("beingTied", true)
	client:SetMainBar("You are tieing "..target:Name()..".", 5)
	
	local uniqueID = "nut_Tieing"..target:UniqueID()
	
	timer.Create(uniqueID, 0.25, 20, function()
		i = i + 1
		if (!IsValid(client) or client:GetEyeTraceNoCursor().Entity != target or target:GetPos():Distance(client:GetPos()) > 128) then
			if (IsValid(target)) then
				target:SetMainBar()
				target:SetNutVar("beingTied", false)
			end
			
			if (IsValid(client)) then
				client:SetMainBar()
			end
			
			timer.Remove(uniqueID)
			
			return
		end

		if (i == 20) then
			target:SetNetVar("tied", true)
			
			local weapons = {}
			
			for k, v in pairs(target:GetWeapons()) do
				weapons[#weapons + 1] = v:GetClass()
			end
			
			target:SetNutVar("tiedWeapons", weapons)
			target:SetNutVar("tiedSpeed", target:GetRunSpeed())
			target:StripWeapons()
			target:SetRunSpeed(nut.config.walkSpeed)
			target:SetNutVar("beingTied", false)
		end
	end)
end
OPTION.itemsRequired = {}
OPTION.itemsTake = {
	["ziptie"] = 1,
}
OPTIONS:Register(OPTION)

local OPTION = {}
OPTION.active = true
OPTION.name = "Untie"
OPTION.icon = "icon16/link_break.png"
OPTION.desc = "Tie down the player"
OPTION.runCheck = function(client, target)
	if (!target:GetNetVar("tied")||target:GetNutVar("beingTied")||target:GetNutVar("beingUnTied")) then
		return false
	end
	return true
end
OPTION.run = function(client, target)
	local i = 0
	
	target:SetMainBar("You are being untied by "..client:Name()..".", 5)
	target:SetNutVar("beingUnTied", true)
	client:SetMainBar("You are untieing "..target:Name()..".", 5)
	
	local uniqueID = "nut_UnTieing"..target:UniqueID()
	
	timer.Create(uniqueID, 0.25, 20, function()
		i = i + 1
		if (!IsValid(client) or client:GetEyeTraceNoCursor().Entity != target or target:GetPos():Distance(client:GetPos()) > 128) then
			if (IsValid(target)) then
				target:SetMainBar()
				target:SetNutVar("beingUnTied", false)
			end
			
			if (IsValid(client)) then
				client:SetMainBar()
			end
			
			timer.Remove(uniqueID)
			
			return
		end
		
		if (i == 20) then
			target:SetNetVar("tied", false)
			
			local weapons = target:GetNutVar("tiedWeapons", {})
			
			for k, v in pairs(weapons) do
				target:Give(v)
			end
			
			target:SetRunSpeed(target:GetNutVar("tiedSpeed", nut.config.runSpeed))
			
			target:SetNutVar("tiedWeapons", nil)
			target:SetNutVar("tiedSpeed", nil)
			target:SetNutVar("beingUnTied", false)
		end
	end)
end
OPTION.itemsRequired = {}
OPTION.itemsTake = {}
OPTIONS:Register(OPTION)
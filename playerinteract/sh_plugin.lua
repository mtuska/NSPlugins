// RAWR!

local PLUGIN = PLUGIN
PLUGIN.name = "Player Interaction"
PLUGIN.author = "[MK] Servers"
PLUGIN.desc = "Adds the ability to access abilities on other players quickly."

nut.util.Include("sh_lang.lua")

OPTIONS = {}
OPTIONS.buttons = {}
function OPTIONS:Register( tbl )
	if (tbl.active == false||!tbl.run) then
		return
	end
	if (tbl.itemsRequired) then
		tbl.hasRequiredItems = function(client)
			for k, v in pairs( tbl.itemsRequired ) do
				if !client:HasItem( k, v ) then
					return false, k
				end
			end
			return true
		end
	end
	if (tbl.itemsTake) then
		tbl.hasRequiredTakeItems = function(client)
			for k, v in pairs( tbl.itemsTake ) do
				if !client:HasItem( k, v ) then
					return false, k
				end
			end
			return true
		end
	end
	if (!tbl.runCheck) then
		tbl.runCheck = function(client, target)
			return true
		end
	end
	tbl.icon = tbl.icon or "icon16/plugin_go.png"
	tbl.desc = tbl.desc or ""
	
	self.buttons[tbl.uid || #self.buttons+1] = tbl
end
function OPTIONS:Call(client, target, tbl)
	local bool = true
	if (tbl.hasRequiredItems) then
		local result, item = tbl.hasRequiredItems(client)
		local item = nut.item.Get(item)
		if (!result) then
			bool = false
			nut.util.Notify(nut.lang.Get("req_item", item.name), client)
		end
	end
	if (tbl.hasRequiredTakeItems) then
		local result, item = tbl.hasRequiredTakeItems(client)
		local item = nut.item.Get(item)
		if (!result) then
			bool = false
			nut.util.Notify(nut.lang.Get("req_item", item.name), client)
		end
	end
	if (!tbl.runCheck(client, target)) then
		bool = false
	end
	return bool
end

nut.util.Include("sh_interactions.lua")

if (SERVER) then
	netstream.Hook("nut_PlayerInteractAction", function(client, data)
		local target = data[1]
		local index = data[2]
		
		if (!target) then
			ErrorNoHalt("Target was not found! Target: "..tostring(target).."\n")
			return
		end
		
		local tbl = OPTIONS.buttons[index]
		if (!tbl) then
			return
		end
		local result = OPTIONS:Call(client, target, tbl)
		
		if (result != false) then
			if (tbl.hasRequiredTakeItems) then
				for k, v in pairs( tbl.itemsTake ) do
					client:UpdateInv(k, -v)
				end
			end
			tbl.run(client, target)
		end
	end)
	function PLUGIN:PlayerInteract(client, target)
		if (target:IsPlayer()||target:IsNPC()) then
			netstream.Start(client, "nut_PlayerInteractPlayer", target)
		end
	end
else
	netstream.Hook("nut_PlayerInteractPlayer", function(data)
		local target = data
		if (!data:IsPlayer()&&type(data)=="table") then
			target = data[1]
		end
		local client = LocalPlayer()
		if (!target) then
			ErrorNoHalt("Target was not found! Target: "..tostring(target).."\n")
			return
		end
		// Client side menu shits!?
		local menu = DermaMenu()
		for k, v in SortedPairs(OPTIONS.buttons) do
			if (v.runCheck and v.runCheck(client, target) == false) then
				continue
			end

			local material = v.icon or "icon16/plugin_go.png"

			local option = menu:AddOption(v.name or "Unknown", function()
				netstream.Start("nut_PlayerInteractAction", {target, k})
			end)
			option:SetImage(material)

			if (v.tip) then
				option:SetToolTip(v.tip)
			end
		end
		menu:Open()
		menu:Center()
	end)
end
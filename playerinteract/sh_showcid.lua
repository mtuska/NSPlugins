// RAWR!

local PLUGIN = PLUGIN

function PLUGIN:SchemaInitialized()
	local plugin = nut.plugin.Get("cidvisual")
	if (!plugin) then
		print(nut.lang.Get("plyact_missing_plugin", "cidvisual"))
		return
	end
	local OPTION = {}
	OPTION.active = true
	OPTION.name = "Show ID Forward"
	OPTION.icon = "icon16/arrow_up.png"
	OPTION.desc = "Show this CID to someone in front of you."
	OPTION.runCheck = function(client, target)
		if (target:IsNPC()) then
			return false
		end
		return true
	end
	OPTION.run = function(client, target)
		local default = false
		local cid = "cid"
		if cid then
			local itemdata = nut.item.Get(cid)
			if itemdata then
				if !itemdata.cid then
					default = true
					cid = PLUGIN.defaultcid
				end
			else
				local found = false
				for class, stack in pairs(client:GetInventory()) do
					local itemdata = nut.item.Get(class)
					if itemdata.cid then
						if string.find(string.lower(itemdata.name), string.lower(cid)) then
							cid = class
							found = true

							break
						end
					end
				end

				if !found then
					default = true
					cid = PLUGIN.defaultcid
				end
			end
		else
			cid = PLUGIN.defaultcid
		end
		
		local items = client:GetItemsByClass(cid)
		for k, v in pairs(items) do
			local data = v.data

			if data then
				if data.Digits and data.Owner then
					if default then
						nut.util.Notify( "No ID Itemdata, Showing default id.", client )
					end
					target:ShowCID( client, data.Digits or "000000", data.Owner or client:GetName(), data.Model or client:GetModel(), data.Forged or false )
				end
			end
		end
	end
	OPTION.itemsRequired = {
		["cid2"] = 1,
	}
	OPTION.itemsTake = {}
	OPTIONS:Register(OPTION)
end
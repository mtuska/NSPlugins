// RAWR!

local PLUGIN = PLUGIN

function PLUGIN:SchemaInitialized()
	local plugin = nut.plugin.Get("moderator")
	if (!plugin) then
		print(nut.lang.Get("plyact_missing_plugin", "moderator"))
		return
	end
	for k,v in pairs(pluginTable.commands) do
		if (v.hasTarget==false) then
			continue
		end
		local OPTION = {}
		OPTION.active = true
		OPTION.name = v.text or "Command"
		OPTION.icon = "icon16/control_equalizer_blue.png"
		OPTION.desc = v.desc or "Unknown"
		OPTION.runCheck = function(client, target)
			return pluginTable:IsAllowed(client, v.group)
		end
		OPTION.run = function(client, target)
			v.onRun(client, {}, target)
		end
		OPTION.itemsRequired = {}
		OPTION.itemsTake = {}
		OPTIONS:Register(OPTION)
	end
end
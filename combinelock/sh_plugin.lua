local PLUGIN = PLUGIN
PLUGIN.name = "Combine Lock"
PLUGIN.author = "Paradise" // Original author was Paradise, however I have editted from the original
PLUGIN.desc = "Adds new lock's for combine."

if (SERVER) then
	function PLUGIN:LoadData()
		for k, v in pairs(nut.util.ReadTable("comlocks")) do
			local position = v.pos
			local angles = v.angles
			//local Locked = v.Locked
			local model = v.model
			local door = v.door

			local entity = ents.Create("nut_union_lock")
			local index = door:LookupBone("handle")
			
			if (index and index > 0) then
				position = door:GetBonePosition(index)
				position = position + angles:Right()*-5 + angles:Forward()*4 + angles:Up()*10
			else
				position = position + angles:Right()*-4.5
			end
			entity:SetPos(position)
			entity:SetAngles(angles)
			entity:Spawn()
			entity:Activate()
			entity.door = door
			entity.door.locks = entity.door.locks or {}
			if (!table.HasValue(entity.door.locks, entity)) then
				table.insert(entity.door.locks, entity)
				/*for k, v in pairs(entity.door:GetDoorPartner()) do
					v.locks = v.locks or {}
					table.insert(v.locks, entity)
				end*/
			end
			//entity:ToggleLock(Locked)
			entity:ToggleLock(true)
			entity:SetParent(door)
			
			entity:SetModel(model)
		end
	end
	
	local playerMeta = FindMetaTable("Player")
	function playerMeta:CanUseComLock() // In case you don't already know, self will be the client/player
		if (self:GetItem("comkey")||self:IsCombine()) then
			return true // Yay, we can lock/unlock combine door locks!
		end
		return false // Boo, citizens don't touch my things!
	end
end
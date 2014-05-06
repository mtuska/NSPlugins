AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Union Lock"
ENT.Category = "HL2 RP"
ENT.Author = "Paradise"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Locked")
	self:NetworkVar("Bool", 1, "Erroring")
end

function ENT:SpawnFunction(client, trace)
	if (!IsValid(trace.Entity) or !trace.Entity:IsDoor()) then
		nut.util.Notify("You need to be aiming at a valid door.", client)

		return
	end

	local entity = ents.Create("nut_union_lock")
	entity:SetPos(trace.HitPos)
	entity:Spawn()
	entity:Activate()

	if (IsValid(trace.Entity) and trace.Entity:IsDoor()) then
		entity:SetDoor(trace.Entity, trace.HitPos, trace.HitNormal:Angle())
	end
 
	return entity
end

if (SERVER) then

	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_lock01.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self.damage = 150
	end

	function ENT:OnRemove()
		if (IsValid(self.door)) then
			self.door:Fire("unlock")
		end
	end

	function ENT:Use(activator)
		if (self:GetErroring()) then
			return
		end

		if (activator:CanUseComLock()) then
			//PrintTable(self.door.locks)
			self:ToggleLock()
			self.door:Fire("close")
		else 
			self:Error()
		end
	end

	function ENT:Error()
		self:EmitSound("buttons/combine_button1.wav")
		self:SetErroring(true)

		timer.Create("nut_CombineLockErroring"..self:EntIndex(), 1, 2, function()
			if (IsValid(self)) then
				self:SetErroring(false)
			end
		end)
	end

	function ENT:ToggleLock(override)
		if (override != nil) then
			self:SetLocked(override)
		else
			self:SetLocked(!self:GetLocked())
			if (self.door.locks) then
				for k,v in pairs(self.door.locks) do
					if (v==self) then continue end
					v:ToggleLock(self:GetLocked())
				end
			end
		end

		if (!self:GetLocked()) then
			self:EmitSound("buttons/combine_button5.wav")
			self.door:Fire("unlock")

			/*for k, v in pairs(self.door:GetDoorPartner()) do
				v:Fire("unlock")
			end*/
		else
			self:EmitSound("buttons/combine_button3.wav")
			self.door:Fire("lock")

			/*for k, v in pairs(self.door:GetDoorPartner()) do
				v:Fire("lock")
			end*/
		end
	end

	function ENT:SetDoor(door, position, angles)
		if (!IsValid(door)) then
			return
		end

		door.locks = door.locks or {}
		table.insert(door.locks, entity)
		for k, v in pairs(door:GetDoorPartner()) do
			v.locks = v.locks or {}
			table.insert(v.locks, entity)
		end
		self.door = door

		angles = angles or door:GetAngles()
		angles:RotateAroundAxis(angles:Up(), 270)

		local index = door:LookupBone("handle")

		if (index and index > 0) then
			position = door:GetBonePosition(index)
			position = position + angles:Right()*-5 + angles:Forward()*4 + angles:Up()*10
		else
			position = position + angles:Right()*-4.5
		end

		self:SetPos(position)
		self:SetAngles(angles)
		self:SetParent(door)
		
		local data = {}

		for k, v in pairs(ents.FindByClass("nut_union_lock")) do
			data[#data + 1] = {
				pos = v:GetPos(),
				angles = v:GetAngles(),		
				//Locked = v:GetNetVar("Locked", {}),
				model = v:GetModel(),
				door = v.door
			}
		end
		nut.util.WriteTable("comlocks", data)
	end
else
	local glowMaterial = Material("sprites/glow04_noz")
	local color_blue = Color(0, 70, 255)
	local color_green = Color(150, 255, 150)
	local color_red = Color(255, 0, 0)

	function ENT:Draw()
		self:DrawModel()

		local position = self:GetPos() + self:GetUp()*-8.7 + self:GetForward()*-3.85 + self:GetRight()*-6
		local color = self:GetLocked() and color_blue or color_green

		if (self:GetErroring()) then
			color = color_red
		end

		render.SetMaterial(glowMaterial)
		render.DrawSprite(position, 14, 14, color)
	end
end

function ENT:OnTakeDamage(dmg)
	self.damage = (self.damage or 100) - dmg:GetDamage()
	if self.damage <= 0 then
			self:Destruct()
			self:Remove()
			self.door:Fire("unlock")
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end


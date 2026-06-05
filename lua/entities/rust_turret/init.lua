AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
    self:SetModel("models/deployable/turret_base.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
    self.Wiring = true
    self.Name = "rust_turret"
    local obbmin = self:OBBMins()
    IO.Wiring.Inputs(self, self:GetPos() + Vector(0, obbmin.y + 12, obbmin.z + 27), "rust_turret")
end

function ENT:Touch(ent)
    if ent.CoolDown == nil then ent.CoolDown = 0 end
    if ent.CoolDown >= CurTime() then return end
    ent.CoolDown = CurTime() + 1
    if ent:GetClass() == "rust_turret_ymodel" and not self.NotHasPitch then
        self.Pitch = ents.Create("rust_turret_ymodel")
        self.Pitch:SetPos(self:GetPos() + Vector(0, 0, 30))
        self.Pitch:Spawn()
        self.Pitch:Activate()
        self.Pitch:SetParent(self)
        ent:Remove()
        self.NotHasPitch = true
    end

    if ent:GetClass() == "rust_turret_pmodel" and self.Pitch and not self.NotHasYaw then
        self.Yaw = ents.Create("rust_turret_pmodel")
        self.Yaw:SetPos(self:GetPos() + Vector(0, 0, 35))
        self.Yaw:Spawn()
        self.Yaw:Activate()
        self.Yaw:SetParent(self)
        self.NotHasYaw = true
        ent:Remove()
    end

    if ent:GetClass() == "rust_turret_gun_m4" and self.Pitch and self.Yaw and not self.NotHasGun then
        self.GunPos = ents.Create("rust_turret_gun_m4")
        self.GunPos:SetPos(self:GetPos() + Vector(0, 0, 31.5))
        self.GunPos:Spawn()
        self.GunPos:Activate()
        self.GunPos:SetParent(self.Pitch)
        self.NotHasGun = turret
        ent:Remove()
    end
end

function ENT:FindDistance()
    local dist = math.huge
    local targ = NULL
    for k, v in pairs(player.GetAll()) do
        local distance = self:GetPos():Distance(v:GetPos())
        if dist >= distance then
            dist = distance
            targ = v
        end
    end

    if targ == NULL then return Vector(0, 0, 0) end
    return targ
end

function ENT:Target()
    return self:FindDistance()
end

function ENT:Think()
    if self.Pitch and self.Yaw and self.GunPos then
        self.Pitch:SetAngles(self:Target():GetAngles())
        self.Yaw:SetAngles(self:Target():GetAngles())
        self.GunPos:SetAngles(self.Pitch:GetAngles() + Angle(0, 180, 0))
    end
end
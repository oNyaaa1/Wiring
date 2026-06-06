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

    self.Wiring      = true
    self.Name        = "rust_turret"
    self.NotHasPitch = false
    self.NotHasYaw   = false
    self.NotHasGun   = false

    -- Defer IO node creation one tick so the entity is fully spawned
    timer.Simple(0, function()
        if not IsValid(self) then return end
        local obbmin = self:OBBMins()
        IO.Wiring.Inputs(self, self:GetPos() + Vector(0, obbmin.y + 12, obbmin.z + 27), "rust_turret")
    end)
end

function ENT:Touch(ent)
    if not IsValid(ent) then return end
    if ent.CoolDown == nil then ent.CoolDown = 0 end
    if ent.CoolDown >= CurTime() then return end
    ent.CoolDown = CurTime() + 1

    if ent:GetClass() == "rust_turret_ymodel" and not self.NotHasPitch then
        self.Pitch = ents.Create("rust_turret_ymodel")
        self.Pitch:SetPos(self:GetPos() + Vector(0, 0, 30))
        self.Pitch:Spawn()
        self.Pitch:Activate()
        self.Pitch:SetParent(self)
        self.NotHasPitch = true
        ent:Remove()

    elseif ent:GetClass() == "rust_turret_pmodel" and IsValid(self.Pitch) and not self.NotHasYaw then
        self.Yaw = ents.Create("rust_turret_pmodel")
        self.Yaw:SetPos(self:GetPos() + Vector(0, 0, 35))
        self.Yaw:Spawn()
        self.Yaw:Activate()
        self.Yaw:SetParent(self)
        self.NotHasYaw = true
        ent:Remove()

    elseif ent:GetClass() == "rust_turret_gun_m4" and IsValid(self.Pitch) and IsValid(self.Yaw) and not self.NotHasGun then
        self.GunPos = ents.Create("rust_turret_gun_m4")
        self.GunPos:SetPos(self:GetPos() + Vector(0, 0, 31.5))
        self.GunPos:Spawn()
        self.GunPos:Activate()
        self.GunPos:SetParent(self.Pitch)
        self.NotHasGun = true  -- was: self.NotHasGun = turret (nil variable)
        ent:Remove()
    end
end

-- Returns the nearest player, or NULL
function ENT:FindTarget()
    local dist = math.huge
    local targ = NULL
    for _, pl in pairs(player.GetAll()) do
        if not IsValid(pl) or not pl:Alive() then continue end
        local d = self:GetPos():Distance(pl:GetPos())
        if d < dist then
            dist = d
            targ = pl
        end
    end
    return targ
end

function ENT:Think()
    if not (IsValid(self.Pitch) and IsValid(self.Yaw) and IsValid(self.GunPos)) then return end

    local targ = self:FindTarget()
    if not IsValid(targ) then return end

    -- Calculate aim angle from turret base to target
    local gunPos  = self.GunPos:GetPos()
    local targPos = targ:GetPos() + Vector(0, 0, 40) -- aim at chest
    local aimAng  = (targPos - gunPos):Angle()

    -- Yaw: horizontal rotation only
    local yawAng  = Angle(0, aimAng.y, 0)
    -- Pitch: vertical rotation only
    local pitchAng = Angle(aimAng.p, aimAng.y, 0)

    self.Yaw:SetAngles(yawAng)
    self.Pitch:SetAngles(pitchAng)
    self.GunPos:SetAngles(pitchAng + Angle(0, 180, 0))

    self:NextThink(CurTime() + 0.05)
    return true
end

function ENT:OnSignal(value, from)
    -- Called when wired input fires; extend as needed
    print("[rust_turret] Signal received:", value, from)
end

function ENT:OnRemove()
end

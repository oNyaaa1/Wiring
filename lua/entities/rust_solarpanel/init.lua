AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
    self:SetModel("models/electricity/solar_panel.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
    self.Wiring = true
    self.Name = "rust_solarpanel"
    self:SetAngles(Angle(0, 0, 0))
    timer.Simple(0, function()
        if not IsValid(self) then return end
        local obbmin = self:OBBMins()
        --IO.Wiring.Inputs(self, self:GetPos() + Vector(40, 3, obbmin.z + 2), "rust_solarpanel")
        IO.Wiring.Output(self, self:GetPos() + Vector(-45, 3, obbmin.z + 2), "rust_solarpanel")
    end)

    self.CoolDown = 0
end

function ENT:Think()
    if self.CoolDown >= CurTime() then return end
    self.CoolDown = CurTime() + math.random(3, 8)
    local sun = ents.FindByClass("env_sun")[1]
    if not sun then return end
    local startPos = self:GetPos()
    local dir = sun:GetUp()
    local trace = util.TraceLine({
        start = startPos,
        endpos = startPos + dir * 50000,
        filter = self, -- ignore the entity itself
        mask = MASK_ALL,
    })

    if not trace.HitWorld then return end
    local entPower = self.OutputNode.ConnectedToEnt
    if not entPower then return end
    entPower.Charge = entPower.Charge + 1
    net.Start("rust_WriteVoltage")
    net.WriteEntity(entPower)
    net.WriteFloat(entPower.Charge)
    net.Broadcast()
end

function ENT:OnRemove()
end
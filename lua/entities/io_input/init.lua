AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    phys:Wake()
    self.Wiring = true
end

function ENT:Input(wire)
    if self.Wiring == nil then return end
    if self.Outputs then end
end

function ENT:Use(act, pl)
end

function ENT:OnTakeDamage(dmg)
end

function ENT:Think()
end

function ENT:OnRemove()
end
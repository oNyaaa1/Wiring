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
    if IsValid(phys) then phys:Wake() end
end

function ENT:OnRemove()
    -- Notify the connected input that this output is gone
    if IsValid(self.ConnectedTo) then
        self.ConnectedTo.ConnectedFrom = nil
        net.Start("RWiring_RemoveConnection")
        net.WriteEntity(self)
        net.WriteEntity(self.ConnectedTo)
        net.Broadcast()
    end
end
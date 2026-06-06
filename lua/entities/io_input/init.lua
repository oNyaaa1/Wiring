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
    -- Notify the connected output that this input is gone
    if IsValid(self.ConnectedFrom) then
        self.ConnectedFrom.ConnectedTo = nil
        net.Start("RWiring_RemoveConnection")
            net.WriteEntity(self.ConnectedFrom)
            net.WriteEntity(self)
        net.Broadcast()
    end
end

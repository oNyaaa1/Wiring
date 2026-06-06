AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
    self:SetModel("models/electricity/small_battery.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
    self.Wiring = true
    self.Name = "rust_battery"
    self.Charge = 25
    self.MaxCharge = 300
    -- Defer IO node creation one tick so the entity is fully spawned
    self:SetAngles(Angle(0, 0, 0))
    timer.Simple(0, function()
        if not IsValid(self) then return end
        local obbmin = self:OBBMins()
        IO.Wiring.Inputs(self, self:GetPos() + Vector(7, 3, obbmin.z + 12), "rust_battery")
        IO.Wiring.Output(self, self:GetPos() + Vector(-7, 3, obbmin.z + 12), "rust_battery")
    end)

    net.Start("rust_WriteVoltage")
    net.WriteEntity(self)
    net.WriteFloat(self.Charge)
    net.Broadcast()
end

function ENT:OnRemove()
end
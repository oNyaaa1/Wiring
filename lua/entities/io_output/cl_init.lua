include("shared.lua")
function ENT:Initialize()
end

function ENT:Draw()
    self:DrawModel()
    --surface.SetDrawColor(255, 255, 255, 128)
    --surface.DrawOutlinedRect(25, 25, 100, 100, 10)
end

function ENT:Think()
end
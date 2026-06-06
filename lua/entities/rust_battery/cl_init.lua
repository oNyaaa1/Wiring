include("shared.lua")
function ENT:Initialize()
end

net.Receive("rust_WriteVoltage", function()
    local ent = net.ReadEntity()
    local flt = net.ReadFloat()
    ent.Voltage = flt
end)

local function Draw3DText(pos, ang, scale, text, flipView)
    if flipView then ang:RotateAroundAxis(Vector(0, 0, 1), 180) end
    cam.Start3D2D(pos, ang, scale)
    draw.SimpleTextOutlined(text, "Default", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
    cam.End3D2D()
end

function ENT:Draw()
    if self.Voltage == nil then self.Voltage = 0 end
    self:DrawModel()
    local text = "Voltage: " .. self.Voltage or 0
    local mins, maxs = self:GetModelBounds()
    local pos = self:GetPos() + Vector(0, 0, maxs.z + 5)
    local ang = Angle(0, 0, 90)
    Draw3DText(pos, ang, 0.2, text, false)
    Draw3DText(pos, ang, 0.2, text, true)
end
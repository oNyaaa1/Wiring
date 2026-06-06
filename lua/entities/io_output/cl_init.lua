include("shared.lua")
function ENT:Initialize()
end

-- Draw some 3D text
local function Draw3DText(pos, ang, scale, text, flipView)
    if flipView then
        -- Flip the angle 180 degrees around the UP axis
        ang:RotateAroundAxis(Vector(0, 0, 1), 180)
    end

    cam.Start3D2D(pos, ang, scale)
    draw.SimpleTextOutlined(text, "Default", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
    cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()
    self:DrawModel(flags)
    local text = "Output"
    local mins, maxs = self:GetModelBounds()
    local pos = self:GetPos() + Vector(0, 0, maxs.z + 2)
    local ang = Angle(0, SysTime() * 100 % 360, 90)
    Draw3DText(pos, ang, 0.2, text, false)
    -- DrawDraw3DTextback
    Draw3DText(pos, ang, 0.2, text, true)
end

function ENT:Think()
end
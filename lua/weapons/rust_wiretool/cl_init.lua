include("shared.lua")
WiringCable = {}
local Laser = Material("cable/redlaser")
hook.Add("PostDrawOpaqueRenderables", "red-cable-laser", function()
    for i = 1, #WiringCable do
        if isvector(WiringCable[1]) and isvector(WiringCable[2]) then
            render.SetMaterial(Laser)
            render.DrawLine(WiringCable[1], WiringCable[2], Color(255, 0, 0))
        end
    end
end)

function SWEP:PrimaryAttack()
    local pl = self:GetOwner()
    if not pl then return end
    local tr = pl:GetEyeTrace()
    WiringCable[#WiringCable + 1] = tr.HitPos
    pl:EmitSound("electrical/wiretool_place.wav")
end
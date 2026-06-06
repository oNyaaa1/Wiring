local beamMat = Material("cable/rope")

hook.Add("PostDrawOpaqueRenderables", "MyBeam", function()
    for i = 1, #WiringCable do
        local p1 = WiringCable[i][1]
        if WiringCable[i + 1] == nil then continue end
        local p2 = WiringCable[i + 1][1]
        if not p1 or not p2 then continue end

        render.SetMaterial(beamMat)
        render.DrawBeam(p1, p2, 2, 0, 1, Color(255, 0, 0, 255))
    end
end)
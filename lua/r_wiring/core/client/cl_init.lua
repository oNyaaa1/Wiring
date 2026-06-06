local beamMat = Material("cable/rope")

-- Table of active connections: { {outNode, inNode}, ... }
WiringConnections = WiringConnections or {}

net.Receive("RWiring_NewConnection", function()
    local outNode = net.ReadEntity()
    local inNode  = net.ReadEntity()
    if IsValid(outNode) and IsValid(inNode) then
        -- Avoid duplicates
        for _, v in ipairs(WiringConnections) do
            if v[1] == outNode and v[2] == inNode then return end
        end
        table.insert(WiringConnections, {outNode, inNode})
    end
end)

net.Receive("RWiring_RemoveConnection", function()
    local outNode = net.ReadEntity()
    local inNode  = net.ReadEntity()
    for i = #WiringConnections, 1, -1 do
        local v = WiringConnections[i]
        if v[1] == outNode or v[2] == inNode or
           not IsValid(v[1]) or not IsValid(v[2]) then
            table.remove(WiringConnections, i)
        end
    end
end)

hook.Add("PostDrawOpaqueRenderables", "RWiring_DrawCables", function()
    -- Purge stale entries
    for i = #WiringConnections, 1, -1 do
        local v = WiringConnections[i]
        if not IsValid(v[1]) or not IsValid(v[2]) then
            table.remove(WiringConnections, i)
        end
    end

    render.SetMaterial(beamMat)
    for _, v in ipairs(WiringConnections) do
        local p1 = v[1]:GetPos()
        local p2 = v[2]:GetPos()
        render.DrawBeam(p1, p2, 2, 0, 1, Color(255, 165, 0, 255))
    end
end)

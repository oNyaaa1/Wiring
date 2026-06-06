IO.Wiring = {
    Inputs = function(ent, pos, name)
        if not SERVER then return end
        if ent.Name ~= name then return end
        local inp = ents.Create("io_input")
        inp:SetPos(pos)
        inp:SetAngles(Angle(0, 0, 0))
        inp:Spawn()
        inp:Activate()
        inp:SetParent(ent)
        inp.Owner = ent
        inp.Inputs = true
        ent.InputNode = inp
        print("[R-Wiring] Created Input node for " .. name)
    end,

    Output = function(ent, pos, name)
        if not SERVER then return end
        if ent.Name ~= name then return end
        local out = ents.Create("io_output")
        out:SetPos(pos)
        out:SetAngles(Angle(0, 0, 0))
        out:Spawn()
        out:Activate()
        out:SetParent(ent)
        out.Owner = ent
        out.Outputs = true
        ent.OutputNode = out
        print("[R-Wiring] Created Output node for " .. name)
    end,

    -- Connect two entities: from ent's OutputNode to target's InputNode
    Connect = function(fromEnt, toEnt)
        if not IsValid(fromEnt) or not IsValid(toEnt) then return false end
        local outNode = fromEnt.OutputNode
        local inNode  = toEnt.InputNode
        if not IsValid(outNode) or not IsValid(inNode) then return false end

        outNode.ConnectedTo = inNode
        inNode.ConnectedFrom = outNode

        -- Sync connection to clients for rendering
        net.Start("RWiring_NewConnection")
            net.WriteEntity(outNode)
            net.WriteEntity(inNode)
        net.Broadcast()

        print("[R-Wiring] Connected " .. tostring(fromEnt) .. " -> " .. tostring(toEnt))
        return true
    end,

    -- Send a signal value through a wired connection
    Signal = function(fromEnt, value)
        if not SERVER then return end
        local outNode = fromEnt.OutputNode
        if not IsValid(outNode) then return end
        local inNode = outNode.ConnectedTo
        if not IsValid(inNode) then return end
        local target = inNode.Owner
        if IsValid(target) and target.OnSignal then
            target:OnSignal(value, fromEnt)
        end
    end
}

if SERVER then
    util.AddNetworkString("RWiring_NewConnection")
    util.AddNetworkString("RWiring_RemoveConnection")
end

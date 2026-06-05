IO.Wiring = {
    Inputs = function(ent, input, name)
        if ent.Name ~= name then return end
        ent.own = ents.Create("oi_input")
        ent.own:SetPos(input)
        ent.own:SetAngles(Angle(0, 0, 0))
        ent.own:Spawn()
        ent.own:Activate()
        ent.own.Outputs = true
    end,
    Output = function(ent, input, name)
        if ent.Name ~= name then return end
        ent.own = ents.Create("oi_output")
        ent.own:SetPos(input)
        ent.own:SetAngles(Angle(0, 0, 0))
        ent.own:Spawn()
        ent.own:Activate()
        ent.own.Inputs = true
    end
}

hook.Add("OnEntityCreated", "IOWiring", function(ent)
    if ent.Wiring then
        --Turret
        IO.Wiring.Inputs(ent, Vector(0, 0, 0), "rust_turret")
    end
end)
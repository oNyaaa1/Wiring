IO.Wiring = {
    Inputs = function(ent, input, name)
        if not SERVER then return end
        print(ent, input, name)
        if ent.Name ~= name then return end
        print("Input")
        ent.own = ents.Create("io_input")
        ent.own:SetPos(input)
        ent.own:SetAngles(Angle(0, 0, 0))
        ent.own:Spawn()
        ent.own:Activate()
        ent.own:SetParent(ent)
        ent.own.Inputs = true
    end,
    Output = function(ent, input, name)
        if not SERVER then return end
        if ent.Name ~= name then return end
        print("Output")
        ent.own = ents.Create("io_output")
        ent.own:SetPos(input)
        ent.own:SetAngles(Angle(0, 0, 0))
        ent.own:Spawn()
        ent.own:Activate()
        constraint.Weld(ent.own, ent, 0, 0, 0, true, true)
        ent.own.Outputs = true
    end
}
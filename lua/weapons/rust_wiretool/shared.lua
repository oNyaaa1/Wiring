SWEP.Base = "weapon_base"
SWEP.PrintName = "Rust Wire Tool"
SWEP.Category = "Rust"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
WiringCable = WiringCable or {}
-- Returns (ownerEntity, "input"|"output") when clicking a proxy node.
-- Returns (nil, "ambiguous") when clicking a machine body directly.
-- Returns (nil, nil) when the entity has no IO nodes at all.
local function ResolveNode(ent)
    if not IsValid(ent) then return nil, nil end
    -- Clicked an output proxy directly
    if ent:GetClass() == "io_output" then
        local owner = IsValid(ent.Owner) and ent.Owner or ent
        if IsValid(owner.OutputNode) then return owner, "output" end
    end

    -- Clicked an input proxy directly
    if ent:GetClass() == "io_input" then
        local owner = IsValid(ent.Owner) and ent.Owner or ent
        if IsValid(owner.InputNode) then return owner, "input" end
    end

    -- Clicked a machine body — has IO but type is ambiguous
    if IsValid(ent.OutputNode) or IsValid(ent.InputNode) then return nil, "ambiguous" end
    return nil, nil
end

local function CancelPending(self)
    self.PendingNode = nil
    self.PendingNodeType = nil
end

function SWEP:PrimaryAttack()
    if not IsValid(self:GetOwner()) then return end
    local pl = self:GetOwner()
    local ent = pl:GetEyeTrace().Entity
    if SERVER then
        local owner, nodeType = ResolveNode(ent)
        if not self.PendingNode then
            -- ── First click ───────────────────────────────────────────────────
            if nodeType == "ambiguous" then
                pl:ChatPrint("[R-Wiring] Click the specific Input or Output node, not the machine body.")
            elseif owner and nodeType then
                self.PendingNode = owner
                self.PendingNodeType = nodeType
                pl:EmitSound("electrical/wiretool_place.wav")
                pl:ChatPrint(string.format("[R-Wiring] %s selected on %s — now click a compatible %s node.", nodeType == "output" and "Output" or "Input", tostring(owner), nodeType == "output" and "Input" or "Output"))
            else
                pl:ChatPrint("[R-Wiring] No IO node found. Click an Input or Output node.")
            end
        else
            -- ── Second click ──────────────────────────────────────────────────
            if nodeType == "ambiguous" then
                pl:ChatPrint("[R-Wiring] Click the specific Input or Output node, not the machine body.")
                -- Preserve pending so the player can retry
                self:SetNextPrimaryFire(CurTime() + 0.3)
                return
            end

            if not owner then
                pl:ChatPrint("[R-Wiring] No IO node found. Connection cancelled.")
                CancelPending(self)
                self:SetNextPrimaryFire(CurTime() + 0.3)
                return
            end

            if owner == self.PendingNode then
                pl:ChatPrint("[R-Wiring] That's the same machine. Click a node on a different entity.")
                self:SetNextPrimaryFire(CurTime() + 0.3)
                return
            end

            if nodeType == self.PendingNodeType then
                pl:ChatPrint(string.format("[R-Wiring] Both are %s nodes. Need one Input and one Output.", nodeType))
                -- Preserve pending so the player can retry
                self:SetNextPrimaryFire(CurTime() + 0.3)
                return
            end

            -- Valid pair — order args correctly for IO.Wiring.Connect(output, input)
            local outputEnt = (self.PendingNodeType == "output") and self.PendingNode or owner
            local inputEnt = (self.PendingNodeType == "input") and self.PendingNode or owner
            if IO.Wiring.Connect(outputEnt, inputEnt) then
                pl:ChatPrint("[R-Wiring] Connected!")
                pl:EmitSound("electrical/wiretool_place.wav")
            else
                pl:ChatPrint("[R-Wiring] Connection failed — check IO nodes.")
            end

            CancelPending(self)
        end
    end

    self:SetNextPrimaryFire(CurTime() + 0.3)
end

function SWEP:SecondaryAttack()
    if SERVER then
        local pl = self:GetOwner()
        if not pl then return end
        local ent = pl:GetEyeTrace().Entity
        if not ent then return end
        net.Start("RWiring_RemoveConnection")
        net.WriteEntity(ent)
        net.WriteEntity(ent.ConnectedTo)
        net.Broadcast()
        net.Start("RWiring_RemoveConnection")
        net.WriteEntity(ent.ConnectedFrom)
        net.WriteEntity(ent)
        net.Broadcast()
        CancelPending(self)
        self:GetOwner():ChatPrint("[R-Wiring] Selection cleared.")
    end

    self:SetNextSecondaryFire(CurTime() + 0.3)
end
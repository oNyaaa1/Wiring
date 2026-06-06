SWEP.Base          = "weapon_base"
SWEP.PrintName     = "Rust Wire Tool"
SWEP.Category      = "Rust"
SWEP.Spawnable     = true
SWEP.AdminSpawnable = false
SWEP.WorldModel    = ""
SWEP.ViewModel     = ""
SWEP.Slot          = 4
SWEP.SlotPos       = 1
SWEP.DrawAmmo      = false
SWEP.DrawCrosshair = false

-- Global cable table always exists, not only after weapon spawn
WiringCable = WiringCable or {}

function SWEP:PrimaryAttack()
    if not self:GetOwner():IsValid() then return end
    local pl = self:GetOwner()
    local tr = pl:GetEyeTrace()
    local ent = tr.Entity

    if SERVER then
        -- First click: store pending node. Second click on a compatible node: connect.
        if not self.PendingNode then
            -- Must click an entity that has an OutputNode
            if IsValid(ent) and IsValid(ent.OutputNode) then
                self.PendingNode = ent
                pl:ChatPrint("[R-Wiring] Output selected: " .. tostring(ent) .. " — now click an entity with an Input node.")
            elseif IsValid(ent) and (ent:GetClass() == "io_output") then
                self.PendingNode = ent.Owner
                pl:ChatPrint("[R-Wiring] Output node selected — now click an entity with an Input node.")
            else
                pl:ChatPrint("[R-Wiring] Click an entity with an Output node first.")
            end
        else
            local toEnt = ent
            if IsValid(ent) and ent:GetClass() == "io_input" then
                toEnt = ent.Owner
            end
            if IsValid(toEnt) and IsValid(toEnt.InputNode) then
                if IO.Wiring.Connect(self.PendingNode, toEnt) then
                    pl:ChatPrint("[R-Wiring] Connected!")
                    pl:EmitSound("electrical/wiretool_place.wav")
                else
                    pl:ChatPrint("[R-Wiring] Connection failed — missing IO nodes.")
                end
            else
                pl:ChatPrint("[R-Wiring] Target has no Input node. Connection cancelled.")
            end
            self.PendingNode = nil
        end
    end

    self:SetNextPrimaryFire(CurTime() + 0.3)
end

function SWEP:SecondaryAttack()
    -- Cancel pending selection
    if SERVER then
        self.PendingNode = nil
        self:GetOwner():ChatPrint("[R-Wiring] Selection cleared.")
    end
    self:SetNextSecondaryFire(CurTime() + 0.3)
end

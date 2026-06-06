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
SWEP.DrawCrosshair = false
WiringCable = {}
function SWEP:PrimaryAttack()
    local pl = self:GetOwner()
    if not pl then return end
    local tr = pl:GetEyeTrace()
    WiringCable[#WiringCable + 1] = {tr.HitPos, tr.Entity}
    pl:EmitSound("electrical/wiretool_place.wav")
end
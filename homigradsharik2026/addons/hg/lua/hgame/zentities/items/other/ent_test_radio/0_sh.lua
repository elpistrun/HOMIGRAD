local ENT = oop.Reg("ent_test_radio",{"base_entity"},true)
if not ENT then return INCLUDE_BREAK end

ENT.PrintName = "Радио"
ENT.Category = L("weapon_category_item")
ENT.Spawnable = true

function ENT:Initialize()
    self:SetModel("models/props/cs_office/radio.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
end

if SERVER then return end

function ENT:Think()
    local snd = self.snd

    if not snd then
        snd = CreateSound(self,"ambient/music/country_rock_am_radio_loop.wav")
        self.snd = snd

        snd:SetSoundLevel(75)
    end

    if not snd:IsPlaying() then snd:Play() end
end

function ENT:OnRemove()
    if self.snd then self.snd:Stop() end
end
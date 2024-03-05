ENT.Type = "anim"
ENT.PrintName = "Imperial Comms Console"
ENT.Author = "Theodor"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/krieg/galacticempire/props/imp_console_6.mdl")
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetHealth(100)
        self:SetNetVar("Health", 100)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end
end

function ENT:OnTakeDamage(damage)
    local currentHealth = self:GetNetVar("Health", 100)
    local newHealth = currentHealth - damage:GetDamage()
    self:SetNetVar("Health", newHealth)
    if newHealth <= 0 and not self.exploded then
        self:OnZeroHealth()
    end
end

function ENT:OnZeroHealth()
    self.exploded = true

    local effectData = EffectData()
    effectData:SetOrigin(self:GetPos())
    util.Effect("Explosion", effectData)

    self:EmitSound("ambient/explosions/explode_4.wav")
    -- Disable communication logic here
end

function ENT:RepairEntity()
    self:SetHealth(100)
    self.exploded = false
end
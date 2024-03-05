ENT.Type = "anim"
ENT.PrintName = "Gravity Generator"
ENT.Author = "Theodor"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/krieg/galacticempire/props/imp_console_1.mdl") -- Adjust the model as necessary
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetHealth(100)
        self:SetNetVar("Health", 100)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
        self:RestoreGravityAndMovement() -- Ensure default settings when spawned
    end
end

function ENT:SetGravityActive(active)
    self:SetNetVar("GravityActive", active)
end

function ENT:GetGravityActive()
    return self:GetNetVar("GravityActive", false)
end

function ENT:ToggleGravity()
    if self:GetGravityActive() then
        self:SetGravityActive(false)
        self:RestoreGravityAndMovement()
    else
        self:SetGravityActive(true)
        self:ApplyLowGravityAndGlide()
    end
end

function ENT:ApplyLowGravityAndGlide()
    if SERVER then
        RunConsoleCommand("sv_gravity", "100") -- Set low gravity
        RunConsoleCommand("sv_airaccelerate", "1000") -- Increase air acceleration for gliding
    end
end

function ENT:RestoreGravityAndMovement()
    if SERVER then
        RunConsoleCommand("sv_gravity", "600") -- Restore normal gravity
        RunConsoleCommand("sv_airaccelerate", "10") -- Restore normal air acceleration
    end
end

function ENT:Use(activator, caller)
    self:ToggleGravity()
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
    self:ApplyLowGravityAndGlide() -- Apply effects when destroyed
end

function ENT:OnRemove()
    self:RestoreGravityAndMovement() -- Reset gravity and movement when removed
end

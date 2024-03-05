ITEM.name = "Advanced Medical Base"
ITEM.description = "An advanced medical item with special bonuses."
ITEM.model = "models/healthvial.mdl"
ITEM.category = "Medical"

-- Base healing parameters
ITEM.baseHealAmount = 10
ITEM.baseHealTime = 3

-- Certification and Attribute related
ITEM.certificationName = "Field Medical Training"
ITEM.attributeName = "intelligence"
ITEM.healAmountPerAttributePoint = 0.5
ITEM.healTimeReductionPerAttributePoint = 0.1 -- 10% per point

-- Function to get the total heal amount considering certification and attribute
function ITEM:GetHealAmount(player)
    local char = player:GetCharacter()
    local certificationBonus = wOS.RenegadeSquad.Certif:HasCertification(player, self.certificationName) and 10 or 0
    local attributeBonus = math.floor(char:GetAttribute(self.attributeName, 0) * self.healAmountPerAttributePoint)
    return self.baseHealAmount + certificationBonus + attributeBonus
end

-- Function to get the total heal time considering certification and attribute
function ITEM:GetHealTime(player)
    local char = player:GetCharacter()
    local attributeReduction = char:GetAttribute(self.attributeName, 0) * self.healTimeReductionPerAttributePoint
    return self.baseHealTime * (1 - attributeReduction)
end

-- Attempt to increase the 'medical' attribute

function ITEM:TryIncreaseMedicalAttribute(player)
    -- Call TryIncreaseAttribute from the Schema table
    -- Ensure 'self.attributeName' is defined in your ITEM table
    Schema:TryIncreaseAttribute(player, "medical", 0, 0.7, 25)
end

-- Heal functionality
ITEM.functions.Heal = {
    name = "Heal",
    OnRun = function(item)
        local player = item.player
        if not IsValid(player) then return false end

        local char = player:GetCharacter()
        if not char then return false end

        if player:Health() >= player:GetMaxHealth() then return false end

        local healAmount = item:GetHealAmount(player)
        local healTime = item:GetHealTime(player)

        local initialPos = player:GetPos() -- Store initial position

        -- Start the timed action
        player:SetAction("Healing...", healTime, function()
            if not IsValid(player) or not player:Alive() then
                return
            end

            -- Check if player has moved
            if player:GetPos() != initialPos then
                player:Notify("Healing failed - movement detected!")
                return
            end

            player:SetHealth(math.Clamp(player:Health() + healAmount, 0, player:GetMaxHealth()))
            ix.chat.Send(player, "iteminternal", "uses an " .. item.name .. " on themselves.", false)

            if item.OnHeal then
                item:OnHeal(player)
            end

            item:TryIncreaseMedicalAttribute(player)
        end)

        return true
    end,
    OnCanRun = function(item)
        local player = item.player
        return IsValid(player) and player:Health() < player:GetMaxHealth()
    end
}

ITEM.functions.HealTarget = {
    name = "Heal Target",
    OnRun = function(item)
        local player = item.player
        if not IsValid(player) then return false end

        local char = player:GetCharacter()
        if not char then return false end

        local trace = player:GetEyeTrace()
        local target = trace.Entity

        if not (IsValid(target) and target:IsPlayer() and target:Health() < target:GetMaxHealth()) then
            return false
        end

        local healAmount = item:GetHealAmount(player)
        local healTime = item:GetHealTime(player)

        local initialPos = player:GetPos() -- Store initial position

        -- Start the timed action
        player:SetAction("Healing Target...", healTime, function()
            if not IsValid(player) or not IsValid(target) or not target:Alive() then
                return
            end

            -- Check if player has moved
            if player:GetPos() != initialPos then
                player:Notify("Healing failed - movement detected!")
                return
            end

            target:SetHealth(math.Clamp(target:Health() + healAmount, 0, target:GetMaxHealth()))
            ix.chat.Send(player, "iteminternal", "uses an " .. item.name .. " on " .. target:Name(), false)

            if item.OnHeal then
                item:OnHeal(target)
            end

            item:TryIncreaseMedicalAttribute(player)
        end)
        return true
    end,
    OnCanRun = function(item)
        local player = item.player
        if not IsValid(player) then return false end

        local trace = player:GetEyeTrace()
        local target = trace.Entity

        return IsValid(target) and target:IsPlayer() and target:Health() < target:GetMaxHealth()
    end
}

-- Optional: Custom behavior when healing
function ITEM:OnHeal(player)
    if SERVER then
        player:EmitSound("items/medshot4.wav")
    end
end

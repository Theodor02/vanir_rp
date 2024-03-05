ITEM.name = "Bacta Infusion Concentrate Vial"
ITEM.description = "This vial holds a highly concentrated dose of bacta. Ideal for swift treatment of moderate injuries, the concentrate accelerates tissue repair and provides rapid relief from pain and inflammation."
ITEM.model = "models/krieg/galacticempire/props/bacta_cylinder.mdl"  -- Update this to the model you want for the medkit
ITEM.category = "Medical"
ITEM.width = 1
ITEM.height = 2

-- If you want to override the base healing parameters for this specific item
ITEM.baseHealAmount = 55  -- The amount of health this medkit heals
ITEM.baseHealTime = 8     -- The time it takes to apply this medkit

-- Optionally, override specific methods if this item has special behavior
function ITEM:GetHealAmount(player)
    -- You can add specific logic here if needed
    return self.baseHealAmount
end

function ITEM:GetHealTime(player)
    -- You can add specific logic here if needed
    return self.baseHealTime
end

function ITEM:OnHeal(player)
    -- Custom behavior when healing, such as playing a unique sound
    if SERVER then
        player:EmitSound("items/medshot4.wav")  -- Update this to the sound you want
    end
end

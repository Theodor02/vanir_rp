ITEM.name = "Automated Suture Kit"
ITEM.description = "A portable device containing pre-threaded surgical needles for rapid wound closure. It's designed for ease of use in the field, enabling soldiers to administer basic stitches to combat lacerations."
ITEM.model = "models/krieg/galacticempire/props/bacta_bandage.mdl"  -- Update this to the model you want for the medkit
ITEM.category = "Medical"
ITEM.width = 2
ITEM.height = 1

-- If you want to override the base healing parameters for this specific item
ITEM.baseHealAmount = 25  -- The amount of health this medkit heals
ITEM.baseHealTime = 3     -- The time it takes to apply this medkit

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

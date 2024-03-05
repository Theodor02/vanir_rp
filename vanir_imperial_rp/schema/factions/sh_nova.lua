FACTION.name = "Imperial Nova Trooper"
FACTION.description = "The Imperial Nova Trooper is a special forces unit of the Galactic Empire's Stormtrooper Corps, distinguished by its use of ARC trooper armor painted with a distinctive patterns."
FACTION.isDefault = false
FACTION.color = Color(45, 24, 47)
FACTION.prefix = "NVT "
FACTION.pay = 25

-- You should define a global variable for this faction's index for easy access wherever you need. FACTION.index is
-- automatically set, so you can simply assign the value.

-- Note that the player's team will also have the same value as their current character's faction index. This means you can use
-- client:Team() == FACTION_CITIZEN to compare the faction of the player's current character.
FACTION_NOVA = FACTION.index

FACTION.models = {

    "models/jajoff/sps/jlmbase/empire/nova/recruit.mdl"
}
local faction_prefix = "NT - "

function FACTION:GetDefaultName(client)
    return faction_prefix .. math.random(1000, 9999), true
end

function FACTION:OnCharacterCreated(client, character)
    local name = character:GetName()

    -- Extract a four-digit number from the name
    -- Pattern looks for a sequence of exactly four digits
    local numberPart = name:match("(%d%d%d%d)")

    if numberPart then
        -- Store the extracted number in the character's data
        character:SetData("uniqueNumber", tonumber(numberPart))
    end
end

function FACTION:OnTransferred(character)
    -- Set the model for the new faction
    character:SetModel(self.models[1])

    -- Get the character's current name
    local name = character:GetName()

    -- Define the old prefix and the new prefix
    local oldPrefixPattern = "^%a%a% - "  -- Pattern to match "XXX - " where X is any alphabet letter
    local newPrefix = faction_prefix  -- Replace with the new prefix for this faction

    -- Remove the old prefix if it exists
    local updatedName = name:gsub(oldPrefixPattern, "")

    -- Apply the new prefix
    updatedName = newPrefix .. updatedName

    -- Update the character's name
    character:SetName(updatedName)
end
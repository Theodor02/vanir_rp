ITEM.name = "Force Sensitive Item"
ITEM.description = "A mysterious item that reacts to one's connection with the Force."
ITEM.model = "models/props_c17/FurnitureWashingmachine001a.mdl"  -- Replace with the model path
ITEM.category = "Holocrons"
ITEM.forceLearn = 20
ITEM.forceChance = 1
ITEM.forceAbility = "Default"
ITEM.descriptionCanLearn = "This item pulses with a mysterious energy. You feel that you can learn something from it."
ITEM.descriptionInert = "This item is inert. It does not react to your touch."

-- Rest of your base ITEM code...
function ITEM:AddCharData(client,data)
    local ply = client:GetPlayer()
    if ply:GetCharacter() then
        Schema:AddForcePower(ply, data)
    end
end

function ITEM:GetDescription(player)
    local description = ""
    local localplayer = player or LocalPlayer()
    local char = localplayer:GetCharacter()
    local forceLevel = char:GetAttribute("theforce", 0)

    local hasPowerAlready = false
    local forcePowers = char:GetData("forcepowers", {})
    for _, power in ipairs(forcePowers) do
        if power == self.forceAbility then
            hasPowerAlready = true
            break
        end
    end

    if self:GetData("inertstate", false) == true then
        description = self.descriptionInert
    elseif forceLevel > self.forceLearn and not hasPowerAlready then
        description = self.descriptionCanLearn
    else
        description = self.description
    end

    return description
end

-- Rest of your ITEM code...


ITEM.functions.Touch = {
    name = "Touch",
    OnRun = function(item)
        --print("Touching item")
        local client = item.player
        if IsValid(client) and item:GetData("inertstate", false) == false then
            local char = client:GetCharacter()
            local forceLevel = char:GetAttribute("theforce", 0)
            local wislevel = char:GetAttribute("wisdom", 0)
            -- Check if the player's force level is greater than 1
            if forceLevel > 1 then
                -- Grant force points directly
                char:UpdateAttrib("theforce", math.random(1,5))
            else
                -- Use the existing chance mechanism
                if math.random(1, 100) <= item.forceChance + math.ceil(wislevel / 100) then
                    char:UpdateAttrib("theforce", 1)
                end
            end
            local newForceWhispers = {
                "A shadowy intuition weaves into your mind, whispering secrets:",
                "An ominous premonition creeps into your awareness, foretelling power:",
                "A chilling revelation pierces through the veil, offering forbidden knowledge:",
                "An obscure epiphany emerges from the depths, shrouded in mystery:",
                "A spectral insight haunts your thoughts, echoing with ancient wisdom:",
                "A daunting awareness infiltrates your mind, heavy with portent:",
                "A peculiar enlightenment envelops you, steeped in enigma:",
                "An unsettling understanding dawns, laden with hidden truths:",
                "A cryptic foresight unfolds, whispering of untold power:",
                "An eerie wisdom infiltrates your senses, its origins unknown:",
                "A sinister vision presents itself, promising untapped might:",
                "A disconcerting knowledge seeps in, wrapped in otherworldly aura:",
                "A ghastly notion invades your consciousness, hinting at dark capabilities:",
                "A bizarre cognition emerges, intertwining reality with the arcane:",
                "An otherworldly insight takes hold, chilling and profound:",
                "A perplexing realization asserts itself, born from the shadows:",
                "An uncanny understanding strikes, resonant with ancient energy:",
                "A mystical concept grips your soul, laden with unsettling implications:",
                "An enigmatic revelation descends, merging fate with will:",
                "A surreal cognition invades, melding past, present, and future:"
            }
            local randomMessage = table.Random(newForceWhispers)
            item.player:Notify(randomMessage)
            --print("Touched item")
            ix.chat.Send(client, "iteminternal", "touches the " .. item.name .. ".", false)
            item:SetData("inertstate", true)
        end
        return false
    end,
    OnCanRun = function(item)
        return !IsValid(item.entity) and item:GetData("inertstate", false) == false
    end

}

ITEM.functions.Learn = {
    name = "Learn",
    OnRun = function(item)
        --print("Learning item")
        local char = item.player:GetCharacter()
        if not char then return false end
    
        local currentPowers = char:GetData("forcepowers", {})
        local newPower = item.forceAbility
    
        -- Check if the new power is already learned
        if not table.HasValue(currentPowers, newPower) then
            table.insert(currentPowers, newPower)
            char:SetData("forcepowers", currentPowers)
            item:SetData("inertstate", true)
        end
        local newForceWhispers = {
            "A shadowy intuition weaves into your mind, whispering secrets:",
            "An ominous premonition creeps into your awareness, foretelling power:",
            "A chilling revelation pierces through the veil, offering forbidden knowledge:",
            "An obscure epiphany emerges from the depths, shrouded in mystery:",
            "A spectral insight haunts your thoughts, echoing with ancient wisdom:",
            "A daunting awareness infiltrates your mind, heavy with portent:",
            "A peculiar enlightenment envelops you, steeped in enigma:",
            "An unsettling understanding dawns, laden with hidden truths:",
            "A cryptic foresight unfolds, whispering of untold power:",
            "An eerie wisdom infiltrates your senses, its origins unknown:",
            "A sinister vision presents itself, promising untapped might:",
            "A disconcerting knowledge seeps in, wrapped in otherworldly aura:",
            "A ghastly notion invades your consciousness, hinting at dark capabilities:",
            "A bizarre cognition emerges, intertwining reality with the arcane:",
            "An otherworldly insight takes hold, chilling and profound:",
            "A perplexing realization asserts itself, born from the shadows:",
            "An uncanny understanding strikes, resonant with ancient energy:",
            "A mystical concept grips your soul, laden with unsettling implications:",
            "An enigmatic revelation descends, merging fate with will:",
            "A surreal cognition invades, melding past, present, and future:"
        }
        local randomMessage = table.Random(newForceWhispers)
        item.player:Notify(randomMessage)
        -- Send the eldritch message to the player who interacted with the item
        return false
    end,
    OnCanRun = function(item)
        local ply = item.player
        local char = ply:GetCharacter()
        if not char then return false end
        local forceLevel = char:GetAttribute("theforce", 0)
        local hasPowerAlready = false
        local forcePowers = char:GetData("forcepowers", {})
        for _, power in ipairs(forcePowers) do
            if power == item.forceAbility then
                hasPowerAlready = true
                break
            end
        end
        return not IsValid(item.entity) and not item:GetData("inertstate", false) and item.forceLearn < forceLevel and not hasPowerAlready
    end
}
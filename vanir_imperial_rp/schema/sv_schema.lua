
-- Here is where all of your serverside functions should go.

-- Example server function that will slap the given player.


-- Function to attempt to increase an attribute with a chance
-- @param client The player whose attribute will be potentially increased
-- @param attributeName The name of the attribute to increase
-- @param minValue The minimum value to increase the attribute by
-- @param maxValue The maximum value to increase the attribute by
-- @param chancePercentage The chance (0-100) that the attribute will be increased
function Schema:TryIncreaseAttribute(client, attribName, minValue, maxValue, chance)
    if not IsValid(client) or not client:GetCharacter() then return end

    local character = client:GetCharacter()
    local currentAttribValue = character:GetAttribute(attribName, 0)

    -- Ensure the attribute value is within the specified range
    if currentAttribValue < maxValue and math.random(100) <= chance then
        -- Determine the increment amount, ensuring it does not exceed maxValue
        local incrementAmount = math.random(minValue, maxValue)
        local finalValue = math.min(currentAttribValue + incrementAmount, maxValue)

        -- Update the attribute, ensuring not to exceed the maximum value
        local increaseAmount = finalValue - currentAttribValue
        character:UpdateAttrib(attribName, increaseAmount)
    end
end

local rankSystem = {
    ["Army"] = {
        enlisted = {
            { rank = "Private", short = "PVT", number = "E1" },
            { rank = "Private First Class", short = "PFC", number = "E2" },
            { rank = "Lance Corporal", short = "LCPL", number = "E3" },
            { rank = "Corporal", short = "CPL", number = "E4" },
            { rank = "Specialist", short = "SPC", number = "E5" },
        },
        nco = {
            { rank = "Sergeant", short = "SGT", number = "N1" },
            { rank = "Staff Sergeant", short = "SSG", number = "N2" },
            { rank = "Sergeant First Class", short = "SFC", number = "N3" },
            { rank = "Master Sergeant", short = "MSG", number = "N4" },
            { rank = "First Sergeant", short = "1SG", number = "N5" },
        },
        co = {
            { rank = "Second Lieutenant", short = "2LT", number = "O1" },
            { rank = "First Lieutenant", short = "1LT", number = "O2" },
            { rank = "Captain", short = "CPT", number = "O3" },
        },
        staff = {
            { rank = "Major", short = "MAJ", number = "O4" },
            { rank = "Lieutenant Colonel", short = "LTC", number = "O5" },
        },
        high_command = {
            { rank = "Colonel", short = "COL", number = "O6" },
            { rank = "Brigadier General", short = "BG", number = "O7" },
            { rank = "General", short = "G", number = "O8" },
        },
    },
    ["Navy"] = {
        enlisted = {
            { rank = "Junior Crewman", short = "JCR", number = "E1" },
            { rank = "Crewman", short = "CRM", number = "E2" },
            { rank = "Able Crewman", short = "ACR", number = "E3" },
            { rank = "Leading Crewman", short = "LCR", number = "E4" },
            { rank = "Petty Officer", short = "PO", number = "E5" },
        },
        nco = {
            { rank = "Chief", short = "CHF", number = "N1" },
            { rank = "Master Chief", short = "MCH", number = "N2" },
            { rank = "Officer Cadet", short = "OCDT", number = "N3" },
            { rank = "Midshipman", short = "MID", number = "N4" },
            { rank = "Ensign", short = "ENS", number = "N5" },
        },
        co = {
            { rank = "Acting Sub-Lieutenant", short = "ASL", number = "O1" },
            { rank = "Sub-Lieutenant", short = "SLT", number = "O2" },
            { rank = "Lieutenant", short = "LT", number = "O3" },
        },
        staff = {
            { rank = "Commander", short = "CMDR", number = "O4" },
            { rank = "Captain", short = "CAPT", number = "O5" },
        },
        high_command = {
            { rank = "Commodore", short = "CDRE", number = "O6" },
            { rank = "Vice Admiral", short = "VADM", number = "O7" },
            { rank = "Admiral", short = "ADM", number = "O8" },
        },
    },
    ["Logistics"] = {
        enlisted = {
            { rank = "Agent Recruit", short = "AR", number = "E1" },
            { rank = "Support Agent", short = "SA", number = "E2" },
            { rank = "Lead Operative", short = "LO", number = "E3" },
            { rank = "Elite Operative", short = "EO", number = "E4" },
            { rank = "Advanced Elite Operative", short = "AEO", number = "E5" },
        },
        nco = {
            { rank = "Section Leader", short = "SL", number = "N1" },
            { rank = "Section Chief", short = "SC", number = "N2" },
            { rank = "Operations Specialist", short = "OS", number = "N3" },
            { rank = "Senior Specialist", short = "SS", number = "N4" },
            { rank = "Field Controller", short = "FC", number = "N5" },
        },
        co = {
            { rank = "Junior Officer", short = "JO", number = "O1" },
            { rank = "Command Officer", short = "CO", number = "O2" },
            { rank = "Executive Officer", short = "XO", number = "O3" },
        },
        staff = {
            { rank = "Resource Manager", short = "RM", number = "O4" },
            { rank = "Senior Resource Manager", short = "SRM", number = "O5" },
        },
        high_command = {
            { rank = "Logistics Commander", short = "LC", number = "O6" },
            { rank = "Senior Logistics Commander", short = "SLC", number = "O7" },
            { rank = "Chief of Logistics", short = "COL", number = "O8" },
        },
    },
    -- Additional branches if needed
}

-- Inside sv_schema.lua
function Schema:TranslateRankByNumber(rankNumber, factionIdentifier)
    -- Assuming `rankSystem` is accessible and contains rank info for all factions
    for _, branchRanks in pairs(rankSystem) do
        for _, categoryRanks in pairs(branchRanks) do
            for _, rankInfo in ipairs(categoryRanks) do
                if rankInfo.number == rankNumber then
                    -- Found a matching rank by number
                    return rankInfo  -- Return the first match found
                end
            end
        end
    end
    return nil  -- Return nil if no matching rank is found
end


function Schema:CustomFactionTransfer(character, newFactionIdentifier)
    -- Retrieve the new faction table using the identifier
    local newFaction = ix.faction.indices[newFactionIdentifier]
    if not newFaction then
        ErrorNoHalt("Faction transfer failed: Invalid faction identifier '" .. tostring(newFactionIdentifier) .. "'.\n")
        return
    end

    -- Check if the character is already in the target faction
    if character:GetFaction() == newFaction.index then
        return  -- No need to change anything if they're already in the target faction
    end
    character:GetPlayer():Spawn()

    local player = character:GetPlayer()
    if not IsValid(player) then return end

    -- Reset bodygroups before changing the model
    self:ResetCharBodygroups(player)

    -- Update the faction and model
    character:SetFaction(newFaction.index)
    character:SetModel(newFaction.models[1])


    -- Retrieve the unique number from the character's data
    local uniqueNumber = character:GetData("uniqueNumber", "0000")  -- Default to "0000" if not found

    -- Construct the new name with the new faction's prefix, a dash, and the unique number
    local newPrefix = newFaction.prefix or ""
    local updatedName = newPrefix .. " - " .. uniqueNumber
    character:SetName(updatedName)
    character:SetData("helmetOn", true)
    

    -- Update characters helmetstate

    -- Faction specific rank adjustments
    local currentRank = character:GetData("rank")
    local currentRankNumber = character:GetData("rankNumber")
    
    -- Handling cadets and non-cadets
    if currentRank == "Cadet" or currentRank == "CDT" then
        -- Directly assign E1 rank for cadets
        if newFaction.index == FACTION_STORMTROOPER then
            character:SetData("rank", "Private")
            character:SetData("rankShort", "PVT")
            character:SetData("rankNumber", "E1")
        elseif newFaction.index == FACTION_NAVY then
            character:SetData("rank", "Junior Crewman")
            character:SetData("rankShort", "JCR")
            character:SetData("rankNumber", "E1")
        elseif newFaction.index == FACTION_LOGISTICS then
            character:SetData("rank", "Agent Recruit")
            character:SetData("rankShort", "AR")
            character:SetData("rankNumber", "E1")
        end
    else
        -- For non-cadets, translate the rank based on the rank number
        local newRank = self:TranslateRankByNumber(currentRankNumber, newFaction.index)
        if newRank then
            character:SetData("rank", newRank.rank)
            character:SetData("rankShort", newRank.short)
            character:SetData("rankNumber", newRank.number)
        end
    end
end
timer.Simple(0.5, function()
    local client = character:GetPlayer()
    local rank = character:GetData("rank", "Unknown")
    local rankNumber = character:GetData("rankNumber", "N/A")

    net.Start("UpdatePlayerRank")
        net.WriteEntity(client)
        net.WriteString(rank)
        net.WriteString(rankNumber)
    net.Broadcast()
end)


-- Reset character's bodygroups to default (usually 0)
function Schema:ResetCharBodygroups(player)
    if not IsValid(player) then return end

    local char = player:GetCharacter()
    if not char then return end

    local model = player:GetModel()
    local bodygroups = player:GetBodyGroups()

    local groupsData = {}
    for _, group in ipairs(bodygroups) do
        groupsData[group.id] = 0
        player:SetBodygroup(group.id, 0)
    end

    char:SetData("groups", groupsData)
end


function Schema:ZeroNumber(number, length)
    local amount = math.max(0, length - string.len(number))
    return string.rep("0", amount) .. tostring(number)
end


function Schema:AddForcePower(char, power)
    local validForcePowers = {
        "item_force_jump",
        "item_force_heal",
        "item_force_immunity",
        "item_force_pull",
        "item_force_push",
        "item_force_replenish",
        "item_force_sense",
        "item_force_throw",
        "item_force_lightning"
    }
    if not char or not char:IsValid() then return end
    -- Assuming validForcePowers is a list of valid force powers defined in your schema
    if table.HasValue(validForcePowers, power) then
        local currentPowers = char:GetData("forcepowers", "")
        char:SetData("forcepowers", currentPowers .. (currentPowers != "" and ", " or "") .. power)
    end
end


function Schema:SetCharBodygroup(ply, index, value)
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    index = index or 1
    value = value or 1

    local groupsData = char:GetData("groups", {})
    groupsData[index] = value

    char:SetData("groups", groupsData)
    ply:SetBodygroup(index, value)
end

-- Functions for bodygroup handling, mostly.

function Schema:HandlePlayerChoice(client, choice, id)
    if not IsValid(client) or not client:GetCharacter() then return end
    local defaultPlayerChoices = defaultPlayerChoices or {
        -- Define default values for each choice
        [1] = "Bald",
        [2] = "Clean",
        [3] = "Black",
        [4] = "Human"
    }
    local character = client:GetCharacter()
    playerChoices[client] = playerChoices[client] or table.Copy(defaultPlayerChoices)
    playerChoices[client][id] = choice
end


-- function to apply player colour to a player. 
function Schema:ApplyHairColor(client, colorChoice) 
    local colorVector = hairColorMapping[colorChoice]
    if colorVector then
        client:SetPlayerColor(colorVector)
    else
        print("Invalid hair color choice:", colorChoice)
    end
end

-- Function to get the bodygroup ID for a given known option 
function Schema:GetBodygroupIDForKnownOption(player, knownOption)
    local bodygroups = player:GetBodyGroups()
    local knownSubmodelFilename = customizationToSubmodel[knownOption]
    for _, bodygroup in ipairs(bodygroups) do
        for _, submodelFilename in ipairs(bodygroup.submodels) do
            if submodelFilename == knownSubmodelFilename then
                return bodygroup.id
            end
        end
    end
end


-- function to get the subgroup index for a given customization option. returns nil if the option is not found.
-- Blame the absolute crazy randomised subgroups for the modelpack that we are using. This is bad. I hate it.
function Schema:GetSubgroupIndex(player, customizationOption)
    local bodygroups = player:GetBodyGroups()
    for _, bodygroup in ipairs(bodygroups) do
        for submodelIndex, submodelFilename in ipairs(bodygroup.submodels) do
            if submodelFilename == customizationToSubmodel[customizationOption] then
                return bodygroup.id, submodelIndex
            end
        end
    end

    if customizationOption == "Bald" then
        return self:GetBodygroupIDForKnownOption(player, "Side"), 0
    elseif customizationOption == "Clean" then
        return self:GetBodygroupIDForKnownOption(player, "Beard"), 0
    end

    return nil, nil
end



-- function to apply chosen bodygroups to a player. takes the client and the bodygroup choices as arguments. Choices being an table of bodygroup names.
function Schema:ApplyBodygroupChoices(client, choices)
    if not choices then
        print("No choices provided for bodygroup application.")
        return
    end

    for _, choiceName in pairs(choices) do
        if hairColorMapping[choiceName] then
            self:ApplyHairColor(client, choiceName)
        else
            local bodygroupID, submodelIndex = self:GetSubgroupIndex(client, choiceName)
            if bodygroupID and submodelIndex then
                client:SetBodygroup(bodygroupID, submodelIndex)
                self:SetCharBodygroup(client, bodygroupID, submodelIndex)
            end
        end
    end
end


util.AddNetworkString("ix.Schema.OpenUI")
function Schema:OpenUI(ply, panel)
    net.Start("ix.Schema.OpenUI")
    net.WriteString(panel)
    net.Send(ply)
end

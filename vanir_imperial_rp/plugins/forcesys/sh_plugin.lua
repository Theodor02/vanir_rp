-- Server-side code
PLUGIN.name = "The Force"
PLUGIN.author = "Theodor"
PLUGIN.description = "Manages effects based on the Force Sensitivity attribute."


if SERVER then
    local timertime = 500
    local forceStatmult = 1.5


    hook.Add( "LSCS:OnPlayerDroppedItem", "itemremover", function( ply, item_entity )

        item_entity:Remove() -- lets just remove it in this example
    end ) 

    -- player attrib check. This shouldn't be here, but it is. deal with it.
    util.AddNetworkString("ForceSensitivityMessage")
    ix.config.Add("meditateDuration", 60, {
        category = "The Force",
        description = "Duration (in seconds) of the meditation action.",
        data = {min = 1, max = 300, decimals = 0},
        type = ix.type.number
    })
    
    ix.config.Add("meditateCooldown", 300, {
        category = "The Force",
        description = "Cooldown (in seconds) before meditation can be performed again.",
        data = {min = 1, max = 3600, decimals = 0},
        type = ix.type.number
    })

    -- Configuration for messages and corresponding levels
    local forceSensitivityMessages = {
        [1] = {
            "A distant whisper echoes, hinting at an uncharted path.",
            "You feel an inexplicable pull, like a gentle nudge in the back of your mind.",
            "Shadows seem to dance at the edge of your vision, as if hiding secrets.",
            "A fleeting sensation of being watched, quickly dismissed as imagination.",
            "An occasional chill brushes past you, carrying faint, indistinct murmurs.",
            "Your dreams occasionally feel strangely vivid, leaving lingering questions upon waking."
        },
        [5] = {
            "Murmurs grow slightly clearer, as if revealing hidden truths.",
            "Shadows around you appear to linger a moment longer, filled with silent curiosity.",
            "You feel an unexplained yearning, a quiet urge guiding you towards something unseen.",
            "Your dreams are occasionally filled with odd, cryptic symbols.",
            "A sense of untapped potential flickers within you, elusive yet persistent.",
            "Now and then, you catch fleeting glimpses of movement, gone when you turn."
        },
        [10] = {
            "Whispers become more frequent, echoing faintly of secrets and hidden power.",
            "Shadows seem to watch, waiting, as if they hold a deeper meaning.",
            "A growing urge within you seeks understanding, drawing you to the unknown.",
            "Visions in your dreams begin to take shape, hinting at a greater mystery.",
            "You sense a dormant strength within, like a buried well waiting to be tapped.",
            "Sometimes, the corner of your eye catches enigmatic figures that vanish when seen directly."
        },
        [20] = {
            "The whispers now speak in clearer tones, suggesting a path less traveled.",
            "Shadows bend and whisper, as if conversing in a forgotten language.",
            "The urge within you becomes a guiding force, leading you towards the unexplored.",
            "Your dreams are rich with symbols and messages, beckoning you deeper.",
            "An unclaimed power within you stirs restlessly, seeking release.",
            "Glimpses of enigmatic figures become more common, almost familiar yet still elusive."
        },
            [30] = {
                "A sensation of unseen eyes upon you grows more frequent, unsettling your peace.",
                "Echoes of distant, indecipherable whispers seem to call out to you in solitude.",
                "You begin to notice shadows shifting subtly when unobserved, as if concealing something.",
                "A growing sense of unease permeates your dreams, leaving you questioning their meaning.",
                "Inexplicable moments of intuition lead you to strange coincidences.",
                "Occasional, unexplained cold drafts accompany thoughts of unknown origin."
            },
            [40] = {
                "Whispers now carry a chilling undertone, urging you towards unknown deeds.",
                "You feel a compelling gaze that guides you to act in unsettling ways.",
                "The shadows around you occasionally pulsate with a life of their own.",
                "Your dreams are invaded by entities speaking in tongues of old, making sinister propositions.",
                "An inner voice starts to challenge your morals, suggesting manipulative actions.",
                "You experience fleeting moments of euphoria followed by deep, inexplicable despair."
            },
            [50] = {
                "The whispers grow more insistent, painting visions of power and dominion.",
                "You feel an overwhelming urge to exert your will over others, driven by an unseen force.",
                "Shadows seem to reach out to you, whispering dark secrets and forbidden knowledge.",
                "Entities in your dreams now demand obedience, promising power in return.",
                "Moments of lost time begin to occur, leaving you with unsettling realizations.",
                "The line between your thoughts and an external will becomes increasingly blurred."
            },
            [60] = {
                "Voices of the Force scream of ultimate power and the sacrifices required to attain it.",
                "You start to perceive others as mere tools, influenced by the dark whispers.",
                "Shadows around you are now constant companions, murmuring unsettling truths.",
                "Dreams turn into negotiations with entities that seek to use you as their vessel.",
                "Your sense of self wanes under the weight of the Force's omnipresent voice.",
                "You are haunted by visions of grandeur built upon actions of cruelty and malice."
            },
            [70] = {
                "The Force's whispers are now a deafening roar, commanding unspeakable acts.",
                "Shadows around you are alive, twisting into forms that both entice and horrify.",
                "Your dreams are no longer your own, but windows into a realm of dark desires.",
                "An unrelenting presence within you orchestrates your actions like a puppeteer.",
                "Reality begins to warp at the edges, bending to the whims of the voices.",
                "Your perception of others is clouded by a malevolent force, seeing them as expendable pawns."
            },
            [80] = {
                "You are engulfed in the Force's dark embrace, losing all sense of self.",
                "Shadows speak clearly now, dictating a path laden with power and dread.",
                "Entities of the dark realm visit you openly, their demands growing more extreme.",
                "The boundary between waking and dreaming dissolves, leaving you in constant turmoil.",
                "A sinister will dominates your thoughts, its intent overwhelmingly oppressive.",
                "Visions of apocalyptic power consume you, driving you to the brink of madness."
            },
            [90] = {
                "The whispers have become an omnipresent command, echoing the dark side's will.",
                "Your existence is a dance on the strings of shadowy figures, orchestrating chaos.",
                "Nightmarish visions become your reality, each more terrifying than the last.",
                "An inexorable force compels you towards actions of devastating consequence.",
                "Your consciousness fragments under the weight of the Force's dark seduction.",
                "You are a conduit for destruction, an agent of a power beyond comprehension."
            },
            [100] = {
                "You are the Force's instrument, imbued with immense power and an insatiable hunger.",
                "Shadows and whispers are now your kin, guiding you in a dance of cosmic horror.",
                "Your dreams have ceased, replaced by a constant stream of dark prophecies.",
                "Every thought is an echo of the dark side's will, shaping reality to its whims.",
                "You see the world through a veil of darkness, where every soul is a plaything of the Force.",
                "You stand at the precipice of ultimate power, teetering between godhood and utter madness."
        }
        }
            -- Additional messages for higher levels continue in this theme...
    local function sendForceMessage(ply, message)
        net.Start("ForceSensitivityMessage")
        net.WriteString(message)
        net.Send(ply)
        --print("Sent message to " .. ply:Nick() .. ": " .. message)  -- Debug print
    end

    local function checkForceSensitivity(ply)
        local char = ply:GetCharacter()
        if not char then
            --print("Character not found for player: " .. ply:Nick())
            return
        end
        local forceLevel = char:GetAttribute("theforce", 0)
        --print("Checking Force Sensitivity for " .. ply:Nick() .. ": " .. forceLevel)
        for level = 100, 1, -1 do  -- Iterate from highest to lowest level
            if forceSensitivityMessages[level] and forceLevel >= level then
                local messages = forceSensitivityMessages[level]
                local message = messages[math.random(#messages)]
                local randomness = math.random(1, 100)
                if randomness <= 10 then
                    sendForceMessage(ply, message)
                end
                break  -- Break after sending one message
            end
        end
    end
    local function periodicCheck()
        --print("Running periodic check for Force Sensitivity messages")  -- Debug print
        for _, ply in ipairs(player.GetAll()) do
            checkForceSensitivity(ply)
        end
    end

    timer.Create("ForceSensitivityMessageTimer", timertime, 0, periodicCheck)

    -- Configuration for force powers
    local forcepowers = {
        [15] = {
            "item_force_sense"
        },
        [30] = {
            "item_force_push"
        },
        [40] = {
            "item_force_pull"
        },
        [50] = {
            "item_force_jump"
        },

        -- Add other force powers here with their required levels
    }
    local validForcePowers = {
        "item_force_jump",
        "item_force_heal",
        "item_force_immunity", 
        "item_force_pull",
        "item_force_push",
        "item_force_replenish",
        "item_force_sense",
        "item_force_lightning",
        "item_force_heal",
        "item_force_immunity",
        "item_force_replenish",
        "item_stance_aggresive",
        "item_stance_agile",
        "item_stance_arrogant",
        "item_stance_butterfly",
        "item_stance_defensive",
        "item_stance_saberstaff",
        "item_stance_saberstaffdual",
        "item_stance_dualwield",


    }
    function PLUGIN:CheckForcePowers(ply)
        local char = ply:GetCharacter()
        if not char then return end

        local forceLevel = char:GetAttribute("theforce", 0)
        ply:lscsWipeInventory(false)

        -- Table to keep track of added powers
        local addedPowers = {}

        -- Add force powers based on the character's force level
        for level, powers in pairs(forcepowers) do
            if forceLevel >= level then
                for _, power in ipairs(powers) do
                    if table.HasValue(validForcePowers, power) and not addedPowers[power] then
                        ply:lscsAddInventory(power, true)
                        addedPowers[power] = true
                    end
                end
            end
        end
        -- Check the character data for any stored force powers and add them if not already added
        local forcePowers = char:GetData("forcepowers", {})
        for _, power in ipairs(forcePowers) do
            if table.HasValue(validForcePowers, power) and not addedPowers[power] then
                ply:lscsAddInventory(power, true)
                addedPowers[power] = true
            end
        end
    end


    function PLUGIN:SetMaxForcePointsBasedOnSensitivity(ply)
        local char = ply:GetCharacter()
        if not char then return end

        local forceLevel = char:GetAttribute("theforce", 0)
        local maxForcePoints = math.floor(forceLevel * forceStatmult)  -- Change this to balance
        ply:lscsSetMaxForce(maxForcePoints)
    end

    function PLUGIN:PlayerSpawn(ply)
        self:SetMaxForcePointsBasedOnSensitivity(ply)
        self:CheckForcePowers(ply)
        --print("Attempting to add set force points on spawn")
    end
end
if SERVER then
    util.AddNetworkString("ForceLearnMessage")
    net.Start("ForceLearnMessage")
    net.Send(client) -- where 'client' is the player object
end

ix.chat.Register("eldritch", {
    format = "%s",
    color = Color(96, 29, 29), -- Dark red color for the eldritch theme
    CanHear = ix.config.Get("chatRange", 280), -- Define the range; might be irrelevant if it's not broadcasted
    description = "Eldritch Messages",
    deadCanChat = true, -- Optional, depending on whether you want dead players to use this
    OnChatAdd = function(self, speaker, text)
        chat.AddText(self.color, text)
    end
})

if CLIENT then
-- List of eldritch whispers
local eldritchWhispers = {
    "A chilling thought pierces your mind:",
    "An unnerving idea creeps into consciousness:",
    "A sinister notion slithers in uninvited:",
    "A disturbing concept looms suddenly:",
    "An eerie realization grips you unexpectedly:",
    "A whisper of dread echoes within:",
    "A disquieting idea infiltrates your thoughts:",
    "A macabre thought crosses your mind:",
    "A menacing realization dawns on you:",
    "A foreboding musing surfaces unexpectedly:",
    "A haunting notion presents itself:",
    "A cryptic thought unfolds, shrouded in darkness:",
    "A nightmarish idea invades your psyche:",
    "A bizarre understanding emerges from the abyss:",
    "An enigmatic thought manifests, chilling to the core:",
    "A perplexing idea asserts itself, steeped in shadows:",
    "An uncanny insight strikes, filled with foreboding:",
    "A mystifying thought grips you, echoing fears:",
    "An arcane notion descends, heavy with dread:",
    "A surreal idea invades, blurring reality and nightmare:"
}

-- Function to get a random eldritch whisper
local function getRandomEldritchWhisper()
    local index = math.random(1, #eldritchWhispers)
    return eldritchWhispers[index]
end



    net.Receive("ForceSensitivityMessage", function()
        local message = net.ReadString()
        local ply = LocalPlayer()
        --print("Received message: " .. message)  -- Debug print
        chat.AddText(Color(96, 29, 29), getRandomEldritchWhisper())
        chat.AddText(Color(96, 29, 29),"-: " .. message .. " :-")
    end)
end

local MEDITATE_DURATION = ix.config.Get("meditateDuration", 60) -- Duration in seconds
local MEDITATE_COOLDOWN = ix.config.Get("meditateCooldown", 300) -- Cooldown in seconds

-- Command implementation
ix.command.Add("dumpforce", {
    description = "Dumps a character's acquired force powers.",
    superAdminOnly = true,
    arguments = ix.type.character,
    OnRun = function(client, target)
        local char = target
        if not char then
            ix.util.Notify("Invalid character.", client)
            return
        end

        char:SetData("forcepowers", {})
        ix.util.Notify("Your force powers have been removed.", char:GetPlayer())
        ix.util.Notify("Dumped force powers for " .. char:GetName(), client)
        ix.log.Add(client, "FLAG_SERVER", "Dumped force powers for " .. char:GetName())
    end
})


ix.command.Add("printforce", {
    description = "Prints a character's acquired force powers.",
    superAdminOnly = true,
    arguments = ix.type.character,
    OnRun = function(client, target)
        local char = target
        if not char then
            ix.util.Notify("Invalid character.", client)
            return
        end

        local forcePowers = char:GetData("forcepowers", {})
        local forcePowerString = "Force Powers: "
        for _, power in ipairs(forcePowers) do
            forcePowerString = forcePowerString .. power .. ", "
        end
        ix.util.Notify(forcePowerString, client)
        ix.log.Add(client, "FLAG_SERVER", "Printed force powers for " .. char:GetName())
    end
})




ix.command.Add("meditate", {
    description = "Meditate to potentially increase your Force Sensitivity.",
    OnRun = function(self, client)
        local char = client:GetCharacter()
        if not char then return end

        local lastMeditate = char:GetData("lastMeditate", 0)
        local currentTime = os.time()

        -- Check if still on cooldown
        if currentTime < lastMeditate + MEDITATE_COOLDOWN then
            client:Notify("The Force doesn't respond. You must wait before meditating again.")
            return
        end

        -- Notify client of meditation start
        client:Notify("You focus your mind and begin to meditate.")

        if char:GetAttribute("theforce", 0) >= 1 then
            -- Random chance to increase the force attribute
            local randoming = math.random(1, 100)
            if randoming <= 50 then
                char:UpdateAttrib("theforce", math.random(0.1, 1))
            end
            -- Trigger a force message
            checkForceSensitivity(client)
        end

        -- Set the time when the meditation was last done
        char:SetData("lastMeditate", os.time())
    end
})


/*
    ply:lscsAddInventory( "item_force_jump", true )
    ply:lscsAddInventory( "item_force_heal", true ) 
    ply:lscsAddInventory( "item_force_immunity", true )
    ply:lscsAddInventory( "item_force_jump", true )
    ply:lscsAddInventory( "item_force_pull", true )
    ply:lscsAddInventory( "item_force_push", true )
    ply:lscsAddInventory( "item_force_replenish", true )
    ply:lscsAddInventory( "item_force_sense", true ) 
*/
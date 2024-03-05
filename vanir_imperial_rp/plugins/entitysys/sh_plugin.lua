PLUGIN.author = "Theodor"
PLUGIN.description = "Adds a comms system, with destroyable relays."
PLUGIN.name = "Comms System"

local scramblerActive = false
if SERVER then
    util.AddNetworkString("ScramblerState")
    util.AddNetworkString("UpdateScramblerState")

    net.Receive("ScramblerState", function(len, ply)
        local state = net.ReadBool() -- Read the state sent from client

        -- Broadcast the updated state to all clients
        net.Start("UpdateScramblerState")
        net.WriteBool(state)
        net.Broadcast()

        scramblerActive = state -- Update the server's state
    end)
end

    net.Receive("UpdateScramblerState", function()
        scramblerActive = net.ReadBool()
    end)

local function GetEntityHealth()
    local health = 100
    for _, ent in ipairs(ents.FindByClass("ix_commsunit")) do
        if IsValid(ent) then
            health = ent:GetNetVar("Health", 100)
            print("Entity Health: " .. health)  -- Print statement
            break -- Assuming there's only one such entity, break after finding it
        end
    end
    return health
end

local function GarbleTextWithScrambler(text)
    -- New garbling logic when scrambler is active
    -- For simplicity, let's just reverse the text and add a prefix
    return "[SCRAMBLED] " .. string.reverse(text)
end




local function GarbleText(text, health)
    local function randomReplace(str)
        local length = #str
        local numReplacements = math.floor(length * (1 - (health / 100)))
        for i = 1, numReplacements do
            local randomIndex = math.random(1, length)
            str = str:sub(1, randomIndex - 1) .. "-" .. str:sub(randomIndex + 1)
        end
        return str
    end
    if scramblerActive then
        return GarbleTextWithScrambler(text)
    end
    if health < 100 then  -- Starts garbling if health is below 100
        local words = string.Split(text, " ")
        for i = 1, #words do
            if health < 25 or (health >= 25 and i % 2 == 0) then
                words[i] = string.reverse(words[i])
            end
            words[i] = randomReplace(words[i])
        end
        return table.concat(words, " ")
    end
    return text
end



ix.chat.Register("commsChat", {
    format = "[Comms] %s says <:: \"%s\" ::>",
    GetColor = function(self, speaker, text)
        return Color(0, 150, 255) -- Blue color for the comms chat
    end,
    CanHear = function(self, speaker, listener)
        local health = GetEntityHealth()
        if health <= 0 then
            speaker:Notify("Only static can be heard.")
            return false -- Nobody can hear the chat if the entity is destroyed
        end
        return true -- Everyone on the map can hear the chat otherwise
    end,
    prefix = {"/comms", "/c", "/com", "/coms", "/comchat", "/comch", "/commschat", "/commsch"},
    description = "Use this for communicating over the ship comms.",
    indicator = "chatTalking",
    OnChatAdd = function(self, speaker, text, anonymous, info)
        local health = GetEntityHealth()
        local garbledText = text

        -- First, apply health-based garbling if needed
        if health < 50 then
            garbledText = GarbleText(garbledText, health)
        end

        -- Then, apply scrambler effect if active
        if scramblerActive then
            garbledText = GarbleTextWithScrambler(garbledText)
        end

        local color = self:GetColor(speaker, text, info)
        local name = anonymous and L"someone" or hook.Run("GetCharacterName", speaker, "shipcommsChat") or (IsValid(speaker) and speaker:Name() or "Console")

        chat.AddText(color, string.format(self.format, name, garbledText))
    end,
    OnCanSay = function(self, speaker, text)
        local health = GetEntityHealth()
        if health <= 0 then
            ix.util.Notify("Only static can be heard.", speaker)
            return false -- Blocks the message completely
        end
        return true -- Allows the message if the entity is not destroyed
    end,
})
ix.chat.Register("opencommsChat", {
    format = "[Open Comms] %s says <:: \"%s\" ::>",
    GetColor = function(self, speaker, text)
        return Color(223, 204, 0) -- Blue color for the comms chat
    end,
    CanHear = function(self, speaker, listener)
        local health = GetEntityHealth()
        if health <= 0 then
            speaker:Notify("Only static can be heard.")
            return false -- Nobody can hear the chat if the entity is destroyed
        end
        return true -- Everyone on the map can hear the chat otherwise
    end,
    prefix = {"/o", "/open", "/opencomms", "/opencommschat", "/opencommsch","/ocomms", "/ocom", "/ocomchat", "/ocomch","/oc"},
    description = "Use this for communicating over the open comms.",
    indicator = "chatTalking",
    OnChatAdd = function(self, speaker, text, anonymous, info)
        local health = GetEntityHealth()
        local garbledText = text

        -- First, apply health-based garbling if needed
        if health < 50 then
            garbledText = GarbleText(garbledText, health)
        end

        -- Then, apply scrambler effect if active
        if scramblerActive then
            garbledText = GarbleTextWithScrambler(garbledText)
        end

        local color = self:GetColor(speaker, text, info)
        local name = anonymous and L"someone" or hook.Run("GetCharacterName", speaker, "shipcommsChat") or (IsValid(speaker) and speaker:Name() or "Console")

        chat.AddText(color, string.format(self.format, name, garbledText))
    end,
    OnCanSay = function(self, speaker, text)
        local health = GetEntityHealth()
        if health <= 0 then
            ix.util.Notify("Only static can be heard.", speaker)
            return false -- Block the message
        end
        return true -- Allow the message
    end,
})

function PLUGIN:PopulateEntityInfo(ent, tooltip)
    if ent:GetClass() == "ix_commsunit" then
        local name = tooltip:AddRow("name")
        name:SetText("Imperial Comms Console")
        name:SetBackgroundColor(Color(0, 0, 0))
        name:SetImportant()
        name:SizeToContents()

        local desc = tooltip:AddRowAfter("name", "desc")
        desc:SetText("The Imperial Comms Console, pivotal for intra-ship and fleet communications, features an advanced holo-link for real-time commands.\nEquipped with quantum encryption and high-speed data processing, it ensures secure and efficient operations.\nReinforced against combat stress, it's key for strategic coordination in critical missions.")
        desc:SetBackgroundColor(Color(0, 0, 0))
        desc:SizeToContents()


        local healthDesc = tooltip:AddRowAfter("desc", "healthDesc")
        local health = ent:GetNetVar("Health", 100)

        local healthStatus, healthColor
        if health <= 0 then
            healthStatus = "[Status]: System Failure - Critical Damage Detected"
            healthColor = Color(255, 0, 0) -- Red
        elseif health < 50 then
            healthStatus = "[Status]: Severe Structural Integrity Compromise"
            healthColor = Color(255, 165, 0) -- Orange
        elseif health < 100 then
            healthStatus = "[Status]: Minor Functional Anomalies Noted"
            healthColor = Color(255, 255, 0) -- Yellow
        else
            healthStatus = "[Status]: Optimal Operational Capacity Confirmed"
            healthColor = Color(0, 255, 0) -- Green
        end

        healthDesc:SetText(healthStatus)
        healthDesc:SetTextColor(healthColor)
        healthDesc:SetBackgroundColor(Color(0, 0, 0))
        healthDesc:SizeToContents()

elseif ent:GetClass() == "ix_gravityunit" then
    -- New code for Gravity Generator
    local name = tooltip:AddRow("name")
    name:SetText("Imperial Gravity Generator")
    name:SetBackgroundColor(Color(0, 0, 0))
    name:SetImportant()
    name:SizeToContents()

    local desc = tooltip:AddRowAfter("name", "desc")
    desc:SetText("The Imperial Gravity Generator, an engineering marvel, manipulates gravitational fields to simulate or nullify gravity within its operational range.\nDesigned for both strategic deployment and emergency scenarios, it features fail-safe protocols and adaptive environmental modulation.\nVital for maintaining habitat conditions or executing zero-g maneuvers.")
    desc:SetBackgroundColor(Color(0, 0, 0))
    desc:SizeToContents()

    local healthDesc = tooltip:AddRowAfter("desc", "healthDesc")
    local health = ent:GetNetVar("Health", 100)

    local healthStatus, healthColor
    if health <= 0 then
        healthStatus = "[Status]: Gravitational Stabilization Failure - Emergency Protocols Engaged"
        healthColor = Color(255, 0, 0) -- Red
    elseif health < 50 then
        healthStatus = "[Status]: Gravitational Integrity At Risk - Immediate Maintenance Required"
        healthColor = Color(255, 165, 0) -- Orange
    elseif health < 100 then
        healthStatus = "[Status]: Operational Efficiency Reduced - Monitor Closely"
        healthColor = Color(255, 255, 0) -- Yellow
    else
        healthStatus = "[Status]: Full Gravitational Control Achieved - System Stable"
        healthColor = Color(0, 255, 0) -- Green
    end

    healthDesc:SetText(healthStatus)
    healthDesc:SetTextColor(healthColor)
    healthDesc:SetBackgroundColor(Color(0, 0, 0))
    healthDesc:SizeToContents()
end

end
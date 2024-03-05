PLUGIN.name = "D&D Style Rolling"
PLUGIN.description = "Various attributes for characters, as well as an overhauled rolling system."
PLUGIN.author = "Val"

-- default roll
ix.command.Add("roll", {
    description = "Roll a random number.",
    arguments = {bit.bor(ix.type.number, ix.type.optional), bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, numDice, numSides)
        numDice = numDice or 1
        numSides = numSides or 20

        local totalValue = 0
        for i = 1, numDice do
            totalValue = totalValue + math.random(1, numSides)
        end

        local critVal
        if totalValue == numDice * numSides then
            critVal = 1
        elseif totalValue == numDice then
            critVal = -1
        else
            critVal = 0
        end

        ix.chat.Send(client, "roll", tostring(totalValue), nil, nil, {
            numDice = numDice,
            numSides = numSides,
            critVal = critVal
        })

        ix.log.Add(client, "roll", totalValue, {
            numDice = numDice,
            numSides = numSides,
            critVal = critVal
        })
    end
})
ix.chat.Register("roll", {
    format = "** %s has rolled %d out of %d.",
    color = Color(160, 91, 192),
    CanHear = ix.config.Get("chatRange", 280),
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local format = "** %s has rolled %d out of %d"
        local formatWithDice = "** %s has rolled %d out of %d (%dd%d)"
        local critSuccess = "a critical success."
        local critFailure = "a critical failure."
    
        local message
        if data.numDice > 1 then
            message = string.format(formatWithDice, speaker:Name(), tonumber(text), data.numDice * data.numSides, data.numDice, data.numSides)
        else
            message = string.format(format, speaker:Name(), tonumber(text), data.numDice * data.numSides)
        end
    
        if data.critVal == 1 then
            chat.AddText(self.color, message .. ", ", Color(0, 255, 0), critSuccess)
        elseif data.critVal == -1 then
            chat.AddText(self.color, message .. ", ", Color(255, 0, 0), critFailure)
        else
            chat.AddText(self.color, message .. ".")
        end
    end
})

-- rollstat
ix.command.Add("rollstat", {
    description = "Leave fate to chance by rolling a random number with an attribute to boost your odds.",
    arguments = {ix.type.string, bit.bor(ix.type.number, ix.type.optional), bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, attribute, numDice, numSides)
        numDice = numDice or 1
        numSides = numSides or 20

        local totalValue = 0
        for i = 1, numDice do
            totalValue = totalValue + math.random(1, numSides)
        end

        local attributeTable
        local attributeIndex
        local attrply = 0
        local attrVal = 0

        if attribute then
            for k, v in pairs(ix.attributes.list) do
                if string.lower(v.name) == string.lower(attribute) then
                    attributeTable = v
                    attributeIndex = k
                elseif k == string.lower(attribute) then
                    attributeTable = v
                    attributeIndex = k
                elseif v.alias and table.HasValue(v.alias, string.lower(attribute)) then
                    attributeTable = v
                    attributeIndex = k
                end
            end

            if attributeTable == nil then
                return "That is not a valid attribute!"
            end
            attrply = client:GetCharacter():GetAttribute(attributeIndex, 0)
            attrVal = math.floor(attrply / 10)
        end

        local critVal = 0 // -1 = crit fail, 0 = normal, 1 = crit success
        if totalValue == numDice * numSides then
            critVal = 1
        elseif totalValue == numDice then
            critVal = -1
        end

        ix.chat.Send(client, "rollstat", tostring(totalValue), nil, nil, {
            attrName = attributeTable and attributeTable.name or "",
            attrVal = attrVal,
            critVal = critVal,
            numDice = numDice,
            numSides = numSides
        })

        ix.log.Add(client, "rollstat", totalValue, attributeTable and attributeTable.name or "", attrVal, critVal, {
            attrName = attributeTable and attributeTable.name or "",
            attrVal = attrVal,
            critVal = critVal,
            numDice = numDice,
            numSides = numSides
        })
    end
})

ix.chat.Register("rollstat", {
    format = "** %s has rolled %d out of %d on %s.",
    formatWithBonus = "** %s has rolled %d (%d + %d) out of %d on %s.",
    color = Color(160, 91, 192),
    CanHear = ix.config.Get("chatRange", 280),
    deadCanChat = true,
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local format = "** %s has rolled %d out of %d on %s"
        local formatWithBoost = "** %s has rolled %d (%d + %d) out of %d on %s"
        local formatWithDice = "** %s has rolled %d out of %d (%dd%d) on %s"
        local formatWithBoostAndDice = "** %s has rolled %d (%d + %d) out of %d (%dd%d) on %s"
        local critSuccess = "a critical success."
        local critFailure = "a critical failure."
    
        local message
        if data.attrVal > 0 and data.numDice > 1 then
            message = string.format(formatWithBoostAndDice, speaker:Name(), tonumber(text) + data.attrVal, tonumber(text), data.attrVal, data.numDice * data.numSides, data.numDice, data.numSides, data.attrName)
        elseif data.attrVal > 0 then
            message = string.format(formatWithBoost, speaker:Name(), tonumber(text) + data.attrVal, tonumber(text), data.attrVal, data.numDice * data.numSides, data.attrName)
        elseif data.numDice > 1 then
            message = string.format(formatWithDice, speaker:Name(), tonumber(text), data.numDice * data.numSides, data.numDice, data.numSides, data.attrName)
        else
            message = string.format(format, speaker:Name(), tonumber(text), data.numDice * data.numSides, data.attrName)
        end
    
        if data.critVal == 1 then
            chat.AddText(self.color, message .. ", ", Color(0, 255, 0), critSuccess)
        elseif data.critVal == -1 then
            chat.AddText(self.color, message .. ", ", Color(255, 0, 0), critFailure)
        else
            chat.AddText(self.color, message .. ".")
        end
    end
})

if (SERVER) then
ix.log.AddType("rollstat", function(client, value, attr, attrVal, critVal, data)
    local format = "%s rolled %d out of %d on %s"
    local formatWithBoost = "%s rolled %d (%d + %d) out of %d on %s"
    local formatWithDice = "%s rolled %d out of %d (%d + %d) on %s"
    local formatWithBoostAndDice = "%s rolled %d (%d + %d) out of %d (%dd%d) on %s"
    local critSuccess = ", a critical success."
    local critFailure = ", a critical failure."

    local message
    if attrVal > 0 and data.numDice > 1 then
        message = string.format(formatWithBoostAndDice, client:Name(), tonumber(value) + tonumber(attrVal), tonumber(value), attrVal, data.numDice * data.numSides, data.numDice, data.numSides, attr)
    elseif attrVal > 0 then
        message = string.format(formatWithBoost, client:Name(), tonumber(value) + tonumber(attrVal), tonumber(value), attrVal, data.numDice * data.numSides, attr)
    elseif data.numDice > 1 then
        message = string.format(formatWithDice, client:Name(), tonumber(value), data.numDice * data.numSides, data.numDice, data.numSides, attr)
    else
        message = string.format(format, client:Name(), tonumber(value), data.numDice * data.numSides, attr)
    end

    if critVal == 1 then
        return message .. critSuccess
    elseif critVal == -1 then
        return message .. critFailure
    else
        return message .. "."
    end
end)

ix.log.AddType("roll", function(client, value, data)
    local format = "%s rolled %d out of %d (%dd%d)"

    local message = string.format(format, client:Name(), tonumber(value), data.numDice * data.numSides, data.numDice, data.numSides)
    return message .. "."
end)
end

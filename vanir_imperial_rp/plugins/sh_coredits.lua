PLUGIN.name = "Core Edits"
PLUGIN.author = "Theodor"
PLUGIN.description = "Various core edits for the schema."


if (SERVER) then
    local spawn_weapon = "mvp_hands" 
    function PLUGIN:PostPlayerLoadout(client)
        client:StripWeapon("ix_hands")
        client:Give(spawn_weapon)
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
end

ix.chat.Register("iteminternal", {
    format = "**%s %s",
    GetColor = function(speaker, text) return Color(255, 70, 0) end,
    CanHear = ix.config.Get("chatRange", 280),
    deadCanChat = true
})


--adds automatic me's when picking up and dropping items
function PLUGIN:OnItemTransferred(item, curInv, inventory)
	if curInv:GetID() == 0 then
		local client = inventory:GetOwner()
		ix.chat.Send(client, "iteminternal", Format("picks up the %s.", item.name), false)
	end

	if inventory:GetID() == 0 then
		local client = curInv:GetOwner()
		if client then
			ix.chat.Send(client, "iteminternal", Format("drops their %s.", item.name), false)
		end
	end
end

function PLUGIN:InitializedPlugins()
	ix.command.list["becomeclass"] = nil
	ix.command.list["charfallover"] = nil
	ix.command.list["chargetup"] = nil
end


-- Edited the attributes to include the ability to "hide" certain attributes from the character creation menu.
ix.char.RegisterVar("attributes", {
    field = "attributes",
    fieldType = ix.type.text,
    default = {},
    index = 4,
    category = "attributes",
    isLocal = true,
    OnDisplay = function(self, container, payload)

        local maximum = hook.Run("GetDefaultAttributePoints", LocalPlayer(), payload) or 10

        if (maximum < 1) then
            return
        end
        local attributes = container:Add("DPanel")
        attributes:Dock(TOP)


        local y
        local total = 0

        payload.attributes = {}

        -- total spendable attribute points
        local totalBar = attributes:Add("ixAttributeBar")
        totalBar:SetMax(maximum)
        totalBar:SetValue(maximum)
        totalBar:Dock(TOP)
        totalBar:DockMargin(2, 2, 2, 2)
        totalBar:SetText(L("attribPointsLeft"))
        totalBar:SetReadOnly(true)
        totalBar:SetColor(Color(20, 120, 20, 255))

        y = totalBar:GetTall() + 4

        for k, v in SortedPairsByMemberValue(ix.attributes.list, "name") do
            if v.bNoDisplay then continue end
            payload.attributes[k] = 0

            local bar = attributes:Add("ixAttributeBar")
            bar:SetMax(maximum)
            bar:Dock(TOP)
            bar:DockMargin(2, 2, 2, 2)
            bar:SetText(L(v.name))
            bar.OnChanged = function(this, difference)
                if ((total + difference) > maximum) then
                    return false
                end

                total = total + difference
                payload.attributes[k] = payload.attributes[k] + difference

                totalBar:SetValue(totalBar.value - difference)
            end

            if (v.noStartBonus) then
                bar:SetReadOnly()
            end

            y = y + bar:GetTall() + 4
        end

        attributes:SetTall(y)
        return attributes
    end,
    OnValidate = function(self, value, data, client)
        if (value != nil) then
            if (istable(value)) then
                local count = 0

                for _, v in pairs(value) do
                    count = count + v
                end

                if (count > (hook.Run("GetDefaultAttributePoints", client, count) or 10)) then
                    return false, "unknownError"
                end
            else
                return false, "unknownError"
            end
        end
    end,
    ShouldDisplay = function(self, container, payload)
        return !table.IsEmpty(ix.attributes.list)
    end
})


-- Relic from the description system. There's probably a built in command for this alreay lol. dont know dont care.
ix.command.Add("AdminSetDescription", {
    description = "Sets a player's character description.",
    adminOnly = true,  -- This command is for admins only
    arguments = {
        ix.type.character,  -- The target character
        ix.type.text  -- The new description
    },
    OnRun = function(self, client, targetCharacter, newDescription)
        -- Check if the target character is valid
        if (not targetCharacter or not IsValid(targetCharacter:GetPlayer())) then
            return "Invalid target."
        end

        -- Update the character's description
        targetCharacter:SetDescription(newDescription)
        targetCharacter:GetPlayer():Notify("Your description has been updated by an admin.")
        -- Notify the admin
        return "You have updated " .. targetCharacter:GetName() .. "'s description."

        -- Optionally, you can also notify the target player
    end
})
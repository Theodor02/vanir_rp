// helix plugin info, such as plugin name, author etc
PLUGIN.name = "Helix UI Changes"
PLUGIN.author = "Theodor"
PLUGIN.description = "Several UI changes to the Helix framework, to better work with the different systems on the server."


hook.Add("CreateMenuButtons", "ixBusiness", function(tabs)

end)

function PLUGIN:ShouldHideBars()
    return true  -- Always hide the bars
end

function PLUGIN:CanDrawAmmoHUD(weapon)
    return false -- Always hide the ammo hud
end



if CLIENT then
    function PLUGIN:CreateCharacterInfo(characterInfo)
        local playerObj = LocalPlayer()
        if not IsValid(playerObj) then return end
        -- RANK
        local rankRow = characterInfo:Add("ixListRow")
        rankRow:SetList(characterInfo.list)
        rankRow:Dock(TOP)
        local rank = LocalPlayer():GetCharacter():GetData("rank") or "None"
        rankRow:SetLabelText("Rank:")
        rankRow:SetText(rank)
        rankRow:SizeToContents()

        -- Allegiance
        local allegianceRow = characterInfo:Add("ixListRow")
        allegianceRow:SetList(characterInfo.list)
        allegianceRow:Dock(TOP)
        local alleg = (playerObj.RSS_GetAllegiance and playerObj:RSS_GetAllegiance()) or "None"
        alleg = alleg ~= "None" and alleg or "Allegianceless"
        allegianceRow:SetLabelText("Allegiance:")
        allegianceRow:SetText(alleg)
        allegianceRow:SizeToContents()

        -- Squad
        local squadRow = characterInfo:Add("ixListRow")
        squadRow:SetList(characterInfo.list)
        squadRow:Dock(TOP)
        local squad = (playerObj.RSS_GetSquad and playerObj:RSS_GetSquad()) or "None"
        squad = squad ~= "None" and squad or "Squadless"
        squadRow:SetLabelText("Squad:")
        squadRow:SetText(squad)
        squadRow:SizeToContents()

        -- Role
        local roleRow = characterInfo:Add("ixListRow")
        roleRow:SetList(characterInfo.list)
        roleRow:Dock(TOP)
        local role = (playerObj.RSS_GetRole and playerObj:RSS_GetRole()) or "None"
        role = role ~= "None" and role or "Roleless (Contact a staff member)"
        roleRow:SetLabelText("Role:")
        roleRow:SetText(role)
        roleRow:SizeToContents()
    end


end

function PLUGIN:CanCreateCharacterInfo(suppress)
    suppress.faction = true
end



function PLUGIN:PopulateCharacterInfo(client, character, container)
	if (client:Alive() and character:GetBleedout()) then
		local panel = container:AddRow("bleedout")
		panel:SetText(L("charBleedOut"))
		panel:SetBackgroundColor(Color(255, 0, 0, 255))
		panel:SizeToContents()
		panel:Dock(BOTTOM)
	end
end

function PLUGIN:GetInjuredText(client)
	if(client:GetCharacter():GetBleedout()) then
		return false
	end
end

net.Receive("BleedingOut", function()
	if (IsValid(ix.gui.bleedoutScreen)) then
		ix.gui.bleedoutScreen:Remove()
		return
	end

	if(LocalPlayer():GetCharacter():GetBleedout()) then
		ix.gui.bleedoutScreen = vgui.Create("BleedingScreen")
		return
	end
	
end)


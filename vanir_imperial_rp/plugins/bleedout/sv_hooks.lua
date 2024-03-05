util.AddNetworkString("BleedingOut")

function PLUGIN:PostPlayerDeath(ply)
	local char = ply:GetCharacter()

	if (char and char:GetBleedout()) then
		char:SetBleedout(false)
		net.Start("BleedingOut")
		net.Send(ply)
	end
end

function PLUGIN:PlayerLoadedCharacter(client, character)
	if (character and character:GetBleedout()) then
		character:SetBleedout(false)
		client:NotifyLocalized("bledOut")
		client:Kill()
	end
end

function PLUGIN:CanPlayerUseCharacter(client, character)
	local currentCharacter = client:GetCharacter()

	if (currentCharacter and currentCharacter:GetBleedout()) then
		return false
	end
end

local PLUGIN = PLUGIN

function PLUGIN:PlayerHurt(victim, attacker, healthRemaining)
	if (healthRemaining <= 0 and healthRemaining >= -30) then -- Too much damage will bypass the bleedout system.
		local char = victim:GetCharacter()
		if (char:GetBleedout()) then -- They are already bleeding out.
			victim:NotifyLocalized("finishedOff")
			return
		end
		char:SetBleedout(true)
		victim:SetHealth(1)
		PLUGIN:EnterBleedout(victim)
	end
end

function PLUGIN:EnterBleedout(player)
	player:SetRagdolled(true)

	local time = ix.config.Get("BleedoutTime", 60)
	
	player:NotifyLocalized("bleedingOutLong")
	player:SetAction("", time-1)
	
	net.Start("BleedingOut")
	net.Send(player)

	local ent = player.ixRagdoll

	if (IsValid(ent)) then
		local uid = "bleedouttime"..player:GetCharacter():GetID()
		timer.Create(uid,time-1, 1, function()
			if (IsValid(ent)) then
				player:NotifyLocalized("bledOut")
				ent.ixPlayer:Kill()
			end
		end)
	end
end

function PLUGIN:Revive(player)
	local char = player:GetCharacter()
	if (char:GetBleedout()) then
		char:SetBleedout(false)

		player:SetAction()
		player:SetRagdolled(false)
		player:NotifyLocalized("stabilized")

		net.Start("BleedingOut")
		net.Send(player)
	end
end

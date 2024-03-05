local PLUGIN = PLUGIN

ix.command.Add("CharGetUp", {
	description = "@cmdCharGetUp",
	OnRun = function(self, client, arguments)
		local entity = client.ixRagdoll

		if (IsValid(entity) and entity.ixGrace and entity.ixGrace < CurTime() and
			entity:GetVelocity():Length2D() < 8 and !entity.ixWakingUp and !client:GetCharacter():GetBleedout()) then
			entity.ixWakingUp = true
			entity:CallOnRemove("CharGetUp", function()
				client:SetAction()
			end)

			client:SetAction("@gettingUp", 5, function()
				if (!IsValid(entity)) then
					return
				end

				hook.Run("OnCharacterGetup", client, entity)
				entity:Remove()
			end)
		end
	end
})

ix.command.Add("AcceptDeath", {
	description = "@cmdAcceptDeath",
	OnRun = function(self, client, arguments)
		
		if(!client:GetCharacter():GetBleedout()) then
			return "@notNow"
		end

		local ent = client.ixRagdoll
		if(IsValid(ent)) then
			ent.ixPlayer:Kill()
			client:NotifyLocalized("deathAccepted")
		end
		
	end
})

ix.command.Add("CharAdminRevive", {
	description = "@cmdAdminRevive",
	adminOnly = true,
	arguments = {
		ix.type.character
	},
	OnRun = function(self, client, target)
		
		if(!target:GetBleedout()) then
			return "@notNow"
		end

		PLUGIN:Revive(target.player)
	end
})

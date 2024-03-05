ITEM.name = "Bacta Infusion Syrette"
ITEM.model = "models/krieg/galacticempire/props/bacta_syringe.mdl"
ITEM.description = "The Bacta Infusion Syrette, offers rapid wound healing through a concentrated bacta formula. Designed for efficiency and ease of use under fire, it quickly stabilizes injuries and counters toxins, ensuring Imperial troops remain battle-ready."
ITEM.category = "Medical"

ITEM.functions.Stabilize = { 
	name = "Stabilize",
	tip = "Stabilize the target character.",
	icon = "icon16/user_add.png",
	OnRun = function(item)
		local player = item.player
		local trace = player:GetEyeTraceNoCursor()
		local target = trace.Entity

		if(!target.ixPlayer) then
			player:Notify("You must be looking at a player!")
			return false
		end
	
		player:SetAction("@stabilizing", 10)
		player:DoStaredAction(target, function()
			hook.Run("Revive", target.ixPlayer)
		end, 10)

	end,

	OnCanRun =  function(item)
		local ent = item.player:GetEyeTraceNoCursor().Entity
		
		return ent:IsRagdoll()
	end
}

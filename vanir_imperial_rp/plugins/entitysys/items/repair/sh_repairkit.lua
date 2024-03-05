ITEM.name = "Standard Issue Repair Kit"
ITEM.description = "Standard issue repair kit for imperial machines."
ITEM.model = "models/krieg/galacticempire/props/mag_medium.mdl"
ITEM.width = 1
ITEM.height = 1


ITEM.functions.Repair = {
    name = "Repair",
    OnRun = function(item)
        local client = item.player
        local entity = client:GetEyeTrace().Entity
        local intelligence = client:GetCharacter():GetAttribute("intelligence", 0)

        -- Define a list of valid entities for repair
        local validEntities = {
            "ix_commsunit",
            "ix_gravityunit", -- Example additional entity class
            -- Add more entity classes as needed
        }

    -- Adjustments based on intelligence
        -- Increase the base failure chance and adjust the influence of intelligence
        local failChance = math.Clamp(35 - intelligence, 10, 35) -- 10% to 35% failure chance
        local criticalFailChance = math.Clamp(15 - (intelligence / 5), 5, 15) -- 5% to 15% critical failure chance
        local repairTime = math.Clamp(6 - (intelligence / 20), 3, 6) -- 3 to 6 seconds repair time, less influenced by intelligence

        -- Check if the entity is valid and within range
        if IsValid(entity) and table.HasValue(validEntities, entity:GetClass()) and client:GetPos():Distance(entity:GetPos()) <= 100 then
            client:SetAction("Repairing...", repairTime)

            client:DoStaredAction(entity, function()
                if math.random(100) <= failChance then
                    -- Handle failure
                    if math.random(100) <= criticalFailChance then  -- Increased chance for critical failure
                        client:TakeDamage(10)  -- Player takes 10 damage
                        client:EmitSound("weapons/shock/destruction_explosions_modular_sfx_small_disruption_var_05.mp3")
                        client:Notify("You received a shock during the repair!")
                        ix.chat.Send(client, "iteminternal"," received a shock during an attempt to repair the device.", false)
                    else
                        client:Notify("Repair attempt failed.")
                        ix.chat.Send(client, "iteminternal"," failed to repair the device.", false)
                    end
                    client:SetAction()  -- Stop the repair action
                else
                    -- Successful repair
                    entity:SetNetVar("Health", 100)
                    entity.exploded = false
                    client:Notify("The device has been repaired.")
                    ix.chat.Send(client, "iteminternal"," has successfully repaired the device using a " .. item.name .. ".", false)
                    client:GetCharacter():UpdateAttrib("intelligence", math.random(0,0.5)) -- Increase intelligence by 0 to 0.5
                    -- Remove the repair item from the player's inventory
                    item:Remove()
                    return true
                end
            end, repairTime, function()
                client:Notify("Repair interrupted.")
                ix.chat.Send(client, "iteminternal","'s repair attempt was interrupted.", false)
            end)
        else
            client:Notify("You must be closer to a damaged device.")
        end

        return false
    end,
    OnCanRun = function(item)
        return true
    end
}
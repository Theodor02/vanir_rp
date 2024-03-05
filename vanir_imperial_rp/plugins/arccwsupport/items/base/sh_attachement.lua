ITEM.name = "Attachement"
ITEM.description = "Weapon attachement"
ITEM.model = Model("models/props_debris/concrete_cynderblock001.mdl")
ITEM.category = "Attachments"
ITEM.attachment = "attachementid"
ITEM.width = 1
ITEM.height = 1


local function FindAttachSlot(weapon, attachment)
    if not weapon or not weapon.Attachments or not attachment then return nil end

    for slot, attData in pairs(weapon.Attachments) do
        local compatibleAtts = ArcCW:GetAttsForSlot(slot, weapon)
        if table.HasValue(compatibleAtts, attachment) then
            print("Compatible slot found:", slot)  -- Debugging line
            return slot
        end
    end

    print("No compatible slot found for attachment:", attachment)  -- Debugging line
    return nil
end


local function IsAttachmentCompatible(weapon, attachment)
    -- Define a filter function that checks for compatibility based on your criteria
    local filter = function(k, v)
        -- Example filter logic: check if the attachment can be applied to the weapon class
        -- Adjust this logic based on the actual compatibility rules you need to enforce
        if v.WeaponType and ((type(v.WeaponType) == "table" and table.HasValue(v.WeaponType, weapon:GetClass())) or (type(v.WeaponType) == "string" and v.WeaponType == weapon:GetClass())) then
            return k, v
        end
        return nil
    end

    -- Retrieve the filtered list of compatible attachments
    local compatibleAttachments = ArcCW:GetAttList("compatibleAttachments_" .. weapon:GetClass(), filter)

    -- Check if the specified attachment is in the list of compatible att  >achments
    return compatibleAttachments[attachment] ~= nil
end


ITEM.functions.Attach = {
    name = "Attach",
    icon = "icon16/add.png",
    OnRun = function(item)
        local client = item.player
        local attachment = item.attachment
        if IsValid(client) then
            local plywep = client:GetActiveWeapon()
            if IsValid(plywep) then
                -- Use the compatibility check before attempting to attach
                if IsAttachmentCompatible(plywep, attachment) then
                    -- Assuming FindAttachSlot and plywep:Attach work as intended
                    local slot = FindAttachSlot(plywep, attachment)
                    if slot then
                        plywep:Attach(slot, attachment)  -- Ensure this matches the actual method signature for attaching an attachment
                        client:Notify("Attachment added successfully.")
                        return true
                    else
                        client:Notify("Could not determine the correct slot for this attachment.")
                    end
                else
                    client:Notify("This weapon does not accept this attachment.")
                end
            end
        end
        return false
    
    
    end,
    OnCanRun = function(item)
        -- only allow admins to run this item function
        local client = item.player
        local canRun = IsValid(client) and client:IsAdmin()
        print("[Debug] OnCanRun - IsValid(client):", IsValid(client), "isAdmin:", client and client:IsAdmin() or "N/A")
        return canRun
    end
}



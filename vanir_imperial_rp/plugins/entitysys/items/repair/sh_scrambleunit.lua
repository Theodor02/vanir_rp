ITEM.name = "Scrambler Device"
ITEM.description = "A device that scrambles nearby communications when activated."
ITEM.model = "models/props_lab/reciever01b.mdl" -- Replace with your desired model

-- Global variable to track the scrambler's state



ITEM.functions.Scramble = {
    name = "Activate Scrambler",
    OnRun = function(item)
        -- Assuming this is server-side
        scramblerActive = true -- Directly set the global variable
        item.player:Notify("Scrambler activated.")
        
        -- Broadcast the updated state to all clients
        net.Start("UpdateScramblerState")
        net.WriteBool(true)
        net.Broadcast()

        return false -- To keep the item after activating the scrambler
    end
}

ITEM.functions.UnScramble = {
    name = "Deactivate Scrambler",
    OnRun = function(item)
        -- Assuming this is server-side
        scramblerActive = false -- Directly set the global variable
        item.player:Notify("Scrambler deactivated.")

        -- Broadcast the updated state to all clients
        net.Start("UpdateScramblerState")
        net.WriteBool(false)
        net.Broadcast()

        return false -- To keep the item after deactivating the scrambler
    end
}

function ITEM:OnRemoved()
    if SERVER and scramblerActive then
        -- Reset the scrambler state
        scramblerActive = false

        -- Notify all clients about the state change
        net.Start("UpdateScramblerState")
        net.WriteBool(false)
        net.Broadcast()
    end
end
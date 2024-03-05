PLUGIN.name = "Downtime Notification"
PLUGIN.author = "Theodor and ChatGPT(99% chatgpt)"
PLUGIN.description = "Notifies players when the server is in downtime due to low player count, and when it is over."

-- Interval for checking player count (in seconds)


ix.config.Add("PlayerCount", 5, "Interval for checking player count (in seconds)", nil, {
    data = {min = 1, max = 100},
    category = "Downtime"
})




-- Server state for downtime
PLUGIN.isdowntime = false

-- Function to check player count and notify
function PLUGIN:CheckPlayerCount()
    local playerCount = #player.GetAll()
    local playeramount = ix.config.Get("PlayerCount", 5)

    if playerCount < playeramount and not self.isdowntime then
        ix.util.Notify("It is currently downtime due to low player count.", player.GetAll())
        self.isdowntime = true
    elseif playerCount >= playeramount and self.isdowntime then
        ix.util.Notify("Downtime is over.", player.GetAll())
        self.isdowntime = false
    end
end


-- does not check on player leave. It should probably do that.
function PLUGIN:PlayerLoadedCharacter()
    self:CheckPlayerCount()
end

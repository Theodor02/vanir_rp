
-- Here is where all of your shared hooks should go.

-- Disable entity driving.


function Schema:CanPlayerUseCharacter(client, character)
	local banned = character:GetData("banned")

	if (banned) then
		if (isnumber(banned)) then
			if (banned < os.time()) then
				return
			end

			return false, "@charBannedTemp"
		end

		return false, "@charBanned"
    else
        return true
	end
end
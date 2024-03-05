local PLUGIN = PLUGIN or {}

PLUGIN.name = "Certification Handler"
PLUGIN.author = "Theodor"
PLUGIN.desc = "Handles automatic certification of players. For RSS."

if SERVER then
    util.AddNetworkString("SendPlayerCertification")
    util.AddNetworkString("CheckPlayerCertification")
    util.AddNetworkString("AnswerPlayerCertification")

    local autoCerts = {
        ["navy crew"] = "Navy Trained",
        ["stormtrooper"] = "Stormtrooper Trained",
    }

    -- Dynamic certification handler.
    function PLUGIN:CertifHandler(ply, certif)
        net.Receive("SendPlayerCertification", function(len, ply)
            local cert = net.ReadString()
            if ply == nil then
                print("CertifHandler: Player entity is nil.")
                return
            end
            if ply:GetCharacter() == nil then
                print("CertifHandler: Player character is nil.")
                return
            end
            local certName = autoCerts[cert]
            if certName == nil then
                print("CertifHandler: Invalid certification '" .. cert .. "'. NET Injection Attempt by " .. ply:Nick() .. " | SteamID: " .. ply:SteamID())
                return
            end
            if not wOS.RenegadeSquad.Certif:HasCertification(ply, certName) then
                wOS.RenegadeSquad.Certif:AddCertification(ply, certName)
                -- Notify the player of successful certification
                ix.util.Notify("You have been certified for: " .. certName, ply)
            end
        end)
    end



-- Dynamic certification checker. Takes the player and a table of certification names to check for.
-- Sends back true if the player has all the certs, false otherwise.
function PLUGIN:CertifChecker()
    net.Receive("CheckPlayerCertification", function(len, ply)
        local certifs = net.ReadTable()
        if not IsValid(ply) or not ply:GetCharacter() then return end

        local hasAllCerts = true
        for _, certName in ipairs(certifs) do
            if not wOS.RenegadeSquad.Certif:HasCertification(ply, certName) then
                hasAllCerts = false
                break
            end
        end

        net.Start("AnswerPlayerCertification")
        net.WriteBool(hasAllCerts)
        net.Send(ply)
    end)
end

    -- Calling the handler to ensure it is active
    PLUGIN:CertifHandler()
    PLUGIN:CertifChecker()
end
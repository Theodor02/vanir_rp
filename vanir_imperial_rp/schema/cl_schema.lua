
-- Here is where all of your clientside functions should go.

-- Example client function that will print to the chatbox.
function Schema:ExampleFunction(text, ...)
	if (text:sub(1, 1) == "@") then
		text = L(text:sub(2), ...)
	end

	LocalPlayer():ChatPrint(text)
end

-- credits https://github.com/bloodycop7/ixehl2rp/
function Schema:SendCaption(text, duration)
	RunConsoleCommand("closecaption", "1")
	gui.AddCaption(text, duration or string.len(text) * 0.1)
end

function Schema:OpenUI(panel)
	return vgui.Create(panel)
end

-- Make sure to use correct certif keys. Check the plugin certifhandler.lua for more info. If not you're going to call innocent players net injectors :D
function Schema:CertifSend(ply, certif)
	net.Start("SendPlayerCertification")
	net.WriteString(certif)
	net.SendToServer()
end

-- Function to request a certification check and handle the response
function Schema:CertificationCheck(certifications)
	net.Start("CheckPlayerCertification")
    net.WriteTable(certifications)
    net.SendToServer()

    net.Receive("AnswerPlayerCertification", function()
        local hasAllCerts = net.ReadBool()
        -- Handle the response here
        if hasAllCerts then
			return true
        else
			return false
        end
    end)
end

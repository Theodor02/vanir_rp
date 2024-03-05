
-- The shared init file. You'll want to fill out the info for your schema and include any other files that you need.

-- Schema info
Schema.name = "Vanir Imperial Remnant RP"
Schema.author = "Theodor"
Schema.description = "An Imperial Remnant RP."

-- Additional files that aren't auto-included should be included here. Note that ix.util.Include will take care of properly
-- using AddCSLuaFile, given that your files have the proper naming scheme.

-- You could technically put most of your schema code into a couple of files, but that makes your code a lot harder to manage -
-- especially once your project grows in size. The standard convention is to have your miscellaneous functions that don't belong
-- in a library reside in your cl/sh/sv_schema.lua files. Your gamemode hooks should reside in cl/sh/sv_hooks.lua. Logical
-- groupings of functions should be put into their own libraries in the libs/ folder. Everything in the libs/ folder is loaded
-- automatically.
ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")

ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")

-- You'll need to manually include files in the meta/ folder, however.
ix.util.Include("meta/sh_character.lua")
ix.util.Include("meta/sh_player.lua")


ix.util.Include("libs/thirdparty/sh_netstream2.lua")

ix.config.SetDefault("font", "Raju Regular")
ix.config.SetDefault("genericFont", "Raju Regular")


-- credits: https://github.com/bloodycop7/ixehl2rp/

function Schema:ColorToText(color)
    if not ( IsColor(color) ) then
        return
    end

    return ( color.r or 255 ) .. "," .. ( color.g or 255 ) .. "," .. ( color.b or 255 ) .. "," .. ( color.a or 255 )
end




function Schema:InitializedChatClasses()
    ix.chat.Register("ic", {
        format = "%s says \"%s\"",
        indicator = "chatTalking",
        GetColor = function(self, speaker, text)
            -- If you are looking at the speaker, make it greener to easier identify who is talking.
            if (LocalPlayer():GetEyeTrace().Entity == speaker) then
                return ix.config.Get("chatListenColor")
            end

            -- Otherwise, use the normal chat color.
            return ix.config.Get("chatColor")
        end,
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local color = self.color
			local name = anonymous and
				L"someone" or hook.Run("GetCharacterName", speaker, "ic") or
				(IsValid(speaker) and speaker:Name() or "Console")

			if (self.GetColor) then
				color = self:GetColor(speaker, text, info)
			end

			local translated = L2("ic" .. "Format", name, text)

			chat.AddText(color, translated or string.format(self.format, name, text))
        end,
        CanHear = ix.config.Get("chatRange", 280)
    })

    -- Actions and such.
    ix.chat.Register("me", {
        format = "** %s %s",
        GetColor = ix.chat.classes.ic.GetColor,
        CanHear = ix.config.Get("chatRange", 280) * 2,
        prefix = {"/Me", "/Action"},
        description = "@cmdMe",
        indicator = "chatPerforming",
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local color = ix.chat.classes["ic"]:GetColor(speaker, text, anonymous, info)

            local name = anonymous and
				L"someone" or hook.Run("GetCharacterName", speaker, "ic") or
				(IsValid(speaker) and speaker:Name() or "Console")

            chat.AddText(color, string.format(self.format, name, text))
        end,
        deadCanChat = true
    })

    -- Actions and such.
    ix.chat.Register("it", {
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local colorToText = Schema:ColorToText(ix.config.Get("chatColor"))

            chat.AddText(ix.config.Get("chatColor"), "** "..text)
        end,
        CanHear = ix.config.Get("chatRange", 280) * 2,
        prefix = {"/It"},
        description = "@cmdIt",
        indicator = "chatPerforming",
        deadCanChat = true
    })

    -- Whisper chat.
    ix.chat.Register("w", {
        format = "%s whispers \"%s\"",
        GetColor = function(self, speaker, text)
            local color = ix.chat.classes.ic:GetColor(speaker, text)

            -- Make the whisper chat slightly darker than IC chat.
            return Color(color.r - 35, color.g - 35, color.b - 35)
        end,
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local colToGet = ix.chat.classes.ic:GetColor(speaker, text, anonymous, info)
            colToGet = Color(colToGet.r - 35, colToGet.g - 35, colToGet.b - 35)

            local colorToText = Schema:ColorToText(colToGet)

            local name = anonymous and
				L"someone" or hook.Run("GetCharacterName", speaker, "ic") or
				(IsValid(speaker) and speaker:Name() or "Console")

            
            chat.AddText(colToGet, string.format(self.format, name, text))
        end,
        CanHear = ix.config.Get("chatRange", 280) * 0.25,
        prefix = {"/W", "/Whisper"},
        description = "@cmdW",
        indicator = "chatWhispering"
    })

    -- Yelling out loud.
    ix.chat.Register("y", {
        format = "%s yells \"%s\"",
        GetColor = function(self, speaker, text)
            local color = ix.chat.classes.ic:GetColor(speaker, text)

            -- Make the yell chat slightly brighter than IC chat.
            return Color(color.r + 35, color.g + 35, color.b + 35)
        end,
        OnChatAdd = function(self, speaker, text, anonymous, info)
            local colToGet = ix.chat.classes.ic:GetColor(speaker, text, anonymous, info)
            colToGet = Color(colToGet.r + 35, colToGet.g + 35, colToGet.b + 35)

            local colorToText = Schema:ColorToText(colToGet)

            local name = anonymous and
				L"someone" or hook.Run("GetCharacterName", speaker, "ic") or
				(IsValid(speaker) and speaker:Name() or "Console")

            chat.AddText(colToGet, string.format(self.format, name, text))
        end,
        CanHear = ix.config.Get("chatRange", 280) * 2,
        prefix = {"/Y", "/Yell"},
        description = "@cmdY",
        indicator = "chatYelling"
    })

    -- Out of character.
    ix.chat.Register("ooc", {
        CanSay = function(self, speaker, text)
            if (!ix.config.Get("allowGlobalOOC")) then
                speaker:NotifyLocalized("Global OOC is disabled on this server.")
                return false
            else
                local delay = ix.config.Get("oocDelay", 10)

                -- Only need to check the time if they have spoken in OOC chat before.
                if (delay > 0 and speaker.ixLastOOC) then
                    local lastOOC = CurTime() - speaker.ixLastOOC

                    -- Use this method of checking time in case the oocDelay config changes.
                    if (lastOOC <= delay and !CAMI.PlayerHasAccess(speaker, "Helix - Bypass OOC Timer", nil)) then
                        speaker:NotifyLocalized("oocDelay", delay - math.ceil(lastOOC))

                        return false
                    end
                end

                -- Save the last time they spoke in OOC.
                speaker.ixLastOOC = CurTime()
            end
        end,
        OnChatAdd = function(self, speaker, text)
            -- @todo remove and fix actual cause of speaker being nil
            if (!IsValid(speaker)) then
                return
            end

            local icon = "icon16/user.png"

            if (speaker:IsSuperAdmin()) then
                icon = "icon16/shield.png"
            elseif (speaker:IsAdmin()) then
                icon = "icon16/star.png"
            elseif (speaker:IsUserGroup("moderator") or speaker:IsUserGroup("operator")) then
                icon = "icon16/wrench.png"
            elseif (speaker:IsUserGroup("vip") or speaker:IsUserGroup("donator") or speaker:IsUserGroup("donor")) then
                icon = "icon16/heart.png"
            end

            icon = Material(hook.Run("GetPlayerIcon", speaker) or icon)

            chat.AddText(icon, Color(255, 50, 50), "[OOC] ", speaker, color_white, ": "..text)
        end,
        prefix = {"//", "/OOC"},
        description = "@cmdOOC",
        noSpaceAfter = true
    })

    -- Local out of character.
    ix.chat.Register("looc", {
        CanSay = function(self, speaker, text)
            local delay = ix.config.Get("loocDelay", 0)

            -- Only need to check the time if they have spoken in OOC chat before.
            if (delay > 0 and speaker.ixLastLOOC) then
                local lastLOOC = CurTime() - speaker.ixLastLOOC

                -- Use this method of checking time in case the oocDelay config changes.
                if (lastLOOC <= delay and !CAMI.PlayerHasAccess(speaker, "Helix - Bypass OOC Timer", nil)) then
                    speaker:NotifyLocalized("loocDelay", delay - math.ceil(lastLOOC))

                    return false
                end
            end

            -- Save the last time they spoke in OOC.
            speaker.ixLastLOOC = CurTime()
        end,
        OnChatAdd = function(self, speaker, text)
            chat.AddText(Color(255, 50, 50), "[LOOC] ", ix.config.Get("chatColor"), speaker:Name()..": "..text)
        end,
        CanHear = ix.config.Get("chatRange", 280),
        prefix = {".//", "[[", "/LOOC"},
        description = "@cmdLOOC",
        noSpaceAfter = true
    })

    ix.chat.Register("event", {
        CanHear = 1000000,
        OnChatAdd = function(self, speaker, text)
            Schema:SendCaption("<clr:" .. Schema:ColorToText(Color(255, 150, 0)) .. ">" .. text)
            chat.AddText(Color(255, 150, 0), text)
        end,
        indicator = "chatPerforming"
    })
end

function Schema:OnReloaded()
    self:InitializedChatClasses()
end

function Schema:IsOutside(ply)
    local trace = util.TraceLine({
        start = ply:GetPos(),
        endpos = ply:GetPos() + ply:GetUp() * 9999999999,
        filter = ply
    })

    return trace.HitSky
end



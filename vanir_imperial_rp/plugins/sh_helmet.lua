local PLUGIN = PLUGIN or {}
PLUGIN.author = "Theodor"
PLUGIN.name = "Helmet system"
PLUGIN.desc = "Handles taking off and putting on helmets. Which updates your description"


-- Helmet commands, to take of helmet and equip helmet. Applies a playhers character creation bodygroups. This is also very jank. See explanation in the char creation plugin. 
-- This should've probable been part of the character creation plugin. As to minimise the amount of code repetition. But it is what it is.

local hairColorMapping = {
    ["Blonde"] = Vector(1, 0.85, 0.55), -- Example values, adjust as needed
    ["Brown"] = Vector(0.65, 0.33, 0.15),
    ["Black"] = Vector(0.15, 0.15, 0.15),
    ["Grey"] = Vector(0.75, 0.75, 0.75),
    ["Red"] = Vector(1, 0, 0),
    ["Orange"] = Vector(1, 0.65, 0),
    ["Yellow"] = Vector(1, 1, 0)
    -- Add other colors as needed
}
-- Default values for each option
  local customizationToSubmodel = {
          -- Hair options
      ["Mohawk"] = "STORMTROOPER/head_hair3.smd",
      ["Ponytail"] = "STORMTROOPER/head_hair4.smd",
      ["Bald"] = "STORMTROOPER/head_hair0.smd",
      ["Side"] = "STORMTROOPER/head_hair2.smd",
      ["Balding"] = "STORMTROOPER/head_hair6.smd",
      ["Straight"] = "STORMTROOPER/head_hair1.smd",
      -- Facial hair options
      ["Clean"] = "STORMTROOPER/head_facial_0.smd",
      ["Side Burns"] = "STORMTROOPER/head_facial_2.smd",
      ["Beard"] = "STORMTROOPER/head_facial_3.smd",
      ["Moustache"] = "STORMTROOPER/head_facial_5.smd",
      ["Goatee"] = "STORMTROOPER/head_facial_6.smd",
      -- Hair color options do not correspond to bodygroups in the images, so they are not included here - -- Species options
      ["Human"] = "STORMTROOPER/head_HUMAN_MALE01.smd", -- Assuming option 1 is the first human model
      ["Dathomirian"] = "STORMTROOPER/head_HUMAN_MALE02.smd", -- Assuming option 2 is the second human model
      ["Mirialan"] = "STORMTROOPER/head_HUMAN_MALE04.smd", -- Assuming option 4 is the fourth human model
      ["Chiss"] = "STORMTROOPER/head_HUMAN_MALE05.smd",
  }

local function GetSubgroupIndex(player, customizationOption)
    local bodygroups = player:GetBodyGroups()
    for _, bodygroup in ipairs(bodygroups) do
        for submodelIndex, submodelFilename in ipairs(bodygroup.submodels) do
            if submodelFilename == customizationToSubmodel[customizationOption] then
                return bodygroup.id, submodelIndex
            end
        end
    end
    -- Handling default states for "Side" and "Beard"
    if customizationOption == "Bald" then  -- Assuming "Bald" is the default state for hair
        local hairBodygroupID = GetBodygroupIDForKnownOption(player, "Side")
        return hairBodygroupID, 0
    elseif customizationOption == "Clean" then  -- Assuming "Clean" is the default state for facial hair
        local facialHairBodygroupID = GetBodygroupIDForKnownOption(player, "Beard")
        return facialHairBodygroupID, 0
    end
    return nil, nil
end

-- Function to get the bodygroup ID for a known non-default option
function GetBodygroupIDForKnownOption(player, knownOption)
    local bodygroups = player:GetBodyGroups()
    local knownSubmodelFilename = customizationToSubmodel[knownOption]
    for _, bodygroup in ipairs(bodygroups) do
        for _, submodelFilename in ipairs(bodygroup.submodels) do
            if submodelFilename == knownSubmodelFilename then
                return bodygroup.id
            end
        end
    end
end

function PLUGIN:ApplyHairColor(client, colorChoice)
    local colorVector = hairColorMapping[colorChoice]
    if colorVector then
        client:SetPlayerColor(colorVector)
      --   print("Debug: Invalid hair color choice:", colorChoice)
    end
end
  cachedChoices = cachedChoices or {}
  function PLUGIN:ApplyBodygroupChoices(client, choices)
  if not choices then
      --   print("Debug: No choices provided for bodygroup application.")
      return
  end

  --   print("Debug: Applying bodygroup choices.")
  --   PrintTable(choices)  -- Debug: Print the choices being applied

  for _, choiceName in pairs(choices) do
      if hairColorMapping[choiceName] then
          self:ApplyHairColor(client, choiceName)
      else
          local bodygroupID, submodelIndex = GetSubgroupIndex(client, choiceName)
          if bodygroupID and submodelIndex then
              --   print("Debug: Setting bodygroup - Bodygroup ID: " .. bodygroupID .. ", Submodel Index: " .. submodelIndex)
              client:SetBodygroup(bodygroupID, submodelIndex )
              Schema:SetCharBodygroup(client, bodygroupID, submodelIndex)
              --   print("Debug: Could not find submodel for customization option: " .. choiceName)
              end
          end
      end
  end

  function PLUGIN:ToggleHelmet(client)
    local character = client:GetCharacter()

    if character then
        local helmetOn = character:GetData("helmetOn", false)
        local speciesOption = character:GetData("customizationChoices", {})[4]
        local speciesBodygroupID, _ = GetSubgroupIndex(client, speciesOption)
        local choices = character:GetData("customizationChoices", {})

        if speciesBodygroupID then
            if helmetOn then
                -- Turning helmet off
                local originalSubmodelIndex = character:GetData("originalHelmetSubmodelIndex", 0)
                client:SetBodygroup(speciesBodygroupID, originalSubmodelIndex)
                self:ApplyBodygroupChoices(client, choices)
                character:SetData("helmetOn", false)

            else
                -- Turning helmet on
                local currentSubmodelIndex = client:GetBodygroup(speciesBodygroupID)
                character:SetData("originalHelmetSubmodelIndex", currentSubmodelIndex)
                client:SetBodygroup(speciesBodygroupID, 0)
                local helmetChoices = { "Bald", "Clean", choices[3] }
                self:ApplyBodygroupChoices(client, helmetChoices)
                character:SetData("helmetOn", true)

            end
        end
    else
        client:Notify("You do not have a character.")
    end
end


function PLUGIN:EnsureCorrectHelmetBodygroups(client)
    local character = client:GetCharacter()

    if character then
        local helmetOn = character:GetData("helmetOn", false)
        local speciesOption = character:GetData("customizationChoices", {})[4]
        local speciesBodygroupID, _ = GetSubgroupIndex(client, speciesOption)
        local choices = character:GetData("customizationChoices", {})

        if speciesBodygroupID then
            if helmetOn then
                -- Helmet on
                local helmetSubmodelIndex = 0
                if client:GetBodygroup(speciesBodygroupID) ~= helmetSubmodelIndex then
                    client:SetBodygroup(speciesBodygroupID, helmetSubmodelIndex)
                    local helmetChoices = { "Bald", "Clean", choices[3] }
                    self:ApplyBodygroupChoices(client, helmetChoices)
                end
            else
                -- Helmet off
                local originalSubmodelIndex = character:GetData("originalHelmetSubmodelIndex", 0)
                if client:GetBodygroup(speciesBodygroupID) ~= originalSubmodelIndex then
                    client:SetBodygroup(speciesBodygroupID, originalSubmodelIndex)
                    self:ApplyBodygroupChoices(client, choices)
                end
            end
        end
    else
        client:Notify("You do not have a character.")
    end
end
function PLUGIN:CheckAndApplyHelmetState(client)
    if not client then
        print("Error: Client is nil in CheckAndApplyHelmetState")
        return
    end
    local character = client:GetCharacter()

    -- If the character does not exist, do nothing.
    if not character then return end

    local helmetOn = character:GetData("helmetOn", false)
    local speciesOption = character:GetData("customizationChoices", {})[4]
    local speciesBodygroupID, _ = GetSubgroupIndex(client, speciesOption)
    local choices = character:GetData("customizationChoices", {})

    -- If there's no species bodygroup ID, do nothing.
    if not speciesBodygroupID then return end



    -- Check if the current bodygroup state matches the desired state
    local helmetBodygroupIndex = helmetOn and 0 or character:GetData("originalHelmetSubmodelIndex", 0)
    if client:GetBodygroup(speciesBodygroupID) ~= helmetBodygroupIndex then
        if helmetOn then
            -- Apply the helmet bodygroup.
            client:SetBodygroup(speciesBodygroupID, helmetBodygroupIndex)
            local helmetChoices = { "Bald", "Clean", choices[3] }
            self:ApplyBodygroupChoices(client, helmetChoices)


        else
            -- Revert to the original bodygroup state.
            client:SetBodygroup(speciesBodygroupID, helmetBodygroupIndex)
            self:ApplyBodygroupChoices(client, choices)
        end
    end
end

function PLUGIN:PostPlayerLoadout(client)
    timer.Simple(1, function()
        if IsValid(client) and client:GetCharacter() then
            self:CheckAndApplyHelmetState(client)
            -- This ensures that faction data is accessed after a slight delay, potentially resolving timing issues.
        end
    end)
end


ix.command.Add("helmet", {
    description = "Toggle your helmet on or off.",
    OnRun = function(self, client)
        local character = client:GetCharacter()
        if not character then
            client:Notify("You do not have a character.")
            return
        end

        local helmetOn = character:GetData("helmetOn", false)
        local actionText = helmetOn and "Removing Helmet..." or "Putting on Helmet..."

        -- Set an action with a duration
        client:SetAction(actionText, 0.5, function()
            if IsValid(client) then
                PLUGIN:ToggleHelmet(client) -- Toggle helmet state
                -- Send a /me chat message
                local actionMsg = helmetOn and "removes their helmet." or "puts on their helmet."
                ix.chat.Send(client, "me", actionMsg, false)
            end
        end)
    end
})
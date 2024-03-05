PLUGIN = PLUGIN or {}
PLUGIN.name = "Character Creation - Description System"
PLUGIN.author = "Theodor"
PLUGIN.desc = "Adds a character creation system."







-- This code is madness. Please don't look at it, or use it for that matter. It's a mess. 
-- However, it works. I'm not proud of it. But it works.
-- Very unoptimized, most likely insecure as well. But should serve as an example for anyone attempting anything similar. Does include editing the bodygroups of the dmodel of the playermodel through the registery of the char vars. As I refuse to edit the derma for the character creation panel.
-- A lot of depracated code. As I intended to have it set a players description at the same time, based on their chosen looks which did work. However, there where several issues with it, especially when players switched factions. So I removed it.
-- However, shouldn't be to hard to reimplement if you would want to do that for some reason.
-- The logic behind the way bodygroups are being handled, especially in this very unoptimised way. Is due to the author of the model pack that was unfortunely chosen by my community, doesn't have a "standardised" way of handling bodygroups.
-- As each "group" of models inside the pack has different indexes for the same bodygroup. Which leads to this mess of having to print and compare bodygroup names to figure out which index to use. 
-- There's probably a way better way to do this, but that is beyond my capabilities.



if CLIENT then
  -- Define the bodygroup indexes globally
  bodygroupIndexes = {
      hair = 3,          -- Update these indexes as appropriate for your model
      facialHair = 2,
      species = 0
  }
end

if SERVER then
    local defaultPlayerChoices = {
        [1] = "Bald",
        [2] = "Clean",
        [3] = "Black",
        [4] = "Human"
    }
    util.AddNetworkString("SendChoiceToServer")

    playerChoices = playerChoices or {}

    -- Step 2 & 3: Inside the net.Receive function
    net.Receive("SendChoiceToServer", function(len, client)
        local choice = net.ReadString()
        local id = net.ReadUInt(8)
    
        -- Initialize defaultPlayerChoices if not already done
    
        -- Make sure 'client' is a valid player and not nil
        if IsValid(client) then
            if not playerChoices[client] then
                playerChoices[client] = table.Copy(defaultPlayerChoices)
            end
    
            playerChoices[client][id] = choice
        else
            print("Error: Invalid client in net.Receive")
        end
    end)
    local descriptiveMapping = {
        Hair = {
            ["Mohawk"] = "a striking mohawk atop their head",
            ["Ponytail"] = "hair tied back into a neat ponytail",
            ["Bald"] = "a completely bald head that shines in the light",
            ["Side"] = "hair parted to the side for a classic look",
            ["Balding"] = "hints of a receding hairline",
            ["Straight"] = "straight hair that falls neatly around their face"
        },
        FacialHair = {
            ["Clean"] = "and a clean-shaven face",
            ["Side Burns"] = "complemented by pronounced side burns",
            ["Beard"] = "covered by a full, thick beard",
            ["Moustache"] = "adorned with a meticulously groomed moustache",
            ["Goatee"] = "highlighted by a sharply trimmed goatee"
        },
        Species = {
            ["Human"] = "the features of a Human",
            ["Dathomirian"] = "the distinct traits of a Dathomirian",
            ["Mirialan"] = "the traditional tattoos of a Mirialan",
            ["Chiss"] = "the rare, blue-toned skin of a Chiss"
        }
    }

    function PLUGIN:OnCharacterCreated(client, character)
        if not character then
            print("Error: Character is nil.")
            return
        end
    
        local choicesToSave = playerChoices[client]
    
        -- Check if choicesToSave is nil or empty, then fallback to defaultPlayerChoices
        if not choicesToSave or not next(choicesToSave) then
            choicesToSave = defaultPlayerChoices
        end
    
        character:SetData("customizationChoices", choicesToSave)
        character:SetData("helmetOn", false)
    

    
        -- Clear the choices for this client, We do this to ensure that the next character created will have correct choices.
        playerChoices[client] = nil
    
    end

  local hairColorMapping = {
      ["Blonde"] = Vector(1, 0.85, 0.55), -- why are colours vectors. I despise vectors.
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

    local function IsDefaultHumanModel(player)
        local modelName = player:GetModel():lower()
        return string.find(modelName, "recruit") or string.find(modelName, "officer")
    end

  local function GetSubgroupIndex(player, customizationOption)
      local bodygroups = player:GetBodyGroups()
      for _, bodygroup in ipairs(bodygroups) do
          for submodelIndex, submodelFilename in ipairs(bodygroup.submodels) do
              if submodelFilename == customizationToSubmodel[customizationOption] then
                  return bodygroup.id, submodelIndex
              end
          end
      end
      if customizationOption == "Human" and not IsDefaultHumanModel(player) then
        return GetBodygroupIDForKnownOption(player, "Human"), 0
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


    function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
        if not IsValid(client) or not character then
            return
        end
    
        -- Retrieve customization choices for the loaded character.
        local choices = character:GetData("customizationChoices", defaultPlayerChoices)
        cachedChoices[client:SteamID()] = choices
    
        -- Immediately apply bodygroup choices to ensure the character model is updated as soon as possible.
        self:ApplyBodygroupChoices(client, choices)
    
        -- Apply additional logic such as helmet state adjustments after a slight delay to ensure all character data is fully loaded.
        timer.Simple(1, function()
            if IsValid(client) then
                self:EnsureCorrectHelmetBodygroups(client)
            end
        end)
    end


end


-- I should really use helper functions to minimise code repetition. But that means effort. And I'm not about that life.

ix.char.RegisterVar("appearance", {
  fieldType = ix.type.string,
  default = "DefaultOption",
  OnDisplay = function(self, container, payload)
      -- Define the height for the dropdowns
      local dropdownHeight = 30

      -- Main horizontal panel
      local hPanel = container:Add("DPanel")
      hPanel:Dock(TOP)
      hPanel:SetHeight(dropdownHeight + 10) -- Adjust height based on the dropdown height + margin
      hPanel:DockMargin(0, 5, 0, 5)
      hPanel.Paint = nil -- No custom painting necessary

      -- Define consistent spacing and sizing
      local labelWidth = 100
      local dropdownSpacing = 10

      -- Adjust dropdownWidth to fit four dropdowns within the container
      local availableWidth = container:GetWide() - (labelWidth * 4) - (dropdownSpacing * 5)
      local dropdownWidth = availableWidth / 4

      -- Dropdown 1 - Hair
      local labelHair = hPanel:Add("DLabel")
      labelHair:SetText("Hair:")
      labelHair:Dock(LEFT)
      labelHair:SetSize(labelWidth, dropdownHeight)
      labelHair:SetContentAlignment(5)

      local dropdownHair = hPanel:Add("DComboBox")
      dropdownHair:SetSize(dropdownWidth, dropdownHeight)
      dropdownHair:Dock(LEFT)
      dropdownHair:DockMargin(dropdownSpacing, 0, dropdownSpacing, 0)
      dropdownHair:SetValue("Select Hair")
      -- Add hair options
      dropdownHair:AddChoice("Mohawk") -- option 3
      dropdownHair:AddChoice("Ponytail") -- option 4
      dropdownHair:AddChoice("Bald") -- option 0
      dropdownHair:AddChoice("Side") -- option 2
      dropdownHair:AddChoice("Balding") -- option 6
      dropdownHair:AddChoice("Straight") -- option 1

      -- Dropdown 2 - Facial Hair
      local labelFacialHair = hPanel:Add("DLabel")
      labelFacialHair:SetText("Facial Hair:")
      labelFacialHair:Dock(LEFT)
      labelFacialHair:SetSize(labelWidth, dropdownHeight)
      labelFacialHair:SetContentAlignment(5)

      local dropdownFacialHair = hPanel:Add("DComboBox")
      dropdownFacialHair:SetSize(dropdownWidth, dropdownHeight)
      dropdownFacialHair:Dock(LEFT)
      dropdownFacialHair:DockMargin(dropdownSpacing, 0, dropdownSpacing, 0)
      dropdownFacialHair:SetValue("Select Facial Hair")
      -- Add facial hair options
      dropdownFacialHair:AddChoice("Clean") -- option 0
      dropdownFacialHair:AddChoice("Side Burns") -- option 1
      dropdownFacialHair:AddChoice("Beard") -- option 2
      dropdownFacialHair:AddChoice("Moustache") -- option 3
      dropdownFacialHair:AddChoice("Goatee") -- option 4

      -- Dropdown 3 - Hair Color
      local labelHairColor = hPanel:Add("DLabel")
      labelHairColor:SetText("Hair Color:")
      labelHairColor:Dock(LEFT)
      labelHairColor:SetSize(labelWidth, dropdownHeight)
      labelHairColor:SetContentAlignment(5)

      local dropdownHairColor = hPanel:Add("DComboBox")
      dropdownHairColor:SetSize(dropdownWidth, dropdownHeight)
      dropdownHairColor:Dock(LEFT)
      dropdownHairColor:DockMargin(dropdownSpacing, 0, dropdownSpacing, 0)
      dropdownHairColor:SetValue("Select Hair Color")
      -- Add hair color options
      dropdownHairColor:AddChoice("Blonde")
      dropdownHairColor:AddChoice("Brown")
      dropdownHairColor:AddChoice("Black")
      dropdownHairColor:AddChoice("Grey")
      dropdownHairColor:AddChoice("Red")
      dropdownHairColor:AddChoice("Orange")
      dropdownHairColor:AddChoice("Yellow")

      -- Dropdown 4 - Species
      local labelSpecies = hPanel:Add("DLabel")
      labelSpecies:SetText("Species:")
      labelSpecies:Dock(LEFT)
      labelSpecies:SetSize(labelWidth, dropdownHeight)
      labelSpecies:SetContentAlignment(5)

      local dropdownSpecies = hPanel:Add("DComboBox")
      dropdownSpecies:SetSize(dropdownWidth, dropdownHeight)
      dropdownSpecies:Dock(LEFT)
      dropdownSpecies:DockMargin(dropdownSpacing, 0, 0, 0) -- No right margin on the last dropdown
      dropdownSpecies:SetValue("Select Species")
      -- Add species options
      dropdownSpecies:AddChoice("Human") -- option 1
      dropdownSpecies:AddChoice("Dathomirian") -- option 2
      dropdownSpecies:AddChoice("Mirialan") -- option 4
      dropdownSpecies:AddChoice("Chiss") -- option 5
local function UpdateAndSendChoices()
    local choices = {
        {"Hair", dropdownHair:GetSelected() or "Bald", 1},
        {"FacialHair", dropdownFacialHair:GetSelected() or "Clean", 2},
        {"HairColor", dropdownHairColor:GetSelected() or "Black", 3},
        {"Species", dropdownSpecies:GetSelected() or "Human", 4}
    }


    for _, choice in ipairs(choices) do
        local choiceName, selectedOption, id = unpack(choice)

        -- Send the choice to the server
        net.Start("SendChoiceToServer")
        net.WriteString(selectedOption)
        net.WriteUInt(id, 8)
        net.SendToServer()

    end

end



      -- This is all very wrong to do and is very jank. I'm sorry.
      local bodygroupMapping = {
        -- Hair options
        ["Mohawk"] = 3, ["Ponytail"] = 4, ["Bald"] = -1, ["Side"] = 2, ["Balding"] = 0, ["Straight"] = 1,
        -- Facial hair options
        ["Clean"] = 0, ["Side Burns"] = 1, ["Beard"] = 2, ["Moustache"] = 3, ["Goatee"] = 4,
        -- Species options (modify as per your game's logic)
        ["Human"] = 0, ["Dathomirian"] = 1, ["Mirialan"] = 3, ["Chiss"] = 4
    }
    -- Define bodygroup indexes for each category
    local bodygroupIndexes = {
        hair = 3,          -- assuming hair options use bodygroup index 3
        facialHair = 4,    -- assuming facial hair options use bodygroup index 2
        species = 2        -- assuming species options use bodygroup index 0
    }
-- Dropdown for Hair
function dropdownHair:OnSelect(index, value)
    UpdateAndSendChoices()
    local parentPanel = self:GetParent():GetParent():GetParent()
    if IsValid(parentPanel) then
        local modelPanel = parentPanel:GetChild(1):GetChild(1) -- Adjust according to your UI structure

        if IsValid(modelPanel) and modelPanel.GetEntity then
            local modelEntity = modelPanel:GetEntity()

            if IsValid(modelEntity) then
                -- Use the hair choice to set the appropriate bodygroup
                local bodygroupValue = bodygroupMapping[value] -- Assuming 'bodygroupMapping' is defined as mentioned earlier
                if bodygroupValue then
                    modelEntity:SetBodygroup(bodygroupIndexes.hair, bodygroupValue+1)
                end
            else
                print("Error: modelEntity is not valid.")
            end
        else
            print("Error: modelPanel is not valid or does not have GetEntity method.")
        end
    else
        print("Error: parentPanel is not valid.")
    end
    local parentPanel2 = hPanel:GetParent():GetParent():GetParent()
    if IsValid(parentPanel2) then
        -- Debug output to see the structure of the parent panel's children
        -- print("Children of parentPanel2:")
        -- PrintTable(parentPanel2:GetChildren())
        -- Attempt to get the model panel based on the known hierarchy
        -- Adjust the indices according to the actual structure
        local modelPanel2 = parentPanel2:GetChild(2):GetChild(1):GetChild(1)
        -- Debug output to check if the modelPanel is valid and what it is
        -- print("modelPanel:", modelPanel2)

        -- Check if the modelPanel is valid and has the GetEntity method
        if IsValid(modelPanel2) and modelPanel2.GetEntity then
            local modelEntity2 = modelPanel2:GetEntity()
            local bodygroupValue = bodygroupMapping[value] -- Assuming 'bodygroupMapping' is defined as mentioned earlier
            if bodygroupValue then
                modelEntity2:SetBodygroup(bodygroupIndexes.hair, bodygroupValue+1)
            end
        else
            print("Error: modelPanel2 is not valid or does not have GetEntity method.")
        end
    else
        print("Error: parentPanel2 is not valid.")
    end
end

-- Dropdown for Facial Hair
function dropdownFacialHair:OnSelect(index, value)
    UpdateAndSendChoices()

    local parentPanel = self:GetParent():GetParent():GetParent()
    if IsValid(parentPanel) then
        local modelPanel = parentPanel:GetChild(1):GetChild(1) -- Adjust as per your UI hierarchy

        if IsValid(modelPanel) and modelPanel.GetEntity then
            local modelEntity = modelPanel:GetEntity()

            if IsValid(modelEntity) then
                local bodygroupValue = bodygroupMapping[value] 
                if bodygroupValue then
                    modelEntity:SetBodygroup(bodygroupIndexes.facialHair, bodygroupValue)
                end
            else
                print("Error: modelEntity is not valid.")
            end
        else
            print("Error: modelPanel is not valid or does not have GetEntity method.")
        end
    else
        print("Error: parentPanel is not valid.")
    end
    local parentPanel2 = hPanel:GetParent():GetParent():GetParent()
    if IsValid(parentPanel2) then
        -- Debug output to see the structure of the parent panel's children
        -- print("Children of parentPanel2:")
        -- PrintTable(parentPanel2:GetChildren())
        -- Attempt to get the model panel based on the known hierarchy
        -- Adjust the indices according to the actual structure
        local modelPanel2 = parentPanel2:GetChild(2):GetChild(1):GetChild(1)
        -- Debug output to check if the modelPanel is valid and what it is
        -- print("modelPanel:", modelPanel2)

        -- Check if the modelPanel is valid and has the GetEntity method
        if IsValid(modelPanel2) and modelPanel2.GetEntity then
            local modelEntity2 = modelPanel2:GetEntity()
            local bodygroupValue = bodygroupMapping[value] -- Assuming 'bodygroupMapping' is defined as mentioned earlier
            if bodygroupValue then
                modelEntity2:SetBodygroup(bodygroupIndexes.facialHair, bodygroupValue)
            end
        else
            print("Error: modelPanel2 is not valid or does not have GetEntity method.")
        end
    else
        print("Error: parentPanel2 is not valid.")
    end
end

function dropdownHairColor:OnSelect(index, value)
    UpdateAndSendChoices()
local hairColorToRGB = {
    ["Blonde"] = Vector(1, 0.85, 0.55), -- Example values, adjust as needed
    ["Brown"] = Vector(0.65, 0.33, 0.15),
    ["Black"] = Vector(0.15, 0.15, 0.15),
    ["Grey"] = Vector(0.75, 0.75, 0.75),
    ["Red"] = Vector(1, 0, 0),
    ["Orange"] = Vector(1, 0.65, 0),
    ["Yellow"] = Vector(1, 1, 0)
}
    local parentPanel = self:GetParent():GetParent():GetParent()
    if IsValid(parentPanel) then
        local modelPanel = parentPanel:GetChild(1):GetChild(1) -- Adjust as per your UI hierarchy

        if IsValid(modelPanel) and modelPanel.GetEntity then
            local modelEntity = modelPanel:GetEntity()

            if IsValid(modelEntity) then
                local colorVector = hairColorToRGB[value]
                if colorVector then
                    modelEntity.GetPlayerColor = function() return colorVector end
                end
            else
                print("Error: modelEntity is not valid.")
            end
        else
            print("Error: modelPanel is not valid or does not have GetEntity method.")
        end
    else
        print("Error: parentPanel is not valid.")
    end
    local parentPanel2 = hPanel:GetParent():GetParent():GetParent()
    if IsValid(parentPanel2) then
        -- Debug output to see the structure of the parent panel's children
        -- print("Children of parentPanel2:")
        -- PrintTable(parentPanel2:GetChildren())
        -- Attempt to get the model panel based on the known hierarchy
        -- Adjust the indices according to the actual structure
        local modelPanel2 = parentPanel2:GetChild(2):GetChild(1):GetChild(1)
        -- Debug output to check if the modelPanel is valid and what it is
        -- print("modelPanel:", modelPanel2)

        -- Check if the modelPanel is valid and has the GetEntity method
        if IsValid(modelPanel2) and modelPanel2.GetEntity then
            local modelEntity2 = modelPanel2:GetEntity()
            local colorVector = hairColorToRGB[value]
            if colorVector then
                modelEntity2.GetPlayerColor = function() return colorVector end
            end
        else
            print("Error: modelPanel2 is not valid or does not have GetEntity method.")
        end
    else
        print("Error: parentPanel2 is not valid.")
    end
end

-- Dropdown for Species
function dropdownSpecies:OnSelect(index, value)
    UpdateAndSendChoices()


    local parentPanel = self:GetParent():GetParent():GetParent()
    if IsValid(parentPanel) then
        local modelPanel = parentPanel:GetChild(1):GetChild(1) -- Adjust as per your UI hierarchy

        if IsValid(modelPanel) and modelPanel.GetEntity then
            local modelEntity = modelPanel:GetEntity()

            if IsValid(modelEntity) then
                local bodygroupValue = bodygroupMapping[value]
                if bodygroupValue then
                    modelEntity:SetBodygroup(bodygroupIndexes.species, bodygroupValue)
                end
            else
                print("Error: modelEntity is not valid.")
            end
        else
            print("Error: modelPanel is not valid or does not have GetEntity method.")
        end
    else
        print("Error: parentPanel is not valid.")
    end
    local parentPanel2 = hPanel:GetParent():GetParent():GetParent()
    if IsValid(parentPanel2) then
        -- Debug output to see the structure of the parent panel's children
        -- print("Children of parentPanel2:")
        -- PrintTable(parentPanel2:GetChildren())
        -- Attempt to get the model panel based on the known hierarchy
        -- Adjust the indices according to the actual structure
        local modelPanel2 = parentPanel2:GetChild(2):GetChild(1):GetChild(1)
        -- Debug output to check if the modelPanel is valid and what it is
        -- print("modelPanel:", modelPanel2)

        -- Check if the modelPanel is valid and has the GetEntity method
        if IsValid(modelPanel2) and modelPanel2.GetEntity then
            local modelEntity2 = modelPanel2:GetEntity()
            local bodygroupValue = bodygroupMapping[value] -- Assuming 'bodygroupMapping' is defined as mentioned earlier
            if bodygroupValue then
                modelEntity2:SetBodygroup(bodygroupIndexes.species, bodygroupValue)
            end
        else
            print("Error: modelPanel2 is not valid or does not have GetEntity method.")
        end
    else
        print("Error: parentPanel2 is not valid.")
    end
end


        return hPanel
end
  -- Other necessary functions like OnValidate, etc.
})
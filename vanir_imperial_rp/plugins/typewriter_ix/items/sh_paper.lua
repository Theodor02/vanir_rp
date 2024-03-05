ITEM.name = "Data Pad"
ITEM.description = "A sleek Imperial datapad, essential for secure communication and data storage,\n designed for efficiency and authority in the Galactic Empire."
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.View = {
	name = "View",
	OnClick = function(item)
		MascoTypeWriter.Document = vgui.Create("ixDocument")
		MascoTypeWriter.Document:SetDocument(item)
	end,
	OnRun = function(item) return false end,
	OnCanRun = function(item)
		if IsValid(item.entity) or item:GetData("DocumentBody") == nil then
            return false
        end
	end,
}

function ITEM:GetName()
	return self:GetData("DocumentName", self.name)
end

function ITEM:GetDescription()
	return Format(
		"%s %s %s",
		self.description,
		self:GetData("DocumentBody") and "This datapad has something written on it." or "This datapad is blank.",
		LocalPlayer():IsAdmin() and ("This datapad was created by "..self:GetData("Creator", "N/A")) or ""
	)
end
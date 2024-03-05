ITEM.name = "Imperial cipher machine"
ITEM.description = "An Imperial cipher machine, outfitted with a comprehensive key array for the input of Galactic Standard alphabetical characters,\n numerals, and critical Imperial symbols. Each key is meticulously designed to transfer the corresponding character directly onto datapads, employing a sophisticated encoding mechanism."
ITEM.model = "models/lordtrilobite/starwars/isd/imp_console_medium02.mdl"
ITEM.width = 4
ITEM.height = 4
ITEM.category = "Documents"
ITEM.price = 250

ITEM.functions.Use = {
	name = "Use",
	OnClick = function(item)
		vgui.Create("ixTypewriter")
	end,
	OnRun = function(item)
		return false
	end,
	OnCanRun = function(item)
		return IsValid(item.entity)
	end
}
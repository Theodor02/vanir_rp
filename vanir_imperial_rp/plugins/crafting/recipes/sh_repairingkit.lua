local RECIPE = {}

local itemData = ix.item.Get("repairkit")

RECIPE.uniqueID = "repairingkit"
RECIPE.name = itemData.name
RECIPE.category = "Repairing"
RECIPE.model = itemData.model
RECIPE.description = itemData.description
RECIPE.requirements = {
    ["metal_plate"] = 8,
    ["gear"] = 6
}
RECIPE.result = {
    ["repairkit"] = 1
}

ix.crafting:RegisterRecipe(RECIPE)
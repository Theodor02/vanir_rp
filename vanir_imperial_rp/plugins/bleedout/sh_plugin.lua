
local PLUGIN = PLUGIN

PLUGIN.name = "Bleed out"
PLUGIN.author = "Ron"
PLUGIN.description = "Adds a bleed out system. Players will not enter the bleed out state if they take too much damage at once, and the bleed out state timer is configurable."
PLUGIN.license = [[
The MIT License (MIT)
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
No attribution is required in any copies or derivatives of this work, however, please feel free to give credit where it’s due!
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.]]

ix.char.RegisterVar("Bleedout", {
    field = "bleedout_status",
    fieldType = ix.type.boolean,
    default = false,
    bNoDisplay = true,
})

ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_configs.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("sv_hooks.lua")

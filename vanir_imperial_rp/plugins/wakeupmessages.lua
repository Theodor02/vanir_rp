local PLUGIN = PLUGIN

PLUGIN.name = "Wake Up Messages"
PLUGIN.description = "Adds a random message when a player loads their character - Edited by Theodor."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2024 Riggs Mackay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]


local mapSpecificWakeUpMessages = {
    ["rp_stardestroyer_v2_7_inf"] = {
        "awakens in the cold, metallic interior of the Star Destroyer, a reminder of their enduring duty to the remnants of a once-great Empire.",
        "rises from their bunk in the barracks, the distant orders echoing through the halls a testament to their continued resolve.",
        "opens their eyes to the dimly lit corridors of their vessel, a sanctuary in a galaxy that has moved on from Imperial rule.",
        "stirs from their sleep, surrounded by the aura of authority and discipline that persists in this fragment of the Empire.",
        "comes to life, greeted by the efficient design of the Star Destroyer, a legacy of the Empire's former might.",
        "leaves their dreams behind, the imposing structure of the Star Destroyer a symbol of their commitment to the Remnant's cause.",
        "gathers themselves in the spartan quarters, determined to uphold the values of the Empire in a galaxy that has changed.",
        "shakes off the remnants of sleep, the ordered routine of the Star Destroyer a comfort in uncertain times.",
        "emerges from a restful slumber, the starry expanse outside a reminder of the vast challenges that lie ahead for the Remnant.",
        "prepares for the day ahead, surrounded by the sounds of an Imperial fleet that endures in spirit, if not in name.",
        "stirs from their bunk, haunted by dreams of past battles and the vastness of space that once belonged to the Empire.",
        "awakens, clinging to the dream of commanding their own vessel in an Imperial fleet that no longer rules the stars.",
        "rises, their sleep filled with visions of TIE fighters that once soared in the name of a now-dissolved Empire.",
        "blinks awake, the dream of walking the corridors of the Death Star a distant echo of a fallen regime.",
        "slowly sits up, grasping at the fading dream of a galaxy united under the rule they still fight for.",
        "awakens from dreams of past glory, ready to forge a new path for the remnants of an Empire they still serve.",
        "comes to consciousness, their dream of Imperial commendations now a drive to prove their worth in a fragmented galaxy.",
        "opens their eyes, leaving behind a dream of patrolling the outer rim for an Empire that now exists in memories.",
        "awakens from restless sleep, filled with visions of skirmishes that continue to define their struggle for survival.",
        "leaves their bunk, the echo of a dream about navigating asteroid fields in an Imperial cruiser a symbol of their enduring journey.",
        "rises from a deep sleep, filled with dreams of commanding legions, a persistent ambition in the new reality of the Remnant.",
        "wakes up, feeling the remnants of a dream where they battled the Rebellion, a fight that now belongs to history.",
        "gets up, their dream of standing on the bridge of a mighty vessel a motivation to keep the spirit of the Empire alive.",
        "gazes at the bulkhead above, their mind replaying the glory days of the Empire as they prepare for another day in the Remnant.",
        "sits up, their heart heavy with the memories of the Empire's grandeur, yet hopeful for the Remnant's future.",
        "wakes to the subtle vibrations of the Star Destroyer, a nostalgic reminder of the Empire's once unshakable foundation.",
        "rubs their eyes, pondering the weight of carrying forward the legacy of a once vast and powerful Empire.",
        "awakens amidst the remnants of a dream, where Star Destroyers ruled the skies, unchallenged and proud.",
        "leaves their cot, stepping into the role of a guardian of the Empire's remnants, a role unasked for, yet embraced with honor.",
        "emerges from the shadows of sleep, their spirit undiminished by the Empire's fall, fueled by a commitment to its remnants.",
        "stretches, feeling a tinge of sadness for the Empire lost, but a surge of determination for the cause that remains.",
        "stands, their resolve hardened like the steel corridors around them, ready to uphold the remnants of a once-great civilization.",
        "takes a deep breath, the scent of the Star Destroyer a constant reminder of what was lost, and what must be preserved.",
        "awakens with a start, the echoes of the Empire's might still ringing in their ears, a sound they chase in waking hours.",
        "contemplates the vastness of space from their viewport, a stark contrast to the confined but familiar corridors of their current refuge.",
        "awakens to a reality far removed from the Empire's zenith, yet finds comfort in the enduring symbols of its power.",
        "rises with a sense of purpose, a lone ember of the Empire in a galaxy that has moved on, yet not extinguished.",
        "wakes, their dreams of imperial parades and grand speeches a stark contrast to the quiet, disciplined life aboard the Remnant vessel.",
        "stares at the ceiling, their thoughts adrift between the Empire's storied past and the Remnant's uncertain future.",
        "awakens, momentarily disoriented, as if expecting to find themselves in the bustling corridors of the Empire at its peak.",
        "awakens with the fading echo of blaster fire in their ears, a vivid reminder of battles long past.",
        "stirs from sleep, haunted by memories of a skirmish that left more scars on their psyche than on their body.",
        "rises, their mind replaying the disciplined routines and camaraderie of the Imperial Academy.",
        "opens their eyes, momentarily lost in memories of rigorous training exercises that shaped them into a soldier of the Empire.",
        "wakes up, recalling a particular harsh lesson learned in the heat of battle, a lesson that forever changed their approach to war.",
        "lays in bed a moment longer, reminiscing about their first proud moments in uniform, now a bittersweet memory.",
        "gets up, their heart heavy with the loss of comrades in battles that now seem distant, yet ever-present in their mind.",
        "awakens from a dream of marching alongside their battalion, a unified force under the Empire's banner.",
        "sits up, troubled by a recurring nightmare of a battle turned sour, where every decision led to regret.",
        "slowly rises, the weight of past decisions in times of war lingering heavily upon their soul.",
        "wakes with a start, a sudden noise triggering a flash of memory from a desperate fight on a forgotten planet.",
        "remembers, in the quiet of the morning, the faces of friends and foes alike, met during the tumult of war.",
        "reflects on their journey from a young cadet full of ideals to a veteran soldier shaped by the realities of conflict.",
        "feels a pang of nostalgia for the rigorous but simpler days of training, a stark contrast to the complexities of their current life.",
        "awakens, as if from a trance, the adrenaline of a fierce space battle still coursing faintly through their veins.",
        "rises with a sense of loss, mourning the youthful innocence left behind in the unforgiving trials of war.",
    },
    ["gm_construct"] = {
        "rises amidst the creativity and chaos of the construct environment.",
        "blinks awake to the sight of the sandbox world's endless possibilities.",
        -- [Add more gm_construct specific messages]
    },
    -- Add more maps and their specific messages here
    ["default"] = {
        "awakens quickly, their senses immediately attuned to the unfamiliar environment of their current operation.",
        "rises with a sense of alertness, ready to adapt to the challenges of a new terrain.",
        "opens their eyes, instantly scanning their surroundings, a habit formed from countless operations in unknown lands.",
        "stirs to wakefulness, their mind already strategizing for the day's mission in this unfamiliar setting.",
        "gets up, feeling the thrill of an operation in a new location, the uncertainty adding an edge to their movements.",
        "emerges from sleep with a soldier's discipline, mentally preparing for the unexpected in a foreign environment.",
        "leaves the comfort of rest behind, their training kicking in as they prepare to face whatever this new map holds.",
        "awakens in a makeshift camp, the reality of operations in unknown territories setting the tone for the day.",
        "rises, their senses heightened by the unfamiliar sounds and sights of their current operation zone.",
        "wakes up to the sound of distant activity, a reminder of the ever-changing nature of their missions."
    },
}

function PLUGIN:PlayerLoadedCharacter(ply, char, oldChar)
    if not IsValid(ply) or not char then
        return
    end

    local currentMap = game.GetMap() -- Get the current map name
    local messages = mapSpecificWakeUpMessages[currentMap] or mapSpecificWakeUpMessages["default"]
    local message = messages[math.random(#messages)]

    -- Send the message only to the player who loaded the character
    ix.chat.Send(ply, "me", message, false, {ply})
end
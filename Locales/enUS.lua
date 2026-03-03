local L = LibStub("AceLocale-3.0"):NewLocale("MapHighlights", "enUS", true)

L["enable"] = "Enable"
L["scale"] = "Scale"
L["alpha"] = "Alpha"
L["textFont"] = "Text Font"
L["textSize"] = "Text Size"
L["show"] = "Show"
L["enableColor"] = "Enable Color"
L["text"] = "Text"
L["highlight"] = "Highlight"
L["animation"] = "Animation"
L["color"] = "Color"
L["top"] = "Top"
L["bottom"] = "Bottom"
L["left"] = "Left"
L["right"] = "Right"
L["center"] = "Center"
L["offset"] = "Offset"
L["glow"] = "Glow"
L["openOptions"] = "Open Options"

-- Main menu
L["tab_settings"] = "Settings"
L["tab_mapHighlights"] = "Map Highlights"
L["tab_other"] = "Other Options"

-- map highlights
--
-- global settings
L["header_globalHighlights"] = "Global Highlight Settings"
L["descr_globalHighlights"] = "These settings apply to all Map Highlights.|nThey can be overriden by each Highlight's own settings."
L["dropdown_textOutline"] = "Text Outline"
L["outlineNone"] = "None"
L["outlineThin"] = "Thin"
L["outlineThick"] = "Thick"
--
-- individual settings
L["header_hlSelection"] = "Individual Highlight Settings"
L["header_animation"] = "Animation"
L["descr_anim"] = "Click the Preview to trigger the animation"
L["dropdown_animPlayback"] = "When to play animation"
L["animPlayback_onBoth"] = "On map open & on click"
L["animPlayback_onMap"] = "Only on map open"
L["animPlayback_onClick"] = "Only on click"
L["animPlayback_loop"] = "Loop"

L["dropdown_animStyle"] = "Animation Style"
L["animStyle1"] = "Shrink & Fade"
L["animStyle2"] = "Grow & Fade"
L["animStyle3"] = "Pulse"
L["animStyle4"] = "Blink"

L["iconScale"] = "Highlight Scale"
L["dropdown_hlStyle"] = "Highlight Style"
L["hlStyle_glowingFG"] = "Glowing Foreground"
L["hlStyle_solidBG"] = "Solid Background"
L["hlStyle_glowingBG"] = "Glowing Background"

L["dropdown_hlTexture"] = "Highlight Texture"
L["hlTexture_1"] = "Same as icon"
L["hlTexture_2"] = "Soft Circle"
L["hlTexture_3"] = "Solid Yellow Circle"
L["hlTexture_4"] = "Solid Brown Circle"

L["textScale"] = "Text Scale"
L["textPosition"] = "Text Position"
L["textCustom"] = "Customize Font"
L["textLevel"] = "Text Layer"
L["descr_textLevel"] = "Higher values allow the text to cover other icons.|n|n2200 - 2800 is pretty good.|nValues above 2800 will overlap the player arrow."

-- highlight group names
L["Navigation"] = true
L["Locations"] = true
L["Objectives"] = true
L["Other"] = true
-- highlight names
L["Waypoint"] = true
L["Flightmaster"] = true
L["Flightmaster (undiscovered)"] = true
L["Dungeon"] = true
L["Raid"] = true
L["Delve"] = true
L["Bountiful Delve"] = true
L["Quest Hub"] = true
L["Zone Portal"] = true
L["Cave Exit (Up)"] = true
L["Cave Exit (Down)"] = true
L["Rare Encounter"] = true
L["WQ Special Assignment"] = true
L["S.C.R.A.P. Heap (active)"] = true
L["S.C.R.A.P. Heap (inactive)"] = true
L["Treasure Goblin Spawn"] = true

L["checkbox_playerLocation"] = "Highlight Player Location"
L["descr_playerLocation"] = "Highlights your Player Location arrow when opening the map and on mouse clicks."
L["checkbox_battlefieldMap"] = "Include BattlefieldMap"
L["descr_battlefieldMap"] = "Highlights will be displayed on the BattlefieldMap in addition to the WorldMap."

L["chatCommands"] = "Chat Commands:"
L["preview"] = "Preview"
L["disabled"] = "Disabled"

L["header_playerLocation"] = "Highlight Player Location"
L["header_playerDirection"] = "Player Direction Line"
L["header_misc"] = "Miscellaneous"
L["descr_playerDirection"] = "Draws a line from the player in the direction the player is facing."
L["colorStart"] = "Start"
L["colorEnd"] = "End"
L["length"] = "Length"
L["thickness"] = "Thickness"

L["Custom"] = "Custom" -- new highlights that the user added
L["new"] = "New" -- add new custom highlight
L["rename"] = "Rename" -- rename custom highlight
L["delete"] = "Delete" -- delete custom highlight
L["copy"] = "Copy Settings from ..." -- copy settings from one highlight to the current one




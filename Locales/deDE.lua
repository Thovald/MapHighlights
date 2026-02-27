local L = LibStub("AceLocale-3.0"):NewLocale("MapHighlights", "deDE")
if not L then return end

L["enable"] = "Aktivieren"
L["scale"] = "Skalierung"
L["alpha"] = "Alpha"
L["textFont"] = "Text Font"
L["textSize"] = "Text Größe"
L["show"] = "Zeigen"
L["enableColor"] = "Benutze Farbe"
L["text"] = "Text"
L["highlight"] = "Highlight"
L["animation"] = "Animation"
L["color"] = "Farbe"
L["top"] = "Oben"
L["bottom"] = "Unten"
L["left"] = "Links"
L["right"] = "Rechts"
L["center"] = "Zentriert"
L["offset"] = "Versatz"
L["glow"] = "Leuchten"
L["openOptions"] = "Öffne Options Menü"

-- Main menu
L["tab_settings"] = "Einstellungen"
L["tab_mapHighlights"] = "Map Highlights"
L["tab_other"] = "Andere Optionen"

-- map highlights
--
-- global settings
L["header_globalHighlights"] = "Globale Highlight Einstellungen"
L["descr_globalHighlights"] = "Diese Einstellungen werden auf alle Highlights angewandt.|nSie können mit den individuellen Einstellungen überschrieben werden."
L["dropdown_textOutline"] = "Text Umriss"
L["outlineNone"] = "Kein"
L["outlineThin"] = "Dünn"
L["outlineThick"] = "Dick"
--
-- individual settings
L["header_hlSelection"] = "Individuelle Highlight Einstellungen"
L["header_animation"] = "Animation"
L["descr_anim"] = "Klicke die Vorschau um Animationen abzuspielen"
L["dropdown_animPlayback"] = "Wann die Animation spielen soll"
L["animPlayback_onBoth"] = "Beim Öffnen & beim Klicken"
L["animPlayback_onMap"] = "Nur beim Öffnen der Karte"
L["animPlayback_onClick"] = "Nur beim Klicken"
L["animPlayback_loop"] = "Endlosschleife"

L["dropdown_animStyle"] = "Animations Stil"
L["animStyle1"] = "Schrumpfen"
L["animStyle2"] = "Wachsen"
L["animStyle3"] = "Pulsieren"
L["animStyle4"] = "Blinken"

L["iconScale"] = "Highlight Skalierung"
L["dropdown_hlStyle"] = "Highlight Stil"
L["hlStyle_glowingFG"] = "Leuchtender Vordergrund"
L["hlStyle_solidBG"] = "Deckender Hintergrund"
L["hlStyle_glowingBG"] = "Leuchtender Hintergrund"

L["dropdown_hlTexture"] = "Highlight Textur"
L["hlTexture_1"] = "Identisch mit Symbol"
L["hlTexture_2"] = "Sanfter Kreis"
L["hlTexture_3"] = "Dichter gelber Kreis"
L["hlTexture_4"] = "Dichter brauner Kreis"

L["textScale"] = "Text Skalierung"
L["textPosition"] = "Text Position"
L["textCustom"] = "Benutzerdefinierter Font"
L["textLevel"] = "Text Ebene"
L["descr_textLevel"] = "Höhere Werte erlauben es dem Text ander Symbole zu überdecken.|n|nWerte zwischen 2200 un 2800 sind recht gut.|nWerte über 2800 überdecken die Spieler Markierung."

-- highlight group names
L["Navigation"] = "Navigation"
L["Locations"] = "Orte"
L["Objectives"] = "Objektive"
L["Other"] = "Andere"
-- highlight names
L["Waypoint"] = "Wegpunkt"
L["Flightmaster"] = "Flugmeister"
L["Flightmaster (undiscovered)"] = "Flugmeister (unentdeckt)"
L["Dungeon"] = true
L["Raid"] = true
L["Delve"] = "Tiefe"
L["Bountiful Delve"] = "Großzügige Tiefe"
L["Quest Hub"] = "Quest-Hub"
L["Zone Portal"] = "Reise Portale"
L["Cave Exit (Up)"] = "Höhlenausgang (Auf)"
L["Cave Exit (Down)"] = "Höhlenausgang (Ab)"
L["Rare Encounter"] = "Seltene Kreatur"
L["WQ Special Assignment"] = "WQ Spezialauftrag"
L["S.C.R.A.P. Heap (active)"] = "SCHROTT-Haufen (aktiv)"
L["S.C.R.A.P. Heap (inactive)"] = "SCHROTT-Haufen (inaktiv)"
L["Treasure Goblin Spawn"] = "Schatzgoblin"

L["checkbox_playerLocation"] = "Spieler Position hervorheben"
L["descr_playerLocation"] = "Beim Öffnen der Karte und bei Maus Klicks wird die Spieler Position hervorgehoben."
L["checkbox_battlefieldMap"] = "Gebietskarte einbeziehen"
L["descr_battlefieldMap"] = "Zusätzlich zur Weltkarte werden Highlights auch auf der Gebietskarte angezeigt."

L["chatCommands"] = "Chat Befehle:"

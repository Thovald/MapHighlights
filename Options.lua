local _, Private = ...
local Main = Private.Main
local Config = Private.Config
local Highlights = Private.Highlights
local PlayerLocation = Private.PlayerLocation

local db

local LSM = LibStub("LibSharedMedia-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MapHighlights")

local pairs, ipairs 
    = pairs, ipairs

local DEFAULT_GAME_FONT = GameFontNormal:GetFont()
local MENU_WIDTH = 800
local MENU_HEIGHT = 700
local MENU_HEIGHT_MIN = 400
local MENU_HEIGHT_MAX = 1000
local DEFAULT_PROFILE

------------------
-- Widgets
------------------

do
    local Type = "MapHighlightsPreviewAnchor"
    local Version = 1

    local function Constructor()
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetHeight(1)
        local widget = {
            type = Type,
            frame = frame,
        }

        -- required
        function widget:SetText(text)
        end

        function widget:SetFontObject(...)
        end

        function widget:OnAcquire()
            self.frame:Show()
            Config.ShowPreviewFrame(self.frame)
        end

        function widget:OnRelease()
            self.frame:Hide()
            Config.HidePreviewFrame()
        end

        return AceGUI:RegisterAsWidget(widget)
    end

    AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

------------------
-- UI Data
------------------

local TEXT_OUTLINE = {L["outlineNone"], L["outlineThin"], L["outlineThick"]}
local POSITION = {L["top"], L["bottom"], L["left"], L["right"], L["center"]}
local ANIMATION_PLAYBACK = {L["animPlayback_onBoth"], L["animPlayback_onMap"], L["animPlayback_onClick"], L["animPlayback_loop"]}
local ANIMATION_STYLE = {L["animStyle1"], L["animStyle2"], L["animStyle3"], L["animStyle4"]}
local HIGHLIGHT_STYLE = {L["hlStyle_glowingFG"], L["hlStyle_solidBG"], L["hlStyle_glowingBG"]}
local HIGHLIGHT_TEXTURE = {L["hlTexture_1"], L["hlTexture_2"], L["hlTexture_3"], L["hlTexture_4"]}


local DEFAULT_PROFILE_HIGHLIGHTS = {
    scale = 1,
    font = "Roboto Condensed Bold",
    textSize = 12,
    textLevel = 2200,
    textOutline = 2,
    entries = {},
}

local DEFAULT_PROFILE_OTHER = {
    playerHighlight = true,
    playerDirection = 3,
    directionScale = 0.3,
    directionThickness = 1,
    directionStartColor = {1,1,1,1},
    directionEndColor = {1,1,1,0},
    battlefieldMap = false,
}

-- default settings of highlight entries. 
local HIGHLIGHT_SETTINGS_TEMPLATE = {
    scale = 1,
    isEnabled = true,
    -- highlight
    iconShow = false,
    iconAlpha = 1,
    iconScale = 1.3,
    iconStyle = 3,
    iconTexture = 1,
    iconColorEnable = false,
    iconColor = {1, 1, 1, 1},
    -- text
    textShow = false,
    textAlpha = 1,
    textScale = 1,
    textPosition = 2,
    textOffset = 0,
    textColor = {1, 1, 1, 1},
    textCustom = false,
    textFont = "PT Sans Narrow Bold",
    textOutline = 2,
    -- animation
    animShow = false,
    animPlayback = 1, -- on map open & on click, only on map open, only on click, loop forever
    animStyle = 1,
    animGlow = true,
}

local HIGHLIGHT_ORDER = {
    {
        groupId = "Navigation",
        childIds = {
            "waypoint",
            "zonePortal",
            "caveExitUp",
            "caveExitDown",
            "flightpoint",
            "flightpointUnknown",
        },
    },
    {
        groupId = "Locations",
        childIds = {
            "dungeon",
            "raid",
            "delve",
            "delveBountiful",
            "poiHub",
        },
    },
    {
        groupId = "Objectives",
        childIds = {
            "rareEncounter",
            "wqAssignmentLocked",
        },
    },
    {
        groupId = "Other",
        childIds = {
            "scrapHeap_active",
            "scrapHeap_inactive",
            "greedyEmissary",
        },
    },
    -- {
    --     groupId = "Custom",
    --     childIds = {
    --     },
    -- },
}

-- "overrides" contains anything different from HIGHLIGHT_SETTINGS_TEMPLATE
-- preview always uses first texture
local HIGHLIGHT_INFO = {
    waypoint = {
        name = L["Waypoint"],
        textures = {
            "Waypoint-MapPin-Untracked",
            "Waypoint-MapPin-Tracked",
        },
        overrides = {
            iconShow = true,
            iconScale = 1.2,
            iconStyle = 2,
            iconColorEnable = true,
            iconColor = {0, 0, 0},
            animStyle = 4,
            animPlayback = 4,
            animShow = true,
        },
    },
    flightpoint = {
        name = L["Flightmaster"],
        textures = {
            "TaxiNode_Neutral",
            "TaxiNode_Alliance",
            "TaxiNode_Horde",
        },
        overrides = {
            iconScale = 1,
            iconStyle = 1,
            iconAlpha = 0.3,
            iconShow = true,
        },
    },
    flightpointUnknown = {
        name = L["Flightmaster (undiscovered)"],
        textures = {
            "TaxiNode_Undiscovered",
        },
        overrides = {
            iconScale = 1.7,
            iconAlpha = 0.5,
            iconStyle = 3,
            iconTexture = 2,
            iconColorEnable = true,
            iconColor = {0.48, 1, 0.40},
            iconShow = true,
            isEnabled = true,
        },
    },
    dungeon = {
        name = L["Dungeon"],
        textures = {
            "Dungeon",
        },
        overrides = {
            textPosition = 1,
            textShow = true,
            textOffset = -3,
            textColor = {0.43, 0.90, 0.82},
        },
    },
    raid = {
        name = L["Raid"],
        textures = {
            "Raid",
        },
        overrides = {
            textPosition = 1,
            textShow = true,
            textOffset = -3,
            textColor = {0.50, 0.90, 0.47},
        },
    },
    delve = {
        name = L["Delve"],
        textures = {
            "delves-regular",
        },
        overrides = {
            iconScale = 1,
            iconShow = true,
            textColor = {1, 0.85, 0.70},
        },
    },
    delveBountiful = {
        name = L["Bountiful Delve"],
        textures = {
            "delves-bountiful",
        },
        overrides = {
            iconScale = 1.3,
            iconAlpha = 0.7,
            textShow = true,
            iconShow = true,
            textColor = {1, 0.60, 0.27}
        },
    },
    poiHub = {
        name = L["Quest Hub"],
        textures = {
            "poi-hub",
        },
        overrides = {
            iconScale = 1.1,
            iconShow = true,
            isEnabled = false,
        },
    },
    zonePortal = {
        name = L["Zone Portal"],
        textures = {
            "TaxiNode_Continent_Neutral",
            "TaxiNode_Continent_Alliance",
            "TaxiNode_Continent_Horde",
            "TaxiNode_Continent_Alliance_Timed",
            "TaxiNode_Continent_Horde_Timed",
            "poi-rift1",
            "poi-rift2",
            "WarlockPortal-Yellow-32x32",
            "FlightMasterArgus",
        },
        overrides = {
            textColor = {0.70, 0.77, 1},
            textShow = true,
        },
    },
    caveExitUp = {
        name = L["Cave Exit (Up)"],
        textures = {
            "CaveUnderground-Up",
        },
        overrides = {
            iconScale = 1.2,
            iconColorEnable = true,
            iconShow = true,
            iconColor = {0, 1, 0},
        },
    },
    caveExitDown = {
        name = L["Cave Exit (Down)"],
        textures = {
            "CaveUnderground-Down",
        },
        overrides = {
            iconScale = 1.2,
            iconColorEnable = true,
            iconShow = true,
            iconColor = {1, 0, 0},
        },
    },
    rareEncounter = {
        name = L["Rare Encounter"],
        textures = {
            "VignetteKillElite",
            "worldquest-questmarker-dragon-silver",
        },
        overrides = {
            animStyle = 2,
            animPlayback = 2,
            textShow = true,
            animShow = true,
            textColor = {0.90, 0.90, 0.90},
        },
    },
    wqAssignmentLocked = {
        name = L["WQ Special Assignment"],
        textures = {
            "worldquest-Capstone-questmarker-epic-Locked",
        },
        overrides = {
            animShow = true,
        },
    },
    scrapHeap_active = {
        name = L["S.C.R.A.P. Heap (active)"],
        textures = {
            "SCRAP-activated",
        },
        overrides = {
            isEnabled = false,
            textShow = true,
        },
    },
    scrapHeap_inactive = {
        name = L["S.C.R.A.P. Heap (inactive)"],
        textures = {
            "SCRAP-deactivated",
        },
        overrides = {
            isEnabled = false,
            textShow = true,
        },
    },
    -- greedyEmissary = {
    --     name = L["Treasure Goblin Spawn"],
    --     textures = {
    --         "WarlockPortal-Yellow-32x32",
    --     },
    --     overrides = {
    --         textShow = true,
    --     },
    -- },
}

------------------
-- UI Logic
------------------

local function HighlightGetter(id, key)
    return function() return db.hl.entries[id][key] end
end

local function HighlightSetter(id, key)
    return function(_, value)
        db.hl.entries[id][key] = value
        Highlights.OnSettingsChanged()
    end
end

local function HighlightColorGetter(id, key)
    return function()
        return unpack(db.hl.entries[id][key])
    end
end

local function HighlightColorSetter(id, key)
    return function(_, r, g, b, a)
        db.hl.entries[id][key] = {r, g, b, a}
        Highlights.OnSettingsChanged()
    end
end

local function GenericColorGetter(id, key)
    return function()
        return unpack(db[id][key])
    end
end

local function GenericColorSetter(id, key, namespace, func, args)
    return function(_, r, g, b, a)
        db[id][key] = {r, g, b, a}
        namespace[func](args)
    end
end

local function HighlightDisabler(id, primaryKey, secondaryKey)
    return function()
        local entry = db.hl.entries[id]
        if not entry.isEnabled then
            return true
        end

        if primaryKey ~= nil and not entry[primaryKey] then
            return true
        end

        if secondaryKey ~= nil and not entry[secondaryKey] then
          return true
        end
        Highlights.OnSettingsChanged()
    end
end

local function UpdatePreview()
    if not Config.previewFrame:IsVisible() then
        return
    end

    Highlights.UpdatePreviewHighlights()
end

local function UpdateSelectedId(id)
    Config.selectedId = id
    Highlights.OnSettingsChanged()
end

------------------
-- UI Layout
------------------

local function CreatePreviewFrame()
    if Config.previewFrame then
        return
    end

    local previewFrame = CreateFrame("Frame", nil, UIParent)
    previewFrame:SetSize(280, 165)

    local title = previewFrame:CreateFontString()
    title:SetFont(DEFAULT_GAME_FONT, 12, "OUTLINE")
    title:SetPoint("BOTTOM", previewFrame, "TOP", 0, 3)
    title:SetText(Main.ColorString(L["preview"], "gold"))

    previewFrame.title = title

    local frame = CreateFrame("Frame", nil, previewFrame)
    frame:SetAllPoints()
    frame:SetClipsChildren(true)
    previewFrame.frame = frame

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("CENTER")
    bg:SetTexture("Interface\\AddOns\\MapHighlights\\Media\\PreviewBackground.tga")
    bg:SetSize(280, 280)
    frame.background = bg

    local isDisabled = frame:CreateFontString()
    isDisabled:SetFont(DEFAULT_GAME_FONT, 24, "OUTLINE")
    isDisabled:SetPoint("TOP", frame, "TOP", 0, -6)
    isDisabled:SetText(Main.ColorString(L["disabled"], "red"))
    isDisabled:Hide()
    frame.isDisabledText = isDisabled
    

    local pin = CreateFrame("Frame", nil, frame)
    pin:SetPoint("CENTER")
    pin:SetSize(28, 28)
    frame.pin = pin

    local btn = CreateFrame("Button", nil, frame)
    btn:SetAllPoints()
    btn:SetPoint("CENTER")
    frame.button = btn

    btn:RegisterForClicks("AnyUp")
    btn:SetScript("OnClick", function()
        Highlights.UpdatePreviewHighlights()
    end)

    Config.previewFrame = previewFrame
    Highlights.SetupPreviewFrame(frame)
    previewFrame:Hide()
end

function Config.ShowPreviewFrame(frame)
    Config.previewFrame:SetParent(frame)
    Config.previewFrame:SetPoint("TOPRIGHT",  -10, 25)
    Config.previewFrame:Show()
end

function Config.HidePreviewFrame()
    Config.previewFrame:SetParent(UIParent)
    Config.previewFrame:Hide()
end

local function GetHighlightEntry(id, info)
    local ANIMATION = {
        checkbox_animation = {
            type = "toggle",
            name = L["show"],
            get = HighlightGetter(id, "animShow"),
            set = HighlightSetter(id, "animShow"),
            disabled = HighlightDisabler(id),
            width = 0.7,
            order = 10,
        },
        spacer1 = {
            type = "description",
            name = L["descr_anim"],
            fontSize = "medium",
            width = 1.5,
            order = 11,
        },
        dropdown_animPlayback = {
            type = "select",
            name = L["dropdown_animPlayback"],
            values = ANIMATION_PLAYBACK,
            get = HighlightGetter(id, "animPlayback"),
            set = HighlightSetter(id, "animPlayback"),
            disabled = HighlightDisabler(id, "animShow"),
            width = 1.2,
            order = 15,
        },
        spacer2 = {
            type = "description",
            name = " ",
            width = 0.1,
            order = 16,
        },
        dropdown_animStyle = {
            type = "select",
            name = L["dropdown_animStyle"],
            values = ANIMATION_STYLE,
            get = HighlightGetter(id, "animStyle"),
            set = HighlightSetter(id, "animStyle"),
            disabled = HighlightDisabler(id, "animShow"),
            width = 0.7,
            order = 20,
        },
        spacer3 = {
            type = "description",
            name = " ",
            width = 0.1,
            order = 21,
        },
        checkbox_animationGlow = {
            type = "toggle",
            name = L["glow"],
            get = HighlightGetter(id, "animGlow"),
            set = HighlightSetter(id, "animGlow"),
            disabled = HighlightDisabler(id, "animShow"),
            width = 0.7,
            order = 21,
        },
    }

    local HIGHLIGHT = {
        checkbox_hlShow = {
            type = "toggle",
            name = L["show"],
            get = HighlightGetter(id, "iconShow"),
            set = HighlightSetter(id, "iconShow"),
            disabled = HighlightDisabler(id),
            width = 0.7,
            order = 30,
        },
        spacer1 = {
            type = "description",
            name = " ",
            width = 2,
            order = 31,
        },
        slider_hlScale = {
            type = "range",
            name = L["iconScale"],
            min = 0.1,
            max = 3,
            bigStep = 0.1,
            get = HighlightGetter(id, "iconScale"),
            set = HighlightSetter(id, "iconScale"),
            disabled = HighlightDisabler(id, "iconShow"),
            width = 1,
            order = 35,
        },
        slider_hlAlpha = {
            type = "range",
            name = L["alpha"],
            min = 0.1,
            max = 1,
            bigStep = 0.1,
            get = HighlightGetter(id, "iconAlpha"),
            set = HighlightSetter(id, "iconAlpha"),
            disabled = HighlightDisabler(id, "iconShow"),
            width = 1,
            order = 40,
        },
        spacer2 = {
            type = "description",
            name = " ",
            width = 0.5,
            order = 41,
        },
        dropdown_hlStyle = {
            type = "select",
            name = L["dropdown_hlStyle"],
            values = HIGHLIGHT_STYLE,
            get = HighlightGetter(id, "iconStyle"),
            set = HighlightSetter(id, "iconStyle"),
            disabled = HighlightDisabler(id, "iconShow"),
            width = 1,
            order = 45,
        },
        dropdown_hlTexture = {
            type = "select",
            name = L["dropdown_hlTexture"],
            values = HIGHLIGHT_TEXTURE,
            get = HighlightGetter(id, "iconTexture"),
            set = HighlightSetter(id, "iconTexture"),
            disabled = HighlightDisabler(id, "iconShow"),
            width = 1,
            order = 50,
        },
        spacer3 = {
            type = "description",
            name = " ",
            width = 0.5,
            order = 51,
        },
        checkbox_hlColorEnable = {
            type = "toggle",
            name = L["enableColor"],
            get = HighlightGetter(id, "iconColorEnable"),
            set = HighlightSetter(id, "iconColorEnable"),
            disabled = HighlightDisabler(id, "iconShow"),
            width = 0.7,
            order = 55,
        },
        color_hlColor = {
            name = L["color"],
            type = "color",
            get = HighlightColorGetter(id, "iconColor"),
            set = HighlightColorSetter(id, "iconColor"),
            disabled = HighlightDisabler(id, "iconColorEnable", "iconShow"),
            hasAlpha = true,
            order = 60,
        },
    }

    local TEXT = {
            checkbox_textShow = {
                type = "toggle",
                name = L["show"],
                get = HighlightGetter(id, "textShow"),
                set = HighlightSetter(id, "textShow"),
                disabled = HighlightDisabler(id),
                width = 0.7,
                order = 70,
            },
            spacer1 = {
                type = "description",
                name = " ",
                width = 2,
                order = 71,
            },
            slider_textAlpha = {
                type = "range",
                name = L["alpha"],
                min = 0,
                max = 1,
                bigStep = 0.1,
                get = HighlightGetter(id, "textAlpha"),
                set = HighlightSetter(id, "textAlpha"),
                disabled = HighlightDisabler(id, "textShow"),
                width = 1,
                order = 75,
            },
            slider_textScale = {
                type = "range",
                name = L["textScale"],
                min = 0.1,
                max = 3,
                bigStep = 0.1,
                get = HighlightGetter(id, "textScale"),
                set = HighlightSetter(id, "textScale"),
                disabled = HighlightDisabler(id, "textShow"),
                width = 1,
                order = 80,
            },
            spacer2 = {
                type = "description",
                name = " ",
                width = 0.5,
                order = 81,
            },
            dropdown_textPosition = {
                type = "select",
                name = L["textPosition"],
                values = function() return POSITION end,
                get = HighlightGetter(id, "textPosition"),
                set = HighlightSetter(id, "textPosition"),
                disabled = HighlightDisabler(id, "textShow"),
                width = 0.7,
                order = 85,
            },
            slider_textOffset = {
                type = "range",
                name = L["offset"],
                min = -20,
                max = 20,
                bigStep = 0.1,
                get = HighlightGetter(id, "textOffset"),
                set = HighlightSetter(id, "textOffset"),
                disabled = HighlightDisabler(id, "textShow"),
                width = 1,
                order = 86,
            },
            spacer3 = {
                type = "description",
                name = " ",
                width = 0.1,
                order = 87,
            },
            color_textColor = {
                name = L["color"],
                type = "color",
                get = HighlightColorGetter(id, "textColor"),
                set = HighlightColorSetter(id, "textColor"),
                disabled = HighlightDisabler(id, "textShow"),
                hasAlpha = true,
                order = 90,
            },
            checkbox_textCustom = {
                type = "toggle",
                name = L["textCustom"],
                get = HighlightGetter(id, "textCustom"),
                set = HighlightSetter(id, "textCustom"),
                disabled = HighlightDisabler(id, "textShow"),
                width = 1.5,
                order = 95,
            },
            spacer4 = {
                type = "description",
                name = " ",
                width = 0.5,
                order = 96,
            },
            dropdown_textFont = {
                type = "select",
                name = L["textFont"],
                dialogControl = "LSM30_Font",
                values = LSM:HashTable("font"),
                get = HighlightGetter(id, "textFont"),
                set = HighlightSetter(id, "textFont"),
                disabled = HighlightDisabler(id, "textCustom", "textShow"),
                width = 1.5,
                order = 100,
            },
            dropdown_textOutline = {
                type = "select",
                name = L["dropdown_textOutline"],
                values = function() return TEXT_OUTLINE end,
                get = HighlightGetter(id, "textOutline"),
                set = HighlightSetter(id, "textOutline"),
                disabled = HighlightDisabler(id, "textCustom", "textShow"),
                width = 0.5,
                order = 105,
            },
    }

    local ENTRY = {
        type = "group",
        name = info.name,
        childGroups = "tab",
        order = 1,
        args = {
            groupSetter = {
                type = "description",
                name ="",
                hidden  = function(a,b,c)
                    -- this fires whenever the user selects this group.
                    -- hacky workaround to keep track of which highlight is currently selected.
                    UpdateSelectedId(id)
                    UpdatePreview()
                    return true
                end
            },
            checkbox_enable = {
                type = "toggle",
                name = L["enable"],
                get = HighlightGetter(id, "isEnabled"),
                set = HighlightSetter(id, "isEnabled"),
                width = 0.6,
                order = 1,
            },
            slider_iconScale = {
                type = "range",
                name = L["scale"],
                min = 0.1,
                max = 5,
                softMax = 3,
                bigStep = 0.1,
                get = HighlightGetter(id, "scale"),
                set = HighlightSetter(id, "scale"),
                disabled = HighlightDisabler(id),
                width = 1.5,
                order = 2,
            },
            tab_highlight = {
                type = "group",
                name = L["highlight"],
                args = HIGHLIGHT,
                disabled = HighlightDisabler(id),
                order = 3
            },
            text_anim = {
                type = "group",
                name = L["text"],
                args = TEXT,
                disabled = HighlightDisabler(id),
                order = 4
            },
            tab_anim = {
                type = "group",
                name = L["animation"],
                args = ANIMATION,
                disabled = HighlightDisabler(id),
                order = 5
            },
        },
    }
    return ENTRY
end

local TAB_HIGHLIGHTS = {
    type = "group",
    name = L["tab_mapHighlights"],
    order = 1,
    args = {
        header_globalIcons = {
            type = "header",
            name = L["header_globalHighlights"],
            order = 1,
        },
        descr_globalIcons = {
            type = "description",
            name = L["descr_globalHighlights"].."|n|n",
            fontSize = "medium",
            width = 2.5,
            order = 3,
        },
        preview = {
            -- this is a thin strip along the entire width of the menu.
            -- the previewFrame gets attached to this.
            type = "description",
            name = "",
            order = 6,
            dialogControl = "MapHighlightsPreviewAnchor",
        },
        slider_globalScale = {
            type = "range",
            name = L["scale"],
            min = 0.1,
            max = 5,
            softMax = 3,
            bigStep = 0.1,
            get = function() return db.hl.scale end,
            set = function(_, value)
                db.hl.scale = value
                Highlights.OnSettingsChanged()
                end,
            order = 10,
            width = 1,
        },
        dropdown_globalFont = {
            type = "select",
            name = L["textFont"],
            dialogControl = "LSM30_Font",
            values = LSM:HashTable("font"),
            get = function(info)
                return db.hl.font
            end,
            set = function(info, value)
                db.hl.font = value
                Highlights.OnSettingsChanged()
            end,
            width = 1.5,
            order = 15,
        },
        rightSpacer = {
            type = "description",
            name = "",
            width = 1,
            order = 16,
        },
        slider_globalTextSize = {
            type = "range",
            name = L["textSize"],
            min = 1,
            max = 50,
            softMax = 30,
            bigStep = 0.25,
            get = function() return db.hl.textSize end,
            set = function(_, value)
                db.hl.textSize = value
                Highlights.OnSettingsChanged()
                end,
            width = 1,
            order = 18,
        },
        dropdown_globalTextOutline = {
            type = "select",
            name = L["dropdown_textOutline"],
            values = function() return TEXT_OUTLINE end,
            get = function(info)
                return db.hl.textOutline
            end,
            set = function(info, value)
                db.hl.textOutline = value
                Highlights.OnSettingsChanged()
            end,
            width = 0.5,
            order = 20,
        },
        slider_textLevel = {
            type = "range",
            name = L["textLevel"],
            desc = L["descr_textLevel"],
            min = 1,
            max = 9999,
            bigStep = 1,
            get = function() return db.hl.textLevel end,
            set = function(_, value)
                db.hl.textLevel = value
                Highlights.OnSettingsChanged()
                end,
            width = 1,
            order = 25,
        },
        bottomSpacer = {
            type = "description",
            name = "|n|n|n",
            width = "full",
            order = 26,
        },
        header_highlightSelection = {
            type = "header",
            name = L["header_hlSelection"],
            order = 30,
        },
    },
}

local TAB_OTHER = {
    type = "group",
    name = L["tab_other"],
    order = 5,
    args = {
        header_playerLocation = {
            type = "header",
            name = L["header_playerLocation"],
            order = 0,
        },
        checkbox_playerHighlight = {
            type = "toggle",
            name = L["enable"],
            desc = L["descr_playerLocation"],
            get = function(info)
                return db.other.playerHighlight
            end,
            set = function(info, value)
                db.other.playerHighlight = value
                PlayerLocation.OnSettingsChanged()
            end,
            width = 1,
            order = 1,
        },
        spacer1 = {
            type = "description",
            name = " |n|n",
            order = 2,
        },
        header_playerDirection = {
            type = "header",
            name = L["header_playerDirection"],
            order = 4,
        },
        dropdown_playerDirection = {
            type = "select",
            name = L["show"],
            values = {L["never"], L["always"], L["whileFlying"]},
            desc = L["descr_playerDirection"],
            get = function(info)
                return db.other.playerDirection
            end,
            set = function(info, value)
                db.other.playerDirection = value
                PlayerLocation.OnSettingsChanged({ignoreArrow = true})
            end,
            width = 1,
            order = 5,
        },
        slider_directionScale = {
            type = "range",
            name = L["length"],
            min = 0.1,
            max = 1,
            bigStep = 0.1,
            get = function() return db.other.directionScale end,
            set = function(_, value)
                db.other.directionScale = value
                PlayerLocation.OnSettingsChanged({ignoreArrow = true})
                end,
            disabled = function() return not db.other.playerDirection end,
            width = 1,
            order = 6,
        },
        slider_directionThickness = {
            type = "range",
            name = L["thickness"],
            min = 0.5,
            max = 5,
            bigStep = 0.01,
            get = function() return db.other.directionThickness end,
            set = function(_, value)
                db.other.directionThickness = value
                PlayerLocation.OnSettingsChanged({ignoreArrow = true})
                end,
            disabled = function() return not db.other.playerDirection end,
            width = 1,
            order = 7,
        },
        color_directionStart = {
            name = L["colorStart"],
            type = "color",
            get = GenericColorGetter("other", "directionStartColor"),
            set = GenericColorSetter("other", "directionStartColor", PlayerLocation, "OnSettingsChanged", {ignoreArrow = true}),
            disabled = function() return not db.other.playerDirection end,
            hasAlpha = true,
            width = 0.5,
            order = 8,
        },
        color_directionEnd = {
            name = L["colorEnd"],
            type = "color",
            get = GenericColorGetter("other", "directionEndColor"),
            set = GenericColorSetter("other", "directionEndColor", PlayerLocation, "OnSettingsChanged", {ignoreArrow = true}),
            disabled = function() return not db.other.playerDirection end,
            hasAlpha = true,
            width = 0.5,
            order = 9,
        },
        spacer2 = {
            type = "description",
            name = " |n|n",
            order = 10,
        },
        header_misc = {
            type = "header",
            name = L["header_misc"],
            order = 15,
        },
        checkbox_battleFieldMap = {
            type = "toggle",
            name = L["checkbox_battlefieldMap"],
            desc = L["descr_battlefieldMap"],
            get = function(info)
                return db.other.battlefieldMap
            end,
            set = function(info, value)
                db.other.battlefieldMap = value
                if Main.IsValidMap(BattlefieldMapFrame) then
                    PlayerLocation.ShowHighlight(BattlefieldMapFrame)
                else
                    PlayerLocation.OnSettingsChanged()
                end
                Highlights.OnSettingsChanged()
            end,
            width = 1.5,
            order = 16,
        },
    }
}


local OPTIONS_MENU = {
    type = "group",
    name = "Map Highlights",
    childGroups = "tab",
    args = {
        setup = {
            name = L["tab_settings"],
            type = "group",
            childGroups = "tab",
            order = 1,
            args = {
                tabMapHighlights = TAB_HIGHLIGHTS,
                tabOther = TAB_OTHER,
            },
        },
        -- profiles is set later when db has actually been initialized
    },
}

local function GetHighlightGroup(name)
    local group = {
        type = "group",
        name = name,
        args = {
            groupSetter = {
                type = "description",
                name ="",
                hidden  = function(a,b,c)
                    UpdateSelectedId("")
                    UpdatePreview()
                    return true
                end,
                order = 0,
            },
        },
    }
    return group
end

local function BuildHighlightSelections()
    local order = 50
    for _, groupInfo in ipairs(HIGHLIGHT_ORDER) do
        local groupId = groupInfo.groupId
        local groupName = L[groupId]
        local newGroup = GetHighlightGroup(groupName)
        newGroup.order = order
        order = order + 1

        for i, id in ipairs(groupInfo.childIds) do
            local info = HIGHLIGHT_INFO[id]
            if info then
                local entry = GetHighlightEntry(id, info)
                entry.order = i
                newGroup.args[id] = entry
            end
        end

        TAB_HIGHLIGHTS.args[groupId] = newGroup
    end
end

function Config.BuilOptionsMenu()
    BuildHighlightSelections()
end

------------------
-- Setup
------------------

function Config.UpdateDB()
    db = Private.db.profile
end

local function CreateDefaultHighlightEntry(id)
    local entry = CopyTable(HIGHLIGHT_SETTINGS_TEMPLATE)

    local info = HIGHLIGHT_INFO[id]
    if info and info.overrides then
        for k, v in pairs(info.overrides) do
            entry[k] = type(v) == "table" and CopyTable(v) or v
        end
    end

    return entry
end

function Config.BuildTextureIndex()
    wipe(Highlights.textureToInfo)
    wipe(Highlights.idToPins)
    for id, data in pairs(HIGHLIGHT_INFO) do
        Highlights.idToPins[id] = {pins = {}, db = db.hl.entries[id]}
        for _, tex in ipairs(data.textures) do
            Highlights.textureToInfo[tex] = {
                db = db.hl.entries[id],
                id = id,
                name = data.name,
                previewTexture = data.textures[1]
            }
        end
    end
end

function Config.GetDefaultProfile()
    if DEFAULT_PROFILE then
        return CopyTable(DEFAULT_PROFILE)
    end

    DEFAULT_PROFILE = {
        hl = DEFAULT_PROFILE_HIGHLIGHTS,
        other = DEFAULT_PROFILE_OTHER,
    }

    -- highlight entries
    for id, _ in pairs(HIGHLIGHT_INFO) do
        DEFAULT_PROFILE.hl.entries[id] = CreateDefaultHighlightEntry(id)
    end

    -- actually important to copy!
    -- don't want to later return a copy of the modified original.
    return CopyTable(DEFAULT_PROFILE)
end

local function OnOptionsClose()
    if Config.previewFrame and Config.previewFrame.frame.pin.animFrame.anim then
        Config.previewFrame.frame.pin.animFrame.anim:Stop()
    end
end

local function OnOptionsOpen(frame)
end

local function SetHooksForAce()
    hooksecurefunc(AceConfigDialog, "Open", function(_, appName)
        -- this runs every time an option is changed, not just when menu opens.
        if appName ~= "MapHighlights" then return end

        local f = AceConfigDialog.OpenFrames[appName]
        if not f then return end

        f:SetStatusText(L["chatCommands"].." /maphighlights /maphl")

        if not Private.isAceHooked then
            local frame = f.frame
            frame:SetResizeBounds(MENU_WIDTH, MENU_HEIGHT_MIN, MENU_WIDTH, MENU_HEIGHT_MAX)
            frame:HookScript("OnShow", function() OnOptionsOpen(frame) end)
            frame:HookScript("OnHide", function() OnOptionsClose() end)
            Private.isAceHooked = true
            OnOptionsOpen(frame) -- need to run this manually on first open
        end
    end)

end 

local function CreateBlizzardOptions()
    local panel = CreateFrame("Frame")
    panel.name = "Map Highlights"

    panel:SetScript("OnShow", function(self)
        if self.initialized then return end
        self.initialized = true

        local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge2")
        title:SetText("Map Highlights|n|n")
        title:SetPoint("TOP", 0, -80)

        local desc = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
        desc:SetJustifyH("CENTER")
        desc:SetPoint("TOP", title, "BOTTOM", 0, -16)
        desc:SetText(
            Main.ColorString("/maphl", "blue").."   "..Main.ColorString("/maphighlights", "blue").."|n"
        )

        local button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
        button:SetSize(220, 34)
        button:SetPoint("TOP", desc, "BOTTOM", 0, -24)
        button:SetText(L["openOptions"])

        button:SetScript("OnClick", function()
            HideUIPanel(SettingsPanel)
            AceConfigDialog:Open("MapHighlights")
        end)
    end)

    local category = Settings.RegisterCanvasLayoutCategory(panel, "Map Highlights")
    Settings.RegisterAddOnCategory(category)
end

function Config.RegisterOptions()
    CreatePreviewFrame()

    -- setting profiles tab in options menu
    OPTIONS_MENU.args.profiles = AceDBOptions:GetOptionsTable(Private.db)

    AceConfig:RegisterOptionsTable("MapHighlights", OPTIONS_MENU)
    AceConfigDialog:SetDefaultSize("MapHighlights", MENU_WIDTH, MENU_HEIGHT)

    SLASH_MAPHL1 = "/maphighlights"
    SLASH_MAPHL2 = "/maphl"
    SlashCmdList["MAPHL"] = function()
        if AceConfigDialog.OpenFrames["MapHighlights"] then
            AceConfigDialog:Close("MapHighlights")
        else
            AceConfigDialog:Open("MapHighlights")
        end
    end

    CreateBlizzardOptions()
    SetHooksForAce()

    -- C_Timer.After(1, function()
    --     AceConfigDialog:Open("MapHighlights")
    -- end)

end

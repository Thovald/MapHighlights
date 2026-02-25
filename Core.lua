local _, Private = ...
Private.Main = {}
Private.Config = {}
Private.Highlights = {}
Private.PlayerLocation = {}
Private.isAceHooked = false

local db
local Main = Private.Main
local Config = Private.Config
local Highlights = Private.Highlights
local PlayerLocation = Private.PlayerLocation
local MapHooks = {} -- namespace for map hooks
local isMapHooked = {}

-- assigned when we're hooking mixins further below
Main.PIN_TEMPLATE_TO_FUNCTION = {}

------------------
-- AddOn Setup
------------------

Main.frame = CreateFrame("Frame")
Main.frame:RegisterEvent("PLAYER_LOGIN")
Main.frame:RegisterEvent("ADDON_LOADED")

local function RefreshSettings()
    Highlights.OnSettingsChanged()
end

local function UpdateAllDB()
    db = Private.db.profile
    Config.UpdateDB()
    Highlights.UpdateDB()
    PlayerLocation.UpdateDB()
end

function Private:OnProfileChanged()
    UpdateAllDB()
    Config.BuildTextureIndex()
    RefreshSettings()
end

------------------
-- Misc
------------------

function Main.GetErrorTitleString()
    return "|cff80ffffMap Highlights: |r"
end

function Main.ColorString(string, clr)
    local clrTable = {
        red = "|cffff3b3b",
        green = "|cff3bff3b",
        blue = "|cff80ffff",
        gold = "|cFFFFD100",
    }

    local clrString = clrTable[clr]
    if clrString then
        return clrString .. string .. "|r"
    else
        return string
    end
end

------------------
-- Pin Handlers
------------------

local function ProcessPin(pin, hlInfo, pinInfo, event)
    local highlightDB = hlInfo.db

    if not highlightDB.isEnabled then
        return
    end

    local scaleChanged = Highlights.ApplyScale(pinInfo, highlightDB)
    local iconFrame, textFrame, animFrame

    if highlightDB.iconShow then
        iconFrame = Highlights.SetupIconFrame(pin, highlightDB, pinInfo)
    end

    if highlightDB.textShow then
        textFrame = Highlights.SetupTextFrame(pin, highlightDB, pinInfo)
    end

    if highlightDB.animShow then
        animFrame = Highlights.SetupAnimationFrame(pin, highlightDB, pinInfo)
        if animFrame.playOnMapOpen and event == "OnAcquired" then
            animFrame.anim:Play()
        end
    end

    if not scaleChanged and not iconFrame and not textFrame and not animFrame then
        return
    end

    Highlights.OnHighlightAdded(pin, iconFrame, textFrame, animFrame, hlInfo, pinInfo)
end

local function IsPinOnMap(pin)
    -- can add BattlefieldMapFrame later
    if pin.GetOwningMap then
        local owningMap = pin:GetOwningMap()
        local validWorldMap = owningMap == WorldMapFrame
        local validBattlefieldMap = Private.db.profile.other.battlefieldMap and owningMap == BattlefieldMapFrame
        return validWorldMap or validBattlefieldMap
    else
        return false
    end
end

function Main.CreatePinInfo(textureName, texturePath, pinType, pin)
    local origScale = texturePath:GetScale()
    local pinInfo = {
        pin = pin,
        name = pin.name,
        frameLevel = pin:GetFrameLevel(),
        textureName = textureName,
        texturePath = texturePath,
        pinType = pinType,
        origScale = origScale,
        currentScale = origScale,
    }
    return pinInfo
end

local function AreaPOIAcquired(pin, _, _, _, event)
    if not IsPinOnMap(pin) then
        return
    end

    event = event or "OnAcquired"

    local texturePath = pin.Texture
    local textureName = pin.poiInfo.atlasName
    local hlInfo = Highlights.textureToInfo[textureName]
    if textureName and hlInfo then
        local pinInfo = Main.CreatePinInfo(textureName, texturePath, "AreaPOI", pin)
        ProcessPin(pin, hlInfo, pinInfo, event)
    end
end

local function AreaPOIReleased(pin)
    Highlights.OnReleased(pin)
end

local function VignetteAcquired(pin, _, _, _, event)
    if not IsPinOnMap(pin) then
        return
    end

    event = event or "OnAcquired"

    local texturePath = pin.Texture
    local textureName = texturePath:GetAtlas()
    local hlInfo = Highlights.textureToInfo[textureName]
    if textureName and hlInfo then
        local pinInfo = Main.CreatePinInfo(textureName, texturePath, "Vignette", pin)
        ProcessPin(pin, hlInfo, pinInfo, event)
    end
end

local function VignetteReleased(pin)
    Highlights.OnReleased(pin)
end

local function WaypointAcquired(pin, _, _, _, event)
    if not IsPinOnMap(pin) then
        return
    end

    event = event or "OnAcquired"

    local texturePath = pin.Icon
    local textureName = pin.Icon:GetAtlas()
    local hlInfo = Highlights.textureToInfo[textureName]
    if textureName and hlInfo then
        local pinInfo = Main.CreatePinInfo(textureName, texturePath, "Waypoint", pin)
        pinInfo.name = "Waypoint"
        ProcessPin(pin, hlInfo, pinInfo, event)
    end
end

local function WayPointClicked(pin)
    -- clicking on waypoint doesn't trigger map's OnClick function.
    -- delay because this triggers an OnAcquired that needs to finish first.
    RunNextFrame(function()
        Highlights.PlayAnimation(pin, "playOnClick")
    end)
end

local function WaypointReleased(pin)
    Highlights.OnReleased(pin)
end

------------------
-- Pin-Mixin Hooks
------------------

do
    local HOOKS_BY_PIN_TYPE = {
        areaPOI = {
            mixins = {
                AreaPOIPinMixin,
                DungeonEntrancePinMixin,
                MapLinkPinMixin,
                DelveEntrancePinMixin,
                FlightPointPinMixin
            },
            templates = {
                "AreaPOIPinTemplate",
                "DungeonEntrancePinTemplate",
                "MapLinkPinTemplate",
                "DelveEntrancePinTemplate",
                "FlightPointPinTemplate",
                "QuestHubPinTemplate", -- we're not hooking to this guy's mixin
            },
            hooks = {
                acquired = {"OnAcquired", AreaPOIAcquired},
                released = {"OnReleased", AreaPOIReleased},
            },
        },
        vignette = {
            mixins = {
                VignettePinMixin,
                VignettePinPOIButtonMixin,
            },
            templates = {
                "VignettePinTemplate",
                "VignettePinPOIButtonTemplate",
            },
            hooks = {
                acquired = {"OnAcquired", VignetteAcquired},
                released = {"OnReleased", VignetteReleased},
            },
        },
        waypoint = {
            mixins = {
                WaypointLocationPinMixin,
            },
            templates = {
                "WaypointLocationPinTemplate",
            },
            hooks = {
                acquired = {"OnAcquired", WaypointAcquired},
                released = {"OnReleased", WaypointReleased},
                clicked = {"OnMouseClickAction", WayPointClicked},
            },
        },

    }

    for pinName, pinType in pairs(HOOKS_BY_PIN_TYPE) do
        -- mapping pinTemplate to function that handles this pin when acquired.
        -- used when we enumerate all pins in OnSettingsChanged.
        for _, template in pairs(pinType.templates) do
            local fn = pinType.hooks.acquired[2]
            Main.PIN_TEMPLATE_TO_FUNCTION[template] = fn
        end

        -- hooking mixins
        for i, mixin in pairs(pinType.mixins) do
            for _, fn in pairs({"acquired", "released", "clicked"}) do
                if pinType.hooks[fn] then
                    local origFn, targetFn = pinType.hooks[fn][1], pinType.hooks[fn][2]
                    if mixin[origFn] then
                        hooksecurefunc(mixin, origFn, targetFn)
                    end
                end
            end
        end

    end

end

------------------
-- Map Hooks
------------------

local function SetMapHooks(frame)
    if isMapHooked[frame] or not frame then
        return
    end

    frame:HookScript("OnShow", function() MapHooks.OnShow(frame) end)
    hooksecurefunc(frame, "OnMapChanged", function() MapHooks.OnShow(frame) end)

    frame:HookScript("OnHide", function() MapHooks.OnHide(frame) end)
    hooksecurefunc(frame, "ProcessCanvasClickHandlers", function(...) MapHooks.OnClick(frame) end)

    isMapHooked[frame] = true
end

local function UpdateViewRect(map)
    if not map.ScrollContainer.viewRect then
        map:GetViewRect()
    end
end

function Main.IsValidMap(map)
    if not map then
        return false
    elseif map == WorldMapFrame then
        return true
    elseif map == BattlefieldMapFrame and db.other.battlefieldMap then
        return true
    else
        return false
    end
end

function MapHooks.OnShow(map)
    if not Main.IsValidMap(map) then
        return
    end

    UpdateViewRect(map)

    Highlights.PlayAllAnimations(map, "playOnMapOpen")
    PlayerLocation.ShowHighlight(map)

    Highlights.PrintStats()
    Highlights.PrintIcons(map)
end

function MapHooks.OnHide(map)
    if not Main.IsValidMap(map) then
        return
    end

    Highlights.StopAllAnimations(map)
    PlayerLocation.HideHighlight(map)
end

function MapHooks.OnClick(map)
    if not Main.IsValidMap(map) then
       return
    end

    -- this is delayed for only one niche case. probably good thing to do anyway.
    -- if waypoint is toggled as active and then a new waypoint is placed, animation wouldn't trigger.
    RunNextFrame(function()
        Highlights.PlayAllAnimations(map, "playOnClick")
    end)

    PlayerLocation.ShowHighlight(map)
    Highlights.PrintIcons(map)
    Highlights.PrintStats()
end

local function ShowBattlefieldMapOnLogin()
    -- if map is open, IsShown returns false on login and OnShow doesn't fire.
    C_Timer.After(2, function()
        if Main.IsValidMap(BattlefieldMapFrame) and BattlefieldMapFrame:IsShown() then
            MapHooks.OnShow(BattlefieldMapFrame)
        end
    end)
end

------------------
-- Events
------------------

local function InitDB()
    local defaultProfile = {profile = Config.GetDefaultProfile()}

    -- default profile is not saved to savedvariables! only the changes are.
    Private.db = LibStub("AceDB-3.0"):New("MapHighlightsDB", defaultProfile, true)
    db = Private.db.profile
    UpdateAllDB()

    Private.db.RegisterCallback(Private, "OnProfileChanged", "OnProfileChanged")
    Private.db.RegisterCallback(Private, "OnProfileCopied", "OnProfileChanged")
    Private.db.RegisterCallback(Private, "OnProfileReset", "OnProfileChanged")

    Config.RegisterOptions()
end

local function OnAddonLoaded(addonName)
    if addonName == "Blizzard_BattlefieldMap" then
        SetMapHooks(BattlefieldMapFrame)
    elseif addonName == "MapHighlights" then
        local LSM = LibStub("LibSharedMedia-3.0")
        LSM:Register("font", "Roboto Condensed Bold", [[Interface\Addons\MapHighlights\Media\RobotoCondensed-Bold.ttf]])
        
    end
end

function Main.InitAddon()
    Config.BuildTextureIndex()
    Config.BuilOptionsMenu()
end

local function OnLogin()
    InitDB()
    Main.InitAddon()
    SetMapHooks(WorldMapFrame)
    SetMapHooks(BattlefieldMapFrame)

    ShowBattlefieldMapOnLogin()
end

------------------
-- Event Handler
------------------

local EVENT_HANDLER = {
    ["ADDON_LOADED"] = OnAddonLoaded,
    ["PLAYER_LOGIN"] = OnLogin,
}

function Main.frame:OnEvent(event, ...)
    EVENT_HANDLER[event](...)
end

Main.frame:SetScript("OnEvent", Main.frame.OnEvent)

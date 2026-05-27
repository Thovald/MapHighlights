local _, Private = ...
local Main = Private.Main
local Config = Private.Config
local Highlights = Private.Highlights
local db

local LSM = LibStub("LibSharedMedia-3.0")

local GetTime, pairs, ipairs = GetTime, pairs, ipairs

local ICON_FRAME_POOL = {} -- fobj=bool - true if available
local TEXT_FRAME_POOL = {}
local ANIMATION_FRAME_POOL = {}

Highlights.textureToInfo = {} -- {"textureName" = {id = "waypoint", db = dbWaypoint}, ...}
Highlights.idToPins = {} -- id = {"pins" = {pinObj = {iconFrame, textFrame, animFrame, pinInfo}}, "db" = db }

-- used to release
local pinToFrames = {} -- {pinObj = {iconFrame=fobj, textFrame=fobj, animFrame=fobj}}

local debugPrintStats = false
local debugPrintIcons = false

function Highlights.UpdateDB()
    db = Private.db.profile
end

------------------
-- All Highlights
------------------

local function GetHighlightFrame(pool, newFrameFunction)
    local newFrame

    for frame, available in pairs(pool) do
        if available then
            newFrame = frame
            pool[frame] = false
            break
        end
    end

    if not newFrame then
        newFrame = newFrameFunction()
        pool[newFrame] = false
    end

    newFrame:Show()
    return newFrame
end

local function RestorePin(pinInfo)
    local pinTexture = pinInfo.texturePath
    pinTexture:SetScale(pinInfo.origScale)
end

function Highlights.ApplyScale(pinInfo, highlightDB)
    local pinTexture = pinInfo.texturePath
    local origScale = pinInfo.origScale
    local newScale = origScale * highlightDB.scale * db.hl.scale
    local scaleChanged = origScale ~= newScale

    if scaleChanged then
        pinTexture:SetScale(newScale)
        pinInfo.currentScale = newScale
    else
        pinTexture:SetScale(origScale)
        pinInfo.currentScale = origScale
    end

    return scaleChanged
end

function Highlights.OnHighlightAdded(pin, iconFrame, textFrame, animFrame, hlInfo, pinInfo)
    local pinTable = {
        iconFrame = iconFrame,
        textFrame = textFrame,
        animFrame = animFrame,
        pinInfo = pinInfo,
        id = hlInfo.id,
    }

    -- we want these to reference the same table
    pinToFrames[pin] = pinTable
    Highlights.idToPins[hlInfo.id].pins[pin] = pinTable
end

function Highlights.OnReleased(pin)
    if not pinToFrames[pin] then
        return
    end

    local id = pinToFrames[pin].id
    Highlights.ReleaseIconFrame(pin)
    Highlights.ReleaseTextFrame(pin)
    Highlights.ReleaseAnimationFrame(pin)
    RestorePin(pinToFrames[pin].pinInfo)

    pinToFrames[pin] = nil
    Highlights.idToPins[id].pins[pin] = nil
end

local function ReleasePinsByTemplate(template, map)
    for pin in map:EnumeratePinsByTemplate(template) do
        if pinToFrames[pin] then
            Highlights.OnReleased(pin)
        end
    end
end

local function RebuildPinsForTemplate(template, map)
    local pinFunction = Main.PIN_TEMPLATE_TO_FUNCTION[template]
    if not pinFunction then
        return
    end

    for pin in map:EnumeratePinsByTemplate(template) do
        pinFunction(pin)
    end
end

function Highlights.OnSettingsChanged()
    -- wiping all pins and then rebuilding pins on active maps with OnAcquired
    for _, map in pairs({WorldMapFrame, BattlefieldMapFrame}) do
        for template in pairs(map.pinPools) do
            ReleasePinsByTemplate(template, map)
            if Main.IsValidMap(map) then
                RebuildPinsForTemplate(template, map)
            end
        end
        Highlights.PlayAllAnimations(map, "playOnLoop")
    end
    Highlights.UpdatePreviewHighlights()
end

------------------
-- Icon Highlight
------------------

local ICON_STYLE_MAPPING = {
    { -- Glowing Foreground
        blendMode = "ADD",
        inFront = true,
    },
    { -- Solid Background
        blendMode = "BLEND",
        inFront = false,
    },
    { -- Glowing Background
        blendMode = "ADD",
        inFront = false,
    },
}

local ICON_TEXTURE_MAPPING = {
    [1] = false, -- Same as pin
    [2] = "ui-frame-cypherchoice-portrait-fx-back-white", -- Soft Circle
    [3] = "UI-QuestPoi-QuestNumber-SuperTracked", -- Solid Yellow Circle
    [4] = "UI-QuestPoi-QuestNumber", -- Solid Brown Circle
}

local function CreateIconFrame()
    local frame = CreateFrame("Frame")
    local tex = frame:CreateTexture()
    tex:SetAllPoints()
    frame.texture = tex
    return frame
end

local function ApplyIconSettings(iconFrame, highlightDB, pinInfo, pin)
    iconFrame:SetSize(pin:GetSize())
    iconFrame:SetAlpha(highlightDB.iconAlpha)
    iconFrame:SetScale(pinInfo.currentScale * highlightDB.iconScale)

    local styleInfo = ICON_STYLE_MAPPING[highlightDB.iconStyle]
    local textureName = ICON_TEXTURE_MAPPING[highlightDB.iconTexture] or pinInfo.textureName

    if styleInfo.inFront then
        iconFrame:SetFrameLevel(pinInfo.frameLevel + 1)
    else
        iconFrame:SetFrameLevel(pinInfo.frameLevel - 1)
    end

    iconFrame.texture:SetBlendMode(styleInfo.blendMode)
    iconFrame.texture:SetAtlas(textureName)

    if highlightDB.iconColorEnable then
        iconFrame.texture:SetDesaturated(true)
        iconFrame.texture:SetVertexColor(unpack(highlightDB.iconColor))
    else
        iconFrame.texture:SetDesaturated(false)
        iconFrame.texture:SetVertexColor(1,1,1,1)
    end
end

function Highlights.SetupIconFrame(pin, highlightDB, pinInfo)
    local iconFrame = GetHighlightFrame(ICON_FRAME_POOL, CreateIconFrame)

    iconFrame:SetParent(pin)
    iconFrame:SetPoint("CENTER")

    ApplyIconSettings(iconFrame, highlightDB, pinInfo, pin)

    return iconFrame
end

function Highlights.ReleaseIconFrame(pin)
    local frame = pinToFrames[pin].iconFrame

    if not frame then
        return
    end
    ICON_FRAME_POOL[frame] = true
    pinToFrames[pin].iconFrame = nil
    frame:Hide()
end

------------------
-- Text Highlight
------------------

local TEXT_ANCHOR_MAPPING = {
    { -- Top
        anchor1 = "BOTTOM",
        anchor2 = "TOP",
        xOffsetMult = 0,
        yOffsetMult = 1,
    },
    { -- Bottom
        anchor1 = "TOP",
        anchor2 = "BOTTOM",
        xOffsetMult = 0,
        yOffsetMult = -1,
    },
    { -- Left
        anchor1 = "RIGHT",
        anchor2 = "LEFT",
        xOffsetMult = -1,
        yOffsetMult = 0,
    },
    { -- Right
        anchor1 = "LEFT",
        anchor2 = "RIGHT",
        xOffsetMult = 1,
        yOffsetMult = 0,
    },
    { -- Center
        anchor1 = "CENTER",
        anchor2 = "CENTER",
        xOffsetMult = 0,
        yOffsetMult = 0,
    },
}

local TEXT_OUTLINE_MAPPING = {
    [1] = "",
    [2] = "OUTLINE",
    [3] = "THICKOUTLINE",
}

local function ShortenPortalTextChinese(str)
    local verb, location = str:match("^(到)(.+)的")
    if verb then
        return verb .. location
    end

    verb, location = str:match("^(通往)(.+)的")
    if verb then
        return verb .. location
    end

    verb, location = str:match("^(前往)(.+)的")
    if verb then
        return verb .. location
    end

    return str
end

local PORTAL_TEXT_PATTERNS = {
    deDE = {
        " zu den ",
        " nach ",
        " zum ",
        " ins ",
        " zur ",
    },
    enUS = {
        " to the ",
        " to ",
    },
}
PORTAL_TEXT_PATTERNS["enGB"] = PORTAL_TEXT_PATTERNS["enUS"]

local function ShortenPortalTextGeneric(str)
    local patterns = PORTAL_TEXT_PATTERNS[Private.locale]
    if not patterns then
        return str
    end

    for _, phrase in ipairs(patterns) do
        local i = str:find(phrase, 1, true)
        if i then
            return str:sub(i + #phrase)
        end
    end

    return str
end

local PORTAL_TEXT_HANDLERS = {
    enGB = ShortenPortalTextGeneric,
    enUS = ShortenPortalTextGeneric,
    deDE = ShortenPortalTextGeneric,
    zhCN = ShortenPortalTextChinese,
}

local function ShortenPortalText(str)
    local portalTextHandler = PORTAL_TEXT_HANDLERS[Private.locale]
    if portalTextHandler then
        return portalTextHandler(str)
    else
        return str
    end
end

local TEXT_HANDLERS = {
    zonePortal = ShortenPortalText
}

local function GetHighlightTextString(hlInfo, pinInfo)
    local textHandler = TEXT_HANDLERS[hlInfo.id]
    if not textHandler then
        return pinInfo.name
    else
        return textHandler(pinInfo.name)
    end
end

local function CreateTextFrame()
    local frame = CreateFrame("Frame")
    local text = frame:CreateFontString()
    text:SetShadowOffset(1,-1)
    frame.text = text
    return frame
end

local function ApplyTextSettings(textFrame, highlightDB, pinInfo, pin, hlInfo)
    textFrame:SetSize(pin:GetSize())
    textFrame:SetScale(db.hl.scale)
    local textPosInfo = TEXT_ANCHOR_MAPPING[highlightDB.textPosition]
    local offset = highlightDB.textOffset
    local offsetX = offset * textPosInfo.xOffsetMult
    local offsetY = offset * textPosInfo.yOffsetMult
    local fontSize = db.hl.textSize * highlightDB.textScale
    local font, outline

    textFrame.text:ClearAllPoints()
    textFrame.text:SetPoint(textPosInfo.anchor1, textFrame, textPosInfo.anchor2, offsetX, offsetY)
    textFrame.text:SetVertexColor(unpack(highlightDB.textColor))

    if highlightDB.textCustom then
        font = highlightDB.textFont
        outline = TEXT_OUTLINE_MAPPING[highlightDB.textOutline]
    else
        font = db.hl.font
        outline = TEXT_OUTLINE_MAPPING[db.hl.textOutline]
    end

    local text = GetHighlightTextString(hlInfo, pinInfo)
    textFrame.text:SetFont(LSM:Fetch("font", font), fontSize, outline)
    textFrame.text:SetText(text)
    textFrame:SetAlpha(highlightDB.textAlpha)

end

function Highlights.SetupTextFrame(pin, highlightDB, pinInfo, hlInfo)
    local textFrame = GetHighlightFrame(TEXT_FRAME_POOL, CreateTextFrame)

    textFrame:SetParent(pin)
    textFrame:SetPoint("CENTER")
    textFrame:SetFrameLevel(db.hl.textLevel)

    ApplyTextSettings(textFrame, highlightDB, pinInfo, pin, hlInfo)

    return textFrame
end

function Highlights.ReleaseTextFrame(pin)
    local frame = pinToFrames[pin].textFrame

    if not frame then
        return
    end

    TEXT_FRAME_POOL[frame] = true
    pinToFrames[pin].textFrame = nil
    frame:Hide()
end

------------------
-- Animation Highlight
------------------

local ANIMATION_STYLE_SETTINGS = {
    shrinkFade = {
        time = 1,
        startScale = 3,
        endScale = 1.7,
        idleAlpha = 0,
    },
    growFade = {
        time = 1,
        startScale = 1,
        endScale = 2,
        idleAlpha = 0,
    },
    pulse = {
        time = 0.7,
        endScale = 1.1,
        idleAlpha = 1,
    },
    blink = {
        time = 0.7,
        idleAlpha = 0,
    },
}

local ANIMATION_STYLE_MAPPING = {
    "shrinkFade",
    "growFade",
    "pulse",
    "blink",
}

local ANIMATION_PLAYBACK_MAPPING = {
    {
        playOnClick = true,
        playOnMapOpen = true,
        playOnLoop = false,
        loopType = "NONE"
    },
    {
        playOnClick = false,
        playOnMapOpen = true,
        playOnLoop = false,
        loopType = "NONE"
    },
    {
        playOnClick = true,
        playOnMapOpen = false,
        playOnLoop = false,
        loopType = "NONE"
    },
    {
        playOnClick = true,
        playOnMapOpen = true,
        playOnLoop = true,
        loopType = "REPEAT"
    },
}

local function CreateFadeAnim(frame, animStyle)
    local cfg = ANIMATION_STYLE_SETTINGS[animStyle]

    local anim = frame:CreateAnimationGroup()
    -- first half
    local fadeStart = anim:CreateAnimation("Alpha")
    fadeStart:SetFromAlpha(0)
    fadeStart:SetToAlpha(1)
    fadeStart:SetDuration(cfg.time/2)
    fadeStart:SetOrder(1)
    local scaleStart = anim:CreateAnimation("Scale")
    scaleStart:SetScaleFrom(cfg.startScale, cfg.startScale)
    scaleStart:SetScaleTo(cfg.endScale/2, cfg.endScale/2)
    scaleStart:SetDuration(cfg.time/2)
    scaleStart:SetOrder(1)
    if cfg.rotation then
        local rotationStart = anim:CreateAnimation("Rotation")
        rotationStart:SetDegrees(cfg.rotation/2)
        rotationStart:SetDuration(cfg.time/2)
        rotationStart:SetOrder(1)
    end

    -- second half
    local fadeEnd = anim:CreateAnimation("Alpha")
    fadeEnd:SetFromAlpha(1)
    fadeEnd:SetToAlpha(0)
    fadeEnd:SetDuration(cfg.time/2)
    fadeEnd:SetOrder(2)
    local scaleEnd = anim:CreateAnimation("Scale")
    scaleEnd:SetScale(cfg.endScale, cfg.endScale)
    scaleEnd:SetDuration(cfg.time/2)
    scaleEnd:SetOrder(2)
    scaleEnd:SetSmoothing("OUT")
    if cfg.rotation then
        local rotationEnd = anim:CreateAnimation("Rotation")
        rotationEnd:SetDegrees(cfg.rotation/2)
        rotationEnd:SetDuration(cfg.time/2)
        rotationEnd:SetOrder(2)
    end

    return anim
end


local function CreatePulseAnim(frame, animStyle)
    local cfg = ANIMATION_STYLE_SETTINGS[animStyle]

    local anim = frame:CreateAnimationGroup()
    local scaleUp = anim:CreateAnimation("Scale")
    scaleUp:SetScale(cfg.endScale, cfg.endScale)
    scaleUp:SetDuration(cfg.time/2)
    scaleUp:SetOrder(1)
    scaleUp:SetSmoothing("IN_OUT")
    local scaleDown = anim:CreateAnimation("Scale")
    scaleDown:SetScale(1/cfg.endScale, 1/cfg.endScale)
    scaleDown:SetDuration(cfg.time/2)
    scaleDown:SetOrder(2)
    scaleDown:SetSmoothing("IN_OUT")

    return anim
end

local function CreateBlinkAnim(frame, animStyle)
    local cfg = ANIMATION_STYLE_SETTINGS[animStyle]

    local anim = frame:CreateAnimationGroup()
    -- first half
    local fadeStart = anim:CreateAnimation("Alpha")
    fadeStart:SetFromAlpha(0)
    fadeStart:SetToAlpha(1)
    fadeStart:SetDuration(cfg.time/2)
    fadeStart:SetOrder(1)
    fadeStart:SetSmoothing("OUT")

    -- second half
    local fadeEnd = anim:CreateAnimation("Alpha")
    fadeEnd:SetFromAlpha(1)
    fadeEnd:SetToAlpha(0)
    fadeEnd:SetDuration(cfg.time/2)
    fadeEnd:SetOrder(2)
    fadeEnd:SetSmoothing("IN")

    return anim
end

local function CreateAnimationFrame()
    local frame = CreateFrame("Frame")
    local tex = frame:CreateTexture()
    tex:SetAllPoints()
    frame.texture = tex
    frame:SetAlpha(0)

    frame.shrinkFade = CreateFadeAnim(frame, "shrinkFade")
    frame.growFade = CreateFadeAnim(frame, "growFade")
    frame.pulse = CreatePulseAnim(frame, "pulse")
    frame.blink = CreateBlinkAnim(frame, "blink")

    return frame
end

local function ApplyAnimationSettings(animFrame, highlightDB, pinInfo, pin)
    local animStyle = ANIMATION_STYLE_MAPPING[highlightDB.animStyle]
    local animSettings = ANIMATION_STYLE_SETTINGS[animStyle]
    animFrame.anim = animFrame[animStyle]
    animFrame:SetSize(pin:GetSize())
    animFrame:SetScale(pinInfo.currentScale)
    animFrame:SetAlpha(animSettings.idleAlpha)
    animFrame.texture:SetAtlas(pinInfo.textureName)

    local animPlaybackInfo = ANIMATION_PLAYBACK_MAPPING[highlightDB.animPlayback]
    animFrame.playOnClick = animPlaybackInfo["playOnClick"]
    animFrame.playOnMapOpen = animPlaybackInfo["playOnMapOpen"]
    animFrame.playOnLoop = animPlaybackInfo["playOnLoop"]
    animFrame.anim:SetLooping(animPlaybackInfo["loopType"])

    local blendMode = highlightDB.animGlow and "ADD" or "BLEND"
    animFrame.texture:SetBlendMode(blendMode)
end

function Highlights.SetupAnimationFrame(pin, highlightDB, pinInfo)
    local animFrame = GetHighlightFrame(ANIMATION_FRAME_POOL, CreateAnimationFrame)

    animFrame:SetParent(pin)
    animFrame:SetPoint("CENTER")

    ApplyAnimationSettings(animFrame, highlightDB, pinInfo, pin)

    return animFrame
end

function Highlights.ReleaseAnimationFrame(pin)
    local frame = pinToFrames[pin].animFrame

    if not frame then
        return
    end

    ANIMATION_FRAME_POOL[frame] = true
    pinToFrames[pin].animFrame = nil
    frame:Hide()

    -- on AreaPOI updates, pins get released and reaquired frequently.
    -- this stops looping animations to be stopped (on release) and restarted again.
    -- avoid while options are open cause it'll bug out looping animations if the map is open.
    if Config.isOptionsOpen then
        frame.anim:Stop()
    else
        RunNextFrame(function()
            if ANIMATION_FRAME_POOL[frame] then
                frame.anim:Stop()
            end
        end)
    end
end

function Highlights.PlayAnimation(pin, playCondition)
    if not pinToFrames[pin] then
        return
    end

    local animFrame = pinToFrames[pin].animFrame
    if animFrame and animFrame[playCondition] then
        animFrame.anim:Play()
    end
end

function Highlights.PlayAllAnimations(map, playCondition)
    for pin, frameInfo in pairs(pinToFrames) do
        if pin:GetOwningMap() == map then
            local animFrame = frameInfo.animFrame
            if animFrame and animFrame[playCondition] then
                animFrame.anim:Play()
            end
        end
    end
end

function Highlights.StopAllAnimations(map)
    for pin, frameInfo in pairs(pinToFrames) do
        if pin:GetOwningMap() == map then
            local animFrame = frameInfo.animFrame
            if animFrame then
                animFrame.anim:Stop()
            end
        end
    end
end

function Highlights.PlayAnimationOnAcquired(pin, animFrame, lastAreaPOIUpdate)
    if GetTime() == lastAreaPOIUpdate and not animFrame.playOnLoop then
        return
    end

    if animFrame.anim and animFrame.playOnMapOpen and not pinToFrames[pin] and not animFrame.anim:IsPlaying() then
        -- new pin, play animation
        animFrame.anim:Play()
    end
end

------------------
-- Preview
------------------

function Highlights.SetupPreviewFrame(frame)
    local pinTexture = frame.pin:CreateTexture(nil, "ARTWORK")
    pinTexture:SetPoint("CENTER")
    pinTexture:SetSize(20, 20)

    local pin = frame.pin
    pin.texture = pinTexture

    pin.iconFrame = CreateIconFrame()
    pin.iconFrame:SetParent(pin)
    pin.iconFrame:SetPoint("CENTER")
    pin.iconFrame:SetSize(pin:GetSize())

    pin.textFrame = CreateTextFrame()
    pin.textFrame:SetParent(pin)
    pin.textFrame:SetPoint("CENTER")
    pin.textFrame:SetSize(pin:GetSize())

    pin.animFrame = CreateAnimationFrame()
    pin.animFrame:SetParent(pin)
    pin.animFrame:SetPoint("CENTER")
    pin.animFrame:SetSize(pin:GetSize())

end

local function GetPreviewInfo(selectedId)
    for _, info in pairs(Highlights.textureToInfo) do
        if info.id == selectedId then
            return info.previewTexture, info.name, info.db, info
        end
    end
end

local function TogglePreviewDisabledText(isDisabled)
    local frame = Config.previewFrame.frame
    if isDisabled then
        frame.isDisabledText:Show()
    else
        frame.isDisabledText:Hide()
    end
end

local function ApplyPreviewSettings(pin, selectedId)
    local atlasName, previewName, highlightDB, hlInfo = GetPreviewInfo(selectedId)

    pin.texture:SetAtlas(atlasName, true)
    pin:SetSize(pin.texture:GetSize())
    pin.name = previewName

    local isDisabled = not highlightDB.isEnabled
    TogglePreviewDisabledText(isDisabled)
    if isDisabled then
        return
    end

    local pinInfo = Main.CreatePinInfo(atlasName, pin.texture, "pinType", pin)
    pinInfo.origScale = 1
    Highlights.ApplyScale(pinInfo, highlightDB)

    if pin.animFrame.anim then
        pin.animFrame.anim:Stop()
    end

    pin.animFrame:SetAlpha(0)
    pin.textFrame:SetFrameLevel(db.hl.textLevel)

    if highlightDB.iconShow then
        pin.iconFrame:Show()
        ApplyIconSettings(pin.iconFrame, highlightDB, pinInfo, pin)
    end

    if highlightDB.textShow then
        pin.textFrame:Show()
        ApplyTextSettings(pin.textFrame, highlightDB, pinInfo, pin, hlInfo)
    end

    if highlightDB.animShow then
        pin.animFrame:Show()
        ApplyAnimationSettings(pin.animFrame, highlightDB, pinInfo, pin)
        pin.animFrame.anim:Play()
    end
end

function Highlights.UpdatePreviewHighlights()
    local selectedId = Config.selectedId

    local frame = Config.previewFrame.frame
    local pin = frame.pin

    if selectedId == "" then
        pin:Hide()
        TogglePreviewDisabledText(false)
        return
    end

    pin:Show()
    pin.iconFrame:Hide()
    pin.animFrame:Hide()
    pin.textFrame:Hide()

    ApplyPreviewSettings(pin, selectedId)
end


------------------
-- Debugging
------------------

function Highlights.PrintStats()
    if not debugPrintStats then return end
    print("__________________________________________")
    local count = 0

    local pools = {Icon = ICON_FRAME_POOL, Text = TEXT_FRAME_POOL, Anim = ANIMATION_FRAME_POOL}
    for poolName, pool in pairs(pools) do
        local availableFrames = 0
        count = 0
        for frame, isAvailable in pairs(pool) do
            if isAvailable then
                availableFrames = availableFrames + 1   
            end
            count = count + 1
        end
        print(" ")
        print("Frames in", poolName, "Pool:", count)
        print("  of which are available:", availableFrames)
    end

    print(" ")

    count = 0
    local iconFrameCount = 0
    local textFrameCount = 0
    local animFrameCount = 0
    for pin, pinFrames in pairs(pinToFrames) do
        count = count + 1
        if pinFrames.iconFrame then
            iconFrameCount = iconFrameCount + 1
        end

        if pinFrames.textFrame then
            textFrameCount = textFrameCount + 1 
        end

        if pinFrames.animFrame then
            animFrameCount = animFrameCount + 1
        end
    end
    print("Active Pins:", count)
    print("  Icon-Frames:", iconFrameCount)
    print("  Text-Frames:", textFrameCount)
    print("  Anim-Frames:", animFrameCount)

    print("__________________________________________")
end

function Highlights.PrintIcons(mapFrame)
    if not debugPrintIcons then return end

    if not mapFrame or not mapFrame:IsShown() then
        return
    end

    local iconInfo = {}

    local frame = mapFrame.ScrollContainer.Child
    local children = {frame:GetChildren()}
    print("__________________________________________")
    for _, child in ipairs(children) do
        if child.pinTemplate then
            local texture = (child.Icon and child.Icon:GetAtlas())
                    or (child.Texture and child.Texture:GetAtlas())
                    or (child.UnderlayAtlas and child.UnderlayAtlas:GetAtlas())
            if texture and not Highlights.textureToInfo[texture] then
                iconInfo[texture] = iconInfo[texture] or {
                    templates = {},
                    names = {},
                }
                local name = child.poiInfo and child.poiInfo.name or child.name
                iconInfo[texture].templates[child.pinTemplate] = true
                tinsert(iconInfo[texture].names, name)
            end
        end
    end

    for texture, info in pairs(iconInfo) do

        print("tex:", texture)
        for template in pairs(info.templates) do
            print(" template:", template)
        end

        for _, name in ipairs(info.names) do
            print(" name:", name)
        end
        print("----------")
    end

end
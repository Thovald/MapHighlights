local _, Private = ...
local Main = Private.Main
local PlayerLocation = Private.PlayerLocation
local db

local playerHighlightFrames = {}
local ARROW_SIZE = 17
local LINE_THICKNESS
local LINE_LENGTH_SCALE -- 1 means full length of map's diagonal

local IsFlying, math = IsFlying, math

function PlayerLocation.UpdateDB()
    db = Private.db.profile
    PlayerLocation.OnSettingsChanged()
end

function PlayerLocation.OnSettingsChanged(args)
    LINE_THICKNESS = db.other.directionThickness
    LINE_LENGTH_SCALE = db.other.directionScale
    for map, frame in pairs(playerHighlightFrames) do
        if Main.IsValidMap(map) then
            PlayerLocation.ShowHighlight(map, args)
        else
            PlayerLocation.HideHighlight(map, "all")
        end
    end
end

function PlayerLocation.HideHighlight(map, type)
    local frame = playerHighlightFrames[map]

    if not frame then
        return
    end

    if type == "all" then
        frame.OnUpdate = nil
        frame:Hide()
        frame.line:Hide()
    end

    -- hiding just the arrow when location animation finishes
    if type == "all" or type == "arrow" then
        frame.arrow.animStart:Stop()
        frame.arrow.animEnd:Stop()
        frame.arrow:SetScale(1)
        frame.arrow:Hide()
    end
end

local function UpdateHighlight(frame)
    local mapId = frame.mapFrame:GetMapID()
    if not mapId then
        PlayerLocation.HideHighlight(frame.mapFrame, "all")
        return
    end

    local playerPos = C_Map.GetPlayerMapPosition(mapId, "player")
    if not playerPos then
        PlayerLocation.HideHighlight(frame.mapFrame, "all")
        return
    end

    local parent = frame.parent
    local x, y = playerPos:GetXY()
    local width, height = parent:GetSize()
    local angle = GetPlayerFacing() or 0
    if parent.viewRect then
        local v = parent.viewRect
        x = (x - v.left) / (v.right - v.left)
        y = (y - v.top) / (v.bottom - v.top)
    end
    x = x * width
    y = y * height * -1
    frame:SetPointsOffset(x,y)

    local scale = frame.parent:GetEffectiveScale() * frame.extraScale
    if scale ~= frame.lastScale then
        frame.scale = scale
        PlayerLocation.UpdateHighlightProperties(frame)
    end

    if frame.showArrow then
        frame.arrow.texture:SetRotation(angle)
    end

    if frame.showDirection then
        local lineLength = 0
        if frame.showDirectionAlways or IsFlying() then
            lineLength = math.sqrt(width * width + height * height) * LINE_LENGTH_SCALE
        end
        angle = angle + 1.57 -- is off by 90°
        local ex, ey = math.cos(angle) *  lineLength, math.sin(angle) * lineLength
        frame.line:SetStartPoint("CENTER", frame, 0, 0)
        frame.line:SetEndPoint("CENTER", frame, ex, ey)
    end

end

local function CreatePlayerLocationAnimation(frame, map)
    local arrow = frame.arrow
    local introTime = 0.5
    local bounceTime = 0.7

    -- scale in
    local animStart = arrow:CreateAnimationGroup()
    local scaleStart = animStart:CreateAnimation("Scale")
    scaleStart:SetScaleFrom(4, 4)
    scaleStart:SetDuration(introTime)
    scaleStart:SetSmoothing("OUT")
    local fadeStart = animStart:CreateAnimation("Alpha")
    fadeStart:SetFromAlpha(0)
    fadeStart:SetToAlpha(1)
    fadeStart:SetDuration(introTime)
    fadeStart:SetSmoothing("OUT")

    -- couldn't get "BOUNCE" to loop smoothly - using "REPEAT" instead
    local animEnd = arrow:CreateAnimationGroup()
    animEnd:SetLooping("REPEAT")
    local scaleUp = animEnd:CreateAnimation("Scale")
    scaleUp:SetScale(1.2, 1.2)
    scaleUp:SetDuration(bounceTime/2)
    scaleUp:SetOrder(1)
    scaleUp:SetSmoothing("IN_OUT")
    local scaleDown = animEnd:CreateAnimation("Scale")
    scaleDown:SetScale(1/1.2, 1/1.2)
    scaleDown:SetDuration(bounceTime/2)
    scaleDown:SetOrder(2)
    scaleDown:SetSmoothing("IN_OUT")

    arrow.animStart = animStart
    arrow.animEnd = animEnd

    animStart:SetScript("OnFinished", function()
        animEnd:Play()
        local startTime = arrow.startTime

        C_Timer.After(bounceTime * 3, function()
            if startTime ~= arrow.startTime then
                return
            end

            if Private.db.profile.other.playerDirection then
                PlayerLocation.HideHighlight(map, "arrow")
            else
                PlayerLocation.HideHighlight(map, "all")
            end
        end)
    end)

end

local function CreatePlayerHighlight(map)
    local pinContainer = map.ScrollContainer.Child

    -- base "frame" to handle only position.
    local frame = CreateFrame("Frame", nil, pinContainer)
    frame:SetParent(pinContainer)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(2400)
    frame:SetPoint("CENTER", pinContainer, "TOPLEFT")
    frame:SetSize(20,20) -- doesn't matter, but needs to be set for line to show

    -- arrow's size depends on map conditions and is set elsewhere
    local arrow = CreateFrame("Frame", nil, frame)
    arrow:SetFrameLevel(3000)
    arrow:SetPoint("CENTER")
    local arrowTex = arrow:CreateTexture()
    arrowTex:SetAllPoints()
    arrowTex:SetAtlas("UI-WorldMapArrow")
    arrow.texture = arrowTex
    frame.arrow = arrow

    -- line thickness and length is the same deal as arrow size
    local line = frame:CreateLine(nil, "OVERLAY", nil, 7)
    line:SetTexture('interface/buttons/white8x8')
    frame.line = line

    CreatePlayerLocationAnimation(frame, map)

    if map:GetDebugName() == "BattlefieldMapFrame" then
        frame.extraScale = 2
        frame:SetFrameLevel(2000)
    else
        frame.extraScale = 1
    end

    frame.mapFrame = map
    frame.parent = pinContainer
    playerHighlightFrames[map] = frame
    return frame
end

function PlayerLocation.UpdateHighlightProperties(frame)
    local scale = frame.scale
    frame.arrow:SetSize(ARROW_SIZE/scale, ARROW_SIZE/scale)
    frame.line:SetThickness(LINE_THICKNESS/scale)
    frame.lastScale = scale

    local startColor = CreateColor(unpack(db.other.directionStartColor))
    local endColor = CreateColor(unpack(db.other.directionEndColor))
    frame.line:SetGradient('HORIZONTAL', startColor, endColor)
end

function PlayerLocation.ShowHighlight(map, args)
    args = args or {}
    local showArrow = Private.db.profile.other.playerHighlight
    local showDirection = Private.db.profile.other.playerDirection ~= 1

    if not showArrow and not showDirection then
        return
    end

    local playerHighlight = playerHighlightFrames[map]

    if not playerHighlight then
        playerHighlight = CreatePlayerHighlight(map)
    end

    playerHighlight:Show()

    if showArrow and not args.ignoreArrow then
        playerHighlight.showArrow = true
        playerHighlight.arrow:Show()
        playerHighlight.arrow.animStart:Play()
        playerHighlight.arrow.startTime = GetTime()
    else
        playerHighlight.showArrow = false
        playerHighlight.arrow:Hide()
    end

    if showDirection then
        playerHighlight.showDirection = true
        playerHighlight.showDirectionAlways = Private.db.profile.other.playerDirection == 2
        playerHighlight.line:Show()
    else
        playerHighlight.showDirection = false
        playerHighlight.line:Hide()
    end

    playerHighlight:SetScript("OnUpdate", UpdateHighlight)
    playerHighlight.scale = playerHighlight.parent:GetEffectiveScale()
    PlayerLocation.UpdateHighlightProperties(playerHighlight)
end
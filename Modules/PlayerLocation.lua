local _, Private = ...
local PlayerLocation = Private.PlayerLocation
local db

local playerHighlightFrames = {}

function PlayerLocation.UpdateDB()
    db = Private.db.profile
end

function PlayerLocation.HideHighlight(map)
    local playerHighlight = playerHighlightFrames[map]

    if not playerHighlight then
        return
    end

    playerHighlight.OnUpdate = nil
    playerHighlight.animStart:Stop()
    playerHighlight.animEnd:Stop()
    playerHighlight:SetScale(1)
    playerHighlight:Hide()
end

local function UpdateHighlight(self)
    local mapId = self.mapFrame:GetMapID()
    if not mapId then
        PlayerLocation.HideHighlight(self.mapFrame)
        return
    end

    local playerPos = C_Map.GetPlayerMapPosition(mapId, "player")
    if not playerPos then
        PlayerLocation.HideHighlight(self.mapFrame)
        return
    end

    local mapFrame = self.mapFrame.ScrollContainer
    local x, y = playerPos:GetXY()

    local width, height = mapFrame:GetSize()
    if mapFrame.viewRect then
        local v = mapFrame.viewRect
        x = (x - v.left) / (v.right - v.left)
        y = (y - v.top) / (v.bottom - v.top)
    end
    x = x * width
    y = y * height
    self:SetPointsOffset(x,-y)
    self.texture:SetRotation(GetPlayerFacing() or 0)
end

local function CreatePlayerLocationAnimation(frame, map)
    local introTime = 0.5
    local bounceTime = 0.7

    -- scale in
    local animStart = frame:CreateAnimationGroup()
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
    local animEnd = frame:CreateAnimationGroup()
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

    frame.animStart = animStart
    frame.animEnd = animEnd

    animStart:SetScript("OnFinished", function()
        animEnd:Play()
        local startTime = frame.startTime

        C_Timer.After(bounceTime * 3, function()
            if startTime ~= frame.startTime then
                return
            end
            PlayerLocation.HideHighlight(map)
        end)
    end)

end

local function CreatePlayerHighlight(map)
    local frame = CreateFrame("Frame")
    frame:SetSize(28, 28)
    local tex = frame:CreateTexture()
    tex:SetAtlas("UI-WorldMapArrow")
    tex:SetAllPoints()
    frame.texture = tex

    local mapFrame = map.ScrollContainer
    frame:SetParent(mapFrame)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(9000)
    frame:SetPoint("CENTER", mapFrame, "TOPLEFT")

    CreatePlayerLocationAnimation(frame, map)

    frame.mapFrame = map
    playerHighlightFrames[map] = frame
    return frame
end

function PlayerLocation.ShowHighlight(map)
    if not Private.db.profile.other.playerHighlight then
        return
    end

    local playerHighlight = playerHighlightFrames[map]

    if not playerHighlight then
        playerHighlight = CreatePlayerHighlight(map)
    end

    playerHighlight:Show()
    playerHighlight.animStart:Play()
    playerHighlight:SetScript("OnUpdate", UpdateHighlight)
    playerHighlight.startTime = GetTime()
end
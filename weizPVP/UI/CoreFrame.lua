---------------------------------------------------------------------------------------------------
--|> CoreFrame
-- 📌 Creates and updates the addon frames and widgets
---------------------------------------------------------------------------------------------------
--: ⬆️ Upvalues :--
local _, NS = ...
local unpack = unpack
local pairs = pairs
local UnitGUID = UnitGUID
local floor = floor
local IsControlKeyDown = IsControlKeyDown
local Round = Round
local InCombatLockdown = InCombatLockdown
local CreateColor = CreateColor
local C_Timer_After = C_Timer.After

--: Core UI Table Init
NS.CoreUI = NS.CoreUI or {}

--|> LIBS
-----------------------------------------------------------
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

--|> Tooltip
-----------------------------------------------------------
weizPVP_CoreTooltip = weizPVP_CoreTooltip or CreateFrame("GameTooltip", "weizPVP_CoreTooltip", UIParent, "GameTooltipTemplate")

--|> Local functions
-----------------------------------------------------------
--> Show Header Tooltip
local pinStat = ""
local lockStat
local inCombat = ""
local joinString = "|cffbbbbbb - |r"
local function showHeaderToolTip()
    pinStat = ""
    lockStat = ""
    inCombat = ""
    if NS.Options.Window.Locked then
        lockStat = "Unlock"
    else
        lockStat = "Lock"
    end
    if NS.Options.Window.Pinned then
        pinStat = "Unpin"
    else
        pinStat = "Pin"
    end
    if InCombatLockdown() then
        inCombat = NS.Constants.InCombat
    end
    -- : Build Tooltip
    weizPVP_CoreTooltip:SetOwner(weizPVP_CoreBar, "ANCHOR_TOPLEFT")
    weizPVP_CoreTooltip:AddDoubleLine(NS.Constants.AddonString, inCombat)
    if NS.Options.Window.Pinned then
        weizPVP_CoreTooltip:AddLine(NS.ColorsLUT["uiMouse"]:WrapTextInColorCode("Right-Click") .. joinString .. pinStat)
    elseif NS.Options.Window.Locked then
        weizPVP_CoreTooltip:AddLine(
        NS.ColorsLUT["uiMouse"]:WrapTextInColorCode("Ctrl + Right-Click") .. joinString .. lockStat
        )
    else
        weizPVP_CoreTooltip:AddLine(NS.ColorsLUT["uiMouse"]:WrapTextInColorCode("Right-Click") .. joinString .. pinStat)
        weizPVP_CoreTooltip:AddLine(
        NS.ColorsLUT["uiMouse"]:WrapTextInColorCode("Ctrl + Right-Click") .. joinString .. lockStat
        )
    end
    weizPVP_CoreTooltip:Show()
end

--> Adjust Scroll Offset
-----------------------------------------------------------
local function AdustScrollOffset(value)
    if not InCombatLockdown() then
        local vertScroll = weizPVP_CoreFrame.ScrollFrame:GetVerticalScroll()
        local rowHeight = NS.CoreUI.Bar[1].Button:GetHeight()
        local offsetMax = weizPVP_CoreFrame.ScrollFrame.ListFrame:GetHeight() - weizPVP_CoreFrame.ScrollFrame:GetHeight()
        local numPlayersOnBars = 0
        for _ in pairs(NS.PlayersOnBars) do
            numPlayersOnBars = numPlayersOnBars + 1
        end
        local barsInDisplay = floor(weizPVP_CoreFrame:GetHeight() / rowHeight)
        local rawCalc = weizPVP_CoreFrame:GetHeight() / rowHeight
        if rawCalc - barsInDisplay >= .5 then
            barsInDisplay = barsInDisplay + 1
        end
        if barsInDisplay < 1 then
            barsInDisplay = 1
        end
        local minVerticalScroll = (numPlayersOnBars - barsInDisplay) * rowHeight
        if minVerticalScroll < 0 then
            minVerticalScroll = 0
        end
        local offset
        if value > 0 then
            offset = vertScroll - (rowHeight)
        else
            offset = vertScroll + (rowHeight)
        end
        if offset < 0 then
            weizPVP_CoreFrame.ScrollFrame:SetVerticalScroll(0)
        elseif offset > offsetMax then
            weizPVP_CoreFrame.ScrollFrame:SetVerticalScroll(offsetMax)
        elseif minVerticalScroll < offset then
            weizPVP_CoreFrame.ScrollFrame:SetVerticalScroll(minVerticalScroll)
        else
            weizPVP_CoreFrame.ScrollFrame:SetVerticalScroll(offset)
        end
    end
end

--> Auto Vertical Scroll
-----------------------------------------------------------
local frameHeight
local rowHeight
local rawCalc
local barsInDisplay
local numPlayersOnBars
local minVerticalScroll

local function AutoVerticalScroll()
    if not InCombatLockdown() then
        frameHeight = weizPVP_CoreFrame.ScrollFrame:GetHeight()
        rowHeight = NS.Options.Bars.RowHeight + NS.Options.Bars.VerticalSpacing
        rawCalc = frameHeight / rowHeight
        barsInDisplay = floor(frameHeight / rowHeight)
        if rawCalc - barsInDisplay >= .5 then
            barsInDisplay = barsInDisplay + 1
        end
        if barsInDisplay < 1 then
            barsInDisplay = 1
        end
        numPlayersOnBars = 0
        for _ in pairs(NS.PlayersOnBars) do
            numPlayersOnBars = numPlayersOnBars + 1
        end
        minVerticalScroll = (numPlayersOnBars - barsInDisplay) * rowHeight
        if barsInDisplay > numPlayersOnBars then
            weizPVP_CoreFrame.ScrollFrame:SetVerticalScroll(0)
        elseif minVerticalScroll < weizPVP_CoreFrame.ScrollFrame:GetVerticalScroll() then
            weizPVP_CoreFrame.ScrollFrame:SetVerticalScroll(minVerticalScroll)
        end
    end
end

--> Snap Height to Bars
-----------------------------------------------------------
local function SnapHeightToBars()
    if not InCombatLockdown() then
        rowHeight = NS.Options.Bars.RowHeight + NS.Options.Bars.VerticalSpacing
        frameHeight = weizPVP_CoreFrame.ScrollFrame:GetHeight()
        rawCalc = frameHeight / rowHeight
        barsInDisplay = floor(frameHeight / rowHeight)
        if rawCalc - barsInDisplay >= .5 then
            barsInDisplay = barsInDisplay + 1
        end
        if barsInDisplay < 1 then
            barsInDisplay = 1
        end
        weizPVP_CoreFrame:SetHeight((barsInDisplay * rowHeight) + NS.Options.Frames.Header.Height - 1)
        AutoVerticalScroll()
        NS.SaveCoreFramePosition()
    end
end

--|> Core Bar
-----------------------------------------------------------
--> Init
local function CoreBarInit()
    --> CoreBar
    do
        weizPVP_CoreBar:RegisterForDrag("LeftButton")
        weizPVP_CoreBar.BG:SetVertexColor(
        NS.Options.Frames.Header.BackgroundColor.r,
            NS.Options.Frames.Header.BackgroundColor.g,
            NS.Options.Frames.Header.BackgroundColor.b
        )
        weizPVP_CoreBar:SetHeight(NS.Options.Frames.Header.Height)
        weizPVP_CoreBar:SetFrameLevel(8)

        --> Scripts
        function weizPVP_CoreBar:DragStart()
            if (not NS.Options.Window.Pinned) and (not NS.Options.Window.Locked) then
                weizPVP_CoreFrame:StartMoving()
                self.moving = true
            elseif NS.Options.Window.Locked then
                NS.CoreUI.SetIcon("lock")
                NS.CoreUI.FlashTitleBar("lightGrey")
            else
                NS.CoreUI.SetIcon("pin")
                NS.CoreUI.FlashTitleBar("lightGrey")
            end
        end

        function weizPVP_CoreBar:DragStop()
            weizPVP_CoreFrame:StopMovingOrSizing()
            self.moving = nil
            NS.SaveCoreFramePosition()
            NS.SetCoreFramePosition()
            if self:IsMouseOver() then
                showHeaderToolTip()
            end
        end

        function weizPVP_CoreBar:MouseUp(button)
            if button == "LeftButton" then
                if self.moving then
                    self:StopMovingOrSizing()
                    self.moving = nil
                    NS.SaveCoreFramePosition()
                end
            end
            if self:IsMouseOver() and button == "RightButton" then
                if IsControlKeyDown() then
                    NS.CoreUI.ToggleLock()
                    showHeaderToolTip()
                else
                    if not NS.Options.Window.Locked then
                        NS.CoreUI.TogglePin()
                        showHeaderToolTip()
                    end
                end
            end
        end

        function weizPVP_CoreBar:MouseEnter()
            if not self.moving then
                showHeaderToolTip()
            end
        end

        function weizPVP_CoreBar:MouseLeave()
            if weizPVP_CoreTooltip:GetOwner() == self then
                weizPVP_CoreTooltip:Hide()
            end
        end
    end

    -- : local reused vars
    local spacer = Round(NS.Options.Frames.Header.Height / 3)
    local spacerHalf = Round(NS.Options.Frames.Header.Height / 6)

    --> Status Icon
    do
        weizPVP_CoreBar.StatusIcon:ClearAllPoints()
        weizPVP_CoreBar.StatusIcon:SetPoint("TOPLEFT", weizPVP_CoreBar, "TOPLEFT", NS.Options.Frames.BorderSize * 4, 0)
        weizPVP_CoreBar.StatusIcon.AddonIcon:SetSize(NS.Options.Frames.Header.Height, NS.Options.Frames.Header.Height)
        weizPVP_CoreBar.StatusIcon.AddonIcon:SetSize(NS.Options.Frames.Header.Height, NS.Options.Frames.Header.Height)

        -- : State Glyph
        --> Status Icon
        weizPVP_CoreBar.StatusIcon.StateGlyph:SetFont(
        "Interface/Addons/weizPVP/Media/Fonts/WeizGlyphs.ttf",
            NS.Options.Frames.Header.Height - Round(NS.Options.Frames.Header.Height / 8),
            "OUTLINE"
        )
        weizPVP_CoreBar.StatusIcon.StateGlyph:ClearAllPoints()
        weizPVP_CoreBar.StatusIcon.StateGlyph:SetHeight(NS.Options.Frames.Header.Height)
        weizPVP_CoreBar.StatusIcon.StateGlyph:SetWidth(NS.Options.Frames.Header.Height)
        weizPVP_CoreBar.StatusIcon.StateGlyph:SetPoint(
        "TOPLEFT",
            weizPVP_CoreBar,
            "TOPLEFT",
            NS.Options.Frames.BorderSize * 4,
            0
        )
    end

    --> Title (Nearby Count)
    weizPVP_CoreBar.Title:SetFont(
    SM:Fetch("font", NS.Options.Frames.Header.Font),
        NS.Options.Frames.Header.Height - Round(NS.Options.Frames.Header.Height / 4),
        "OUTLINE"
    )
    weizPVP_CoreBar.TitleFrame = CreateFrame("Frame")
    weizPVP_CoreBar.TitleFrame:SetParent(weizPVP_CoreBar)
    weizPVP_CoreBar.TitleFrame:SetAllPoints(weizPVP_CoreBar.Title)
    -- : Title-OnEnter
    weizPVP_CoreBar.TitleFrame:SetScript(
    "OnEnter",
        function()
            weizPVP_CoreTooltip:SetOwner(weizPVP_CoreBar, "ANCHOR_TOPLEFT")
            weizPVP_CoreTooltip:SetText(weizPVP_CoreBar.Title:GetText() .. " |cffffffff Enemies nearby|r")
            weizPVP_CoreTooltip:Show()
        end
    )
    -- : Title-OnLeave
    weizPVP_CoreBar.TitleFrame:SetScript(
    "OnLeave",
        function()
            if weizPVP_CoreTooltip:GetOwner() == weizPVP_CoreBar then
                weizPVP_CoreTooltip:Hide()
            else
                weizPVP_CoreTooltip:SetOwner(weizPVP_CoreBar, "ANCHOR_TOPLEFT")
                weizPVP_CoreTooltip:Hide()
            end
        end
    )
    --: separator
    weizPVP_CoreBar.Separator:SetFont(
    SM:Fetch("font", NS.Options.Frames.Header.Font),
        NS.Options.Frames.Header.Height - spacer,
        "OUTLINE"
    )
    weizPVP_CoreBar.Separator:SetText(":")
    weizPVP_CoreBar.Separator:SetPoint("TOP", weizPVP_CoreBar, "TOP", 0, 0)

    --> Expander Button
    do
        weizPVP_CoreBar.ExpanderButton:ClearAllPoints()
        weizPVP_CoreBar.ExpanderButton:SetPoint("RIGHT", weizPVP_CoreBar, "RIGHT", -spacer, 0)
        weizPVP_CoreBar.ExpanderButton:SetHeight(NS.Options.Frames.Header.Height - spacer)
        weizPVP_CoreBar.ExpanderButton:SetWidth(NS.Options.Frames.Header.Height - spacer)
        weizPVP_CoreBar.ExpanderButton:SetHitRectInsets(-(spacerHalf / 2), -spacer, -spacerHalf, -spacerHalf)
        weizPVP_CoreBar.ExpanderButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7)
        weizPVP_CoreBar.ExpanderButton:GetHighlightTexture():SetVertexColor(1, 1, 1)
        -- : OnMouseDown
        weizPVP_CoreBar.ExpanderButton:SetScript(
        "OnMouseUp",
            function(self, button)
                if not InCombatLockdown() then
                    weizPVP_CoreTooltip:SetOwner(weizPVP_CoreBar, "ANCHOR_TOPRIGHT")
                    if NS.Options.Window.Collapsed then -- : collapse to expand
                        if button == "LeftButton" then
                            self.textureRotation = 0
                            self:StopAnimating()
                            self.FadeIn:Play()
                            NS.CoreUI.ExpandFrame()
                            weizPVP_CoreTooltip:SetText("Collapse")
                        end
                    else -- : expand to collapse
                        if button == "LeftButton" then
                            self.textureRotation = 3.14159
                            self:StopAnimating()
                            self.FadeIn:Play()
                            NS.CoreUI.CollapseFrame()
                            weizPVP_CoreTooltip:SetText("Expand")
                        end
                    end
                    weizPVP_CoreTooltip:Show()
                end
            end
        )
        -- : OnEnter
        weizPVP_CoreBar.ExpanderButton:SetScript(
        "OnEnter",
            function()
                weizPVP_CoreTooltip:SetOwner(weizPVP_CoreBar, "ANCHOR_TOPRIGHT")
                if NS.Options.Window.Collapsed then
                    weizPVP_CoreTooltip:SetText("Expand")
                else
                    weizPVP_CoreTooltip:SetText("Collapse")
                end
                weizPVP_CoreTooltip:Show()
            end
        )
        -- : OnLeave
        weizPVP_CoreBar.ExpanderButton:SetScript(
        "OnLeave",
            function()
                if weizPVP_CoreTooltip:GetOwner() == weizPVP_CoreBar then
                    weizPVP_CoreTooltip:Hide()
                else
                    weizPVP_CoreTooltip:SetOwner(weizPVP_CoreBar, "ANCHOR_TOPRIGHT")
                    weizPVP_CoreTooltip:Hide()
                end
            end
        )
    end

    --> Clear List
    do
        weizPVP_CoreBar.ClearListButton:ClearAllPoints()
        weizPVP_CoreBar.ClearListButton:SetPoint("RIGHT", weizPVP_CoreBar.ExpanderButton, "LEFT", -spacerHalf, 0)
        weizPVP_CoreBar.ClearListButton:SetHeight(weizPVP_CoreBar.ExpanderButton:GetHeight())
        weizPVP_CoreBar.ClearListButton:SetWidth(weizPVP_CoreBar.ExpanderButton:GetWidth())
        weizPVP_CoreBar.ClearListButton:SetHitRectInsets(-spacerHalf, -(spacerHalf / 2), -spacerHalf, -spacerHalf)
        weizPVP_CoreBar.ClearListButton:GetNormalTexture():SetVertexColor(0.8, 0.5, 0) -- 0.9, 0.6, 0
        weizPVP_CoreBar.ClearListButton:GetHighlightTexture():SetVertexColor(1, 0.65, 0)
        weizPVP_CoreBar.ClearListButton:SetScript(
        "OnMouseDown",
            function(self, button)
                if button == "LeftButton" then
                    NS.ClearListData()
                    self.ClearAnim:Play()
                end
            end
        )
        weizPVP_CoreBar.ClearListButton:SetScript(
        "OnEnter",
            function()
                weizPVP_CoreTooltip:SetOwner(weizPVP_CoreBar, "ANCHOR_TOPRIGHT")
                weizPVP_CoreTooltip:SetText("Clear List")
                weizPVP_CoreTooltip:Show()
            end
        )
        weizPVP_CoreBar.ClearListButton:SetScript(
        "OnLeave",
            function()
                weizPVP_CoreTooltip:Hide()
            end
        )
    end

    --> Set CoreBar insets
    local insetValue = Round((weizPVP_CoreBar.ExpanderButton:GetWidth() * 2) + (spacerHalf * 3))
    insetValue = insetValue or 40
    weizPVP_CoreBar:SetHitRectInsets(0, insetValue, 0, 0)

    -- : Status Highlight
    local highlightColor = "lightGrey"
    weizPVP_CoreBar.StatusHeader.Highlight.grad:SetGradient(
    "HORIZONTAL",
        CreateColor(
            NS.ColorsLUT[highlightColor].r,
            NS.ColorsLUT[highlightColor].g,
            NS.ColorsLUT[highlightColor].b,
            0
        ),
        CreateColor(
            NS.ColorsLUT[highlightColor].r,
            NS.ColorsLUT[highlightColor].g,
            NS.ColorsLUT[highlightColor].b,
            0.4
       )
    )

    weizPVP_CoreBar.StatusHeader.Highlight.grad:ClearAllPoints()
    weizPVP_CoreBar.StatusHeader.Highlight.grad:SetPoint("TOP", weizPVP_CoreBar, "TOP", 0, -1)
    weizPVP_CoreBar.StatusHeader.Highlight.grad:SetPoint("BOTTOM", weizPVP_CoreBar, "BOTTOM", 0, 1)
    weizPVP_CoreBar.StatusHeader.Highlight.grad:SetPoint("LEFT", weizPVP_CoreBar, "LEFT")
    weizPVP_CoreBar.StatusHeader.Highlight.grad:SetPoint("RIGHT", weizPVP_CoreBar.Separator, "CENTER")
    weizPVP_CoreBar.StatusHeader.Highlight.grad2:SetGradient(
    "HORIZONTAL",
        CreateColor(
            NS.ColorsLUT[highlightColor].r,
            NS.ColorsLUT[highlightColor].g,
            NS.ColorsLUT[highlightColor].b,
            0.4
        ),
        CreateColor(
            NS.ColorsLUT[highlightColor].r,
            NS.ColorsLUT[highlightColor].g,
            NS.ColorsLUT[highlightColor].b,
            0
        )
    )
    weizPVP_CoreBar.StatusHeader.Highlight.grad2:ClearAllPoints()
    weizPVP_CoreBar.StatusHeader.Highlight.grad2:SetPoint("TOP", weizPVP_CoreBar, "TOP", 0, -1)
    weizPVP_CoreBar.StatusHeader.Highlight.grad2:SetPoint("BOTTOM", weizPVP_CoreBar, "BOTTOM", 0, 1)
    weizPVP_CoreBar.StatusHeader.Highlight.grad2:SetPoint("LEFT", weizPVP_CoreBar.Separator, "CENTER")
    weizPVP_CoreBar.StatusHeader.Highlight.grad2:SetPoint("RIGHT", weizPVP_CoreBar, "CENTER")

    --|> CORE FRAME
    if weizPVP_CoreFrame.SetResizeBounds then -- WoW 10.0
        weizPVP_CoreFrame:SetResizeBounds(140, NS.Options.Bars.RowHeight + NS.Options.Frames.Header.Height)
        weizPVP_CoreFrame:SetResizeBounds(140, 1, 600, ((NS.Options.Bars.RowHeight + NS.Options.Bars.VerticalSpacing) * NS.Options.Bars.MaxNumBars) + NS.Options.Frames.Header.Height - 1)
    else
        weizPVP_CoreFrame:SetMinResize(140, NS.Options.Bars.RowHeight + NS.Options.Frames.Header.Height)
        weizPVP_CoreFrame:SetMaxResize(600, ((NS.Options.Bars.RowHeight + NS.Options.Bars.VerticalSpacing) * NS.Options.Bars.MaxNumBars) + NS.Options.Frames.Header.Height - 1)
    end

    weizPVP_CoreFrame:EnableMouse(false)

    --> Scroll Frame
    do
        weizPVP_CoreFrame.ScrollFrame.BG:SetVertexColor(
        NS.Options.Frames.BackgroundColor.r,
            NS.Options.Frames.BackgroundColor.g,
            NS.Options.Frames.BackgroundColor.b
        )
        weizPVP_CoreFrame.ScrollFrame.BG:SetAlpha(NS.Options.Frames.BackgroundColor.a)
        weizPVP_CoreFrame.ScrollFrame:SetPoint(
        "TOP",
            weizPVP_CoreFrame,
            "TOP",
            0,
            -NS.Options.Frames.Header.Height + NS.Options.Frames.BorderSize
        )
        weizPVP_CoreFrame.ScrollFrame:EnableMouse(false)

        -- : ScrollFrame: On Mouse Wheel
        weizPVP_CoreFrame.ScrollFrame:SetScript(
        "OnMouseWheel",
            function(_, value)
                AdustScrollOffset(value)
            end
        )

        -- : ListFrame - (ScrollFrame's Scroll Child)
        weizPVP_CoreFrame.ScrollFrame.ListFrame:ClearAllPoints()
        weizPVP_CoreFrame.ScrollFrame.ListFrame:SetPoint("CENTER", weizPVP_CoreFrame.ScrollFrame, "CENTER")
        weizPVP_CoreFrame.ScrollFrame.ListFrame:SetPoint(
        "TOP",
            weizPVP_CoreFrame,
            "TOP",
            0,
            -NS.Options.Frames.Header.Height
        )
        weizPVP_CoreFrame.ScrollFrame.ListFrame:SetWidth(weizPVP_CoreFrame.ScrollFrame:GetWidth())
        weizPVP_CoreFrame.ScrollFrame.ListFrame:SetHeight(NS.Options.Frames.List.Height)

        -- : Set ListFrame as scroll child to ScrollFrame
        weizPVP_CoreFrame.ScrollFrame:SetScrollChild(weizPVP_CoreFrame.ScrollFrame.ListFrame)
    end

    --> Resize BottomRight
    do
        weizPVP_CoreFrame.ResizeBottomRight:GetNormalTexture():SetVertexColor(1, 1, 1, 0.1)
        weizPVP_CoreFrame.ResizeBottomRight:GetHighlightTexture():SetVertexColor(1, 0.8, 0, 1)

        -- : OnMouseDown
        weizPVP_CoreFrame.ResizeBottomRight:SetScript(
        "OnMouseDown",
            function()
                if (not NS.Options.Window.Locked) then
                    weizPVP_CoreFrame.resizing = true
                    weizPVP_CoreFrame:StartSizing("BOTTOMRIGHT")
                elseif NS.Options.Window.Locked then
                    NS.CoreUI.SetIcon("lock")
                end
            end
        )

        -- : OnMouseUp
        weizPVP_CoreFrame.ResizeBottomRight:SetScript(
        "OnMouseUp",
            function(_, button)
                if (button == "LeftButton") then
                    if not NS.Options.Window.Locked then
                        if weizPVP_CoreFrame.resizing then
                            weizPVP_CoreFrame:StopMovingOrSizing()
                            weizPVP_CoreFrame.resizing = nil
                            NS.SaveCoreFramePosition()
                            NS.SetCoreFramePosition()
                            SnapHeightToBars()
                        end
                        NS.RefreshCurrentList()
                    end
                end
            end
        )
    end

    --> Resize BottomLeft
    do
        weizPVP_CoreFrame.ResizeBottomLeft:GetNormalTexture():SetVertexColor(1, 1, 1, 0.1)
        weizPVP_CoreFrame.ResizeBottomLeft:GetHighlightTexture():SetVertexColor(1, 0.8, 0, 1)
        weizPVP_CoreFrame.ResizeBottomLeft:GetNormalTexture():SetTexCoord(1, 0, 0, 1)
        weizPVP_CoreFrame.ResizeBottomLeft:GetHighlightTexture():SetTexCoord(1, 0, 0, 1)

        -- : OnMouseDown
        weizPVP_CoreFrame.ResizeBottomLeft:SetScript(
        "OnMouseDown",
            function(_, button)
                if (not NS.Options.Window.Locked) and button == "LeftButton" then
                    weizPVP_CoreFrame.resizing = true
                    weizPVP_CoreFrame:StartSizing("BOTTOMLEFT")
                elseif NS.Options.Window.Locked then
                    NS.CoreUI.SetIcon("lock")
                end
            end
        )

        -- : OnMouseUp
        weizPVP_CoreFrame.ResizeBottomLeft:SetScript(
        "OnMouseUp",
            function(_, button)
                if (button == "LeftButton") then
                    if not NS.Options.Window.Locked then
                        SnapHeightToBars()
                        if weizPVP_CoreFrame.resizing then
                            weizPVP_CoreFrame:StopMovingOrSizing()
                            weizPVP_CoreFrame.resizing = nil
                            NS.SaveCoreFramePosition()
                            NS.SetCoreFramePosition()
                            NS.AutoResize()
                        end
                        NS.RefreshCurrentList()
                    end
                end
            end
        )
    end

    -- : AFTER SETUP
    weizPVP_CoreFrame:SetScale(NS.Options.Frames.Scale)
end

--> Targeted Icon
-----------------------------------------------------------
local function BuildTargetedIcon()
    -- : Outer Icon Frame
    weizPVP_CoreFrame.OuterIconFrame = weizPVP_CoreFrame.OuterIconFrame or CreateFrame("Frame", nil, weizPVP_CoreFrame)
    weizPVP_CoreFrame.OuterIconFrame:SetPoint("TOPLEFT", weizPVP_CoreFrame, "TOPLEFT", -NS.Options.Bars.RowHeight, 0)
    weizPVP_CoreFrame.OuterIconFrame:SetPoint(
    "BOTTOMRIGHT",
        weizPVP_CoreFrame,
        "BOTTOMRIGHT",
        NS.Options.Bars.RowHeight,
        0
    )
    weizPVP_CoreFrame.OuterIconFrame:SetClipsChildren(true)
    -- : Targeted Icon
    weizPVP_CoreFrame.TargetedIcon = weizPVP_CoreFrame.TargetedIcon or weizPVP_CoreFrame.OuterIconFrame:CreateTexture(nil, "OVERLAY")
    weizPVP_CoreFrame.TargetedIcon:SetTexture("Interface/Addons/weizPVP/Media/Buttons/target.tga") -- 64x64 image
    weizPVP_CoreFrame.TargetedIcon:SetSize(
    Round(NS.Options.Bars.RowHeight - (NS.Options.Bars.RowHeight / 6)),
        Round(NS.Options.Bars.RowHeight - (NS.Options.Bars.RowHeight / 6))
    )
    weizPVP_CoreFrame.TargetedIcon:Hide()
end

--> Initialize
-----------------------------------------------------------
local initializing = false
local initialized = false
function NS.CoreUI.Initialize()
    if initializing then
        return
    end
    if initialized then
        weizPVP_CoreFrame:StopAnimating()
        weizPVP_CoreBar:StopAnimating()
    else
        initialized = true
    end
    do
        CoreBarInit()
        BuildTargetedIcon()
        NS.CoreUI.BuildBars()
        NS.SetCoreFramePosition()
        NS.ManageBarsDisplayed()
        NS.RefreshCurrentList()
        NS.UpdateNearbyCount()
        SnapHeightToBars()
        NS.CoreUI.ChangeTargetIcon()
        --> Apply Colors
        weizPVP_CoreFrame.ScrollFrame.BG:SetVertexColor(
        NS.Options.Frames.BackgroundColor.r,
            NS.Options.Frames.BackgroundColor.g,
            NS.Options.Frames.BackgroundColor.b
        )
        weizPVP_CoreFrame.ScrollFrame.BG:SetAlpha(NS.Options.Frames.BackgroundColor.a)
        weizPVP_CoreBar.BG:SetVertexColor(
        NS.Options.Frames.Header.BackgroundColor.r,
            NS.Options.Frames.Header.BackgroundColor.g,
            NS.Options.Frames.Header.BackgroundColor.b
        )
        weizPVP_CoreBar.BG:SetAlpha(NS.Options.Frames.Header.BackgroundColor.a)
    end
    initializing = false
end

---------------------------------------------------------------------------------------------------
--|> Functions
---------------------------------------------------------------------------------------------------

--> Change Target Icon
-----------------------------------------------------------
local lastRowSelected = nil
local GUID
function NS.CoreUI.ChangeTargetIcon()
    if not weizPVP_CoreFrame then
        return
    end
    if NS.Options.Window.Collapsed then
        return
    end
    if not weizPVP_CoreFrame.TargetedIcon then
        return
    end
    GUID = UnitGUID("target")
    if NS.PlayersOnBars[GUID] then
        if weizPVP_CoreFrame:GetLeft() < 8 then
            weizPVP_CoreFrame.TargetedIcon:SetRotation(3.14159)
            weizPVP_CoreFrame.TargetedIcon:ClearAllPoints()
            weizPVP_CoreFrame.TargetedIcon:SetPoint(
            "LEFT",
                NS.CoreUI.Bar[NS.PlayersOnBars[GUID]],
                "RIGHT",
                -(NS.Options.Frames.BorderSize),
                0
            )
        else
            weizPVP_CoreFrame.TargetedIcon:SetRotation(0)
            weizPVP_CoreFrame.TargetedIcon:ClearAllPoints()
            weizPVP_CoreFrame.TargetedIcon:SetPoint(
            "RIGHT",
                NS.CoreUI.Bar[NS.PlayersOnBars[GUID]],
                "LEFT",
                NS.Options.Frames.BorderSize,
                0
            )
        end
        weizPVP_CoreFrame.TargetedIcon:Show()
        if lastRowSelected then
            NS.CoreUI.Bar[lastRowSelected]:SetStatusBarTexture(SM:Fetch("statusbar", NS.Options.Bars.Texture))
        end
        NS.CoreUI.Bar[NS.PlayersOnBars[GUID]]:SetStatusBarTexture(SM:Fetch("statusbar", NS.Options.Bars.BarSolid))
        lastRowSelected = NS.PlayersOnBars[GUID] or nil
    else
        weizPVP_CoreFrame.TargetedIcon:Hide()
        if lastRowSelected then
            NS.CoreUI.Bar[lastRowSelected]:SetStatusBarTexture(SM:Fetch("statusbar", NS.Options.Bars.Texture))
        end
    end
end

--> Window: Set Window Settings
-----------------------------------------------------------
function NS.SetWindowSettings()
    -- Double check everything is loaded,, targeticon is pretty much last
    -- TODO: make proper event loading so this isn't needed
    if not weizPVP_CoreFrame.TargetedIcon then
        return
    end
    if not InCombatLockdown() then
        if NS.Options.Addon.Enabled and NS.Options.Window.Visible then
            weizPVP_CoreFrame:Show()
            if not NS.Options.Window.Collapsed then
                NS.CoreUI.ExpandFrame()
            else
                NS.CoreUI.CollapseFrame()
            end
            if NS.Options.Frames.AutoResize then
                NS.AutoResize()
            end
        else
            weizPVP_CoreFrame:Hide()
        end
    end
end

--> Set Icon
-----------------------------------------------------------
function NS.CoreUI.SetIcon(icon)
    if not icon then
        return
    end
    if NS.IconLUT[icon] then
        weizPVP_CoreBar.StatusIcon.StateGlyph:SetTextColor(1, 1, 1)
        weizPVP_CoreBar.StatusIcon.StateGlyph:SetText(NS.IconLUT[icon])
        weizPVP_CoreBar.StatusIconNotice:Stop()
        weizPVP_CoreBar.StatusIconNotice:Play()
    end
end

--> Toggle Pin
-----------------------------------------------------------
function NS.CoreUI.TogglePin()
    if NS.Options.Window.Locked then
        NS.CoreUI.SetIcon("lock")
        return
    end
    if NS.Options.Window.Pinned then
        NS.CoreUI.SetIcon("unpin")
        NS.Options.Window.Pinned = false
        weizPVP_CoreBar:SetMovable(true)
    else
        NS.CoreUI.SetIcon("pin")
        NS.Options.Window.Pinned = true
        weizPVP_CoreBar:SetMovable(false)
    end
end

--> Toggle Lock
-----------------------------------------------------------
function NS.CoreUI.ToggleLock()
    if NS.Options.Window.Locked then
        NS.CoreUI.SetIcon("unlock")
        NS.Options.Window.Locked = false
        weizPVP_CoreBar:SetMovable(true)
        if not NS.Options.Window.Collapsed then
            weizPVP_CoreFrame.ResizeBottomLeft:Show()
            weizPVP_CoreFrame.ResizeBottomRight:Show()
        end
    else
        NS.CoreUI.SetIcon("lock")
        NS.Options.Window.Locked = true
        NS.Options.Window.Pinned = false
        weizPVP_CoreBar:SetMovable(false)
        weizPVP_CoreFrame.ResizeBottomLeft:Hide()
        weizPVP_CoreFrame.ResizeBottomRight:Hide()
    end
end

--> Collapse Frame
-----------------------------------------------------------
function NS.CoreUI.CollapseFrame()
    weizPVP_CoreFrame:SetClampedToScreen(false)
    weizPVP_CoreFrame.ScrollFrame:Hide()
    weizPVP_CoreFrame.ResizeBottomLeft:Hide()
    weizPVP_CoreFrame.ResizeBottomRight:Hide()
    NS.Options.Window.Collapsed = true
    weizPVP_CoreFrame.CollapsedHeight = weizPVP_CoreFrame:GetHeight()
    NS.Options.Frames.Height = weizPVP_CoreFrame:GetHeight()
    weizPVP_CoreFrame.TargetedIcon:Hide()
end

--> Expand Frame
-----------------------------------------------------------
function NS.CoreUI.ExpandFrame()
    weizPVP_CoreFrame:SetClampedToScreen(true)
    weizPVP_CoreFrame.ScrollFrame:Show()
    weizPVP_CoreFrame:SetHeight(NS.Options.Frames.Height)
    weizPVP_CoreFrame.ResizeBottomLeft:Show()
    weizPVP_CoreFrame.ResizeBottomRight:Show()
    NS.Options.Window.Collapsed = false
    NS.CoreUI.ChangeTargetIcon()
end

--> Combat Start
-----------------------------------------------------------
function NS.CoreUI.CombatStart()
    NS.CoreUI.SetStatusIconColor(NS.ColorsLUT["InCombat"].r, NS.ColorsLUT["InCombat"].g, NS.ColorsLUT["InCombat"].b)
end

--> Combat End
-----------------------------------------------------------
function NS.CoreUI.CombatEnd()
    NS.CoreUI.SetStatusIconColor(
    NS.ColorsLUT["OutOfCombat"].r,
        NS.ColorsLUT["OutOfCombat"].g,
        NS.ColorsLUT["OutOfCombat"].b
    )
    C_Timer_After(
    3,
        function()
            if not InCombatLockdown() then
                NS.CoreUI.SetStatusIconColor(NS.ColorsLUT["addon"].r, NS.ColorsLUT["addon"].g, NS.ColorsLUT["addon"].b)
            end
        end
    )
end

--> Set Status Icon Color
-----------------------------------------------------------
function NS.CoreUI.SetStatusIconColor(r, g, b)
    weizPVP_CoreBar.StatusIcon.AddonIconHighlight:SetVertexColor(r, g, b)
end

--> Flash Title Bar
-----------------------------------------------------------
function NS.CoreUI.FlashTitleBar(color)
    if NS.ColorsLUT[color] then
        weizPVP_CoreBar.StatusHeader.Highlight.grad:SetGradient(
        "HORIZONTAL",
            NS.ColorsLUT[color].r,
            NS.ColorsLUT[color].g,
            NS.ColorsLUT[color].b,
            0,
            NS.ColorsLUT[color].r,
            NS.ColorsLUT[color].g,
            NS.ColorsLUT[color].b,
            0.4
        )
        weizPVP_CoreBar.StatusHeader.Highlight.grad2:SetGradient(
        "HORIZONTAL",
            NS.ColorsLUT[color].r,
            NS.ColorsLUT[color].g,
            NS.ColorsLUT[color].b,
            0.4,
            NS.ColorsLUT[color].r,
            NS.ColorsLUT[color].g,
            NS.ColorsLUT[color].b,
            0
        )
        if weizPVP_CoreBar.HeaderFlash:IsPlaying() then
            weizPVP_CoreBar.HeaderFlash:Restart()
        else
            weizPVP_CoreBar.HeaderFlash:Play()
        end
    else
        if weizPVP_CoreBar.HeaderFlash:IsPlaying() then
            weizPVP_CoreBar.HeaderFlash:Restart()
        else
            weizPVP_CoreBar.HeaderFlash:Play()
        end
    end
end

--> Auto-Resize
-----------------------------------------------------------
function NS.AutoResize()
    if not NS.Options.Frames.AutoResize then
        return
    end
    if weizPVP_CoreFrame.resizing then
        return
    end
    local count = NS.NearbyCount or 0
    --: Get # players

    if NS.NearbyCount > NS.Options.Bars.MaxNumBars then
        count = NS.Options.Bars.MaxNumBars
    end
    --: Collapse/Expand
    if count == 0 and not NS.Options.Window.Collapsed then
        NS.CoreUI.CollapseFrame()
    elseif count > 0 and NS.Options.Window.Collapsed then
        NS.CoreUI.ExpandFrame()
    end
    if count == 0 then
        count = 1
    end
    weizPVP_CoreFrame:SetHeight(
    (count * (NS.Options.Bars.RowHeight + NS.Options.Bars.VerticalSpacing)) + NS.Options.Frames.Header.Height
    )
    SnapHeightToBars()
end

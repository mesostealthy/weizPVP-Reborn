---------------------------------------------------------------------------------------------------
--|> CROSSHAIR
-- 📌 Places a crosshair on a nameplate.
-- 📌 Filtered for player targets that are hostile player with support for icons, text etc attachments
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: Libraries :------------------------
local RC = LibStub("LibRangeCheck-2.0")

--: NAMESPACE :------------------------
NS.Crosshair = {}
NS.Crosshair.Enabled = false
--: LOCALS :---------------------------
NS.Crosshair = {}
NS.Crosshair.Enabled = false
local eventFrame = CreateFrame("frame")
local RangeCheckTicker

--: 🆙 Upvalues :----------------------
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local DISABLED_FONT_COLOR = DISABLED_FONT_COLOR
local UIFrameFadeIn = UIFrameFadeIn
local IsItemInRange = IsItemInRange
local UnitIsUnit = UnitIsUnit
local C_NamePlate = C_NamePlate
local UnitClass = UnitClass
local UnitIsConnected = UnitIsConnected
local IsFlying = IsFlying
local IsUsableItem = IsUsableItem
local select = select
local C_Timer_NewTicker = C_Timer.NewTicker

--> Hide <-----------------------------------------------------------
local function HideCrosshair()
    weizPVP_CrosshairFrame:Hide()
    weizPVP_CrosshairFrame.active = nil
end

--> Show <-----------------------------------------------------------
local function ShowCrosshair()
    if NS.Options.Crosshair.Enabled then
        UIFrameFadeIn(weizPVP_CrosshairFrame, 0.1, 0, NS.Options.Crosshair.Alpha)
        weizPVP_CrosshairFrame:Show()
        weizPVP_CrosshairFrame.active = true
    else
        NS.Crosshair.Disable()
    end
end

function NS.HideCrosshair()
    HideCrosshair()
end

function NS.ShowCrosshair()
    ShowCrosshair()
end

--> CONFIGURE RANGE <------------------------------------------------
local function ConfigureRange()
    if NS.Options.Crosshair.ShowRange then
        weizPVP_CrosshairFrame.RangeText:Show()
    else
        weizPVP_CrosshairFrame.RangeText:Hide()
    end
end

-->  SET CLASS COLORS <----------------------------------------------
local targetClassColor = {}
local function SetCrosshairColors()
    if UnitIsConnected("target") then
        targetClassColor = RAID_CLASS_COLORS[select(2, UnitClass("target"))]
    else
        targetClassColor = DISABLED_FONT_COLOR
    end
    --: CORE
    weizPVP_CrosshairFrame.Core:SetVertexColor(targetClassColor.r, targetClassColor.g, targetClassColor.b, 0.3)
    weizPVP_CrosshairFrame.Core_ADD:SetVertexColor(targetClassColor.r, targetClassColor.g, targetClassColor.b, 0.8)
    --: LINES
    weizPVP_CrosshairFrame.TopLine:SetVertexColor(
    targetClassColor.r,
        targetClassColor.g,
        targetClassColor.b,
        NS.Options.Crosshair.LineAlpha
    )
    weizPVP_CrosshairFrame.BottomLine:SetVertexColor(
    targetClassColor.r,
        targetClassColor.g,
        targetClassColor.b,
        NS.Options.Crosshair.LineAlpha
    )
    weizPVP_CrosshairFrame.LeftLine:SetVertexColor(
    targetClassColor.r,
        targetClassColor.g,
        targetClassColor.b,
        NS.Options.Crosshair.LineAlpha
    )
    weizPVP_CrosshairFrame.RightLine:SetVertexColor(
    targetClassColor.r,
        targetClassColor.g,
        targetClassColor.b,
        NS.Options.Crosshair.LineAlpha
    )
    weizPVP_CrosshairFrame.TargetFX:SetVertexColor(targetClassColor.r, targetClassColor.g, targetClassColor.b, 0.8)
    NS.Crosshair.SetAlpha()
    --: NAME TEXT
    if NS.Options.Crosshair.NameEnabled then
        weizPVP_CrosshairFrame.NameText:SetTextColor(targetClassColor.r, targetClassColor.g, targetClassColor.b)
    end
end

-->  RANGE CHECK <---------------------------------------------------
local function getRangeInfo()
    local minRange, _ = RC:GetRange("target")
    local outputAlpha = 1
    if minRange then
        if minRange < 20 then
            outputAlpha = 0
        elseif minRange < 30 then
            outputAlpha = 0.5
        elseif minRange < 40 then
            outputAlpha = 0.8
        end
    end
    if minRange == 200 then
        minRange = "200+"
    elseif not minRange then
        minRange = "|cffffff00--|r"
    end
    return minRange, outputAlpha
end

--> NET <------------------------------------------------------------
local function ShowNet5000()
    weizPVP_CrosshairFrame.NetOMatic.BG.Pulse:Play()
    weizPVP_CrosshairFrame.NetOMatic:SetAlpha(1)
end

local function HideNet5000()
    weizPVP_CrosshairFrame.NetOMatic.BG.Pulse:Stop()
    weizPVP_CrosshairFrame.NetOMatic:SetAlpha(0)
end

local function IsNetUsable()
    return (IsFlying("target") and IsItemInRange("Net-o-Matic 5000", "target") and IsUsableItem("Net-o-Matic 5000"))
end

--> Target Changed <-------------------------------------------------
local function TargetRangeCheck()
    --: Net-o-Matic 5000 Check
    if IsNetUsable() then
        ShowNet5000()
    else
        HideNet5000()
    end
    --: Range Check
    local rText, rAlpha = getRangeInfo()
    if weizPVP_CrosshairFrame.RangeText:GetText() ~= rText then
        weizPVP_CrosshairFrame.RangeText:SetText(rText)
    end
    if weizPVP_CrosshairFrame.RangeText:GetAlpha() ~= rAlpha then
        weizPVP_CrosshairFrame.RangeText:SetAlpha(rAlpha)
    end
end

--> Range Check Pulse <----------------------------------------------
local function RangeCheckPulse()
    if weizPVP_CrosshairFrame.active then
        TargetRangeCheck()
    end
end

--> Check KOS <------------------------------------------------------
local function CheckKOS()
    if NS.KosList[NS.GetFullNameOfUnit("target")] then
        weizPVP_CrosshairFrame.FourArrowsKOS.FadeIn:Play()
        weizPVP_CrosshairFrame.FourArrowsKOS.Rotate:Play()
        weizPVP_CrosshairFrame.FourArrows:Hide()
        weizPVP_CrosshairFrame.FourArrowsKOS:Show()
        return true
    else
        weizPVP_CrosshairFrame.FourArrows.FadeIn:Play()
        weizPVP_CrosshairFrame.FourArrows.Rotate:Play()
        weizPVP_CrosshairFrame.FourArrows:Show()
        weizPVP_CrosshairFrame.FourArrowsKOS:Hide()
        return false
    end
end

--> Setup Crosshair On Nameplate <-----------------------------------
local function SetupCrosshairOnNameplate(nameplate)
    if not nameplate then
        return
    end
    --: Set on same level as nameplate
    weizPVP_CrosshairFrame.Core:SetWidth(nameplate:GetWidth() + 14)
    weizPVP_CrosshairFrame.Core:SetHeight(weizPVP_CrosshairFrame.Core:GetWidth())
    weizPVP_CrosshairFrame:ClearAllPoints()
    weizPVP_CrosshairFrame:SetParent(nameplate)
    weizPVP_CrosshairFrame:SetPoint("CENTER")
    --: Alpha
    if not weizPVP_CrosshairFrame:IsShown() then
        NS.Crosshair.SetAlpha()
        ShowCrosshair()
    end
    --: Animations
    weizPVP_CrosshairFrame:StopAnimating()
    weizPVP_CrosshairFrame.TargetFX:Show()
    weizPVP_CrosshairFrame.TargetFX.Splash:Play()
    --: KOS Check
    CheckKOS()
    SetCrosshairColors()
end

--> Refresh Name Text -----------------------------------------------
local function RefreshNameText()
    if NS.Options.Crosshair.NameEnabled then
        local displayName = NS.FormatPlayerNameOnly(NS.GetFullNameOfUnit("target"))
        weizPVP_CrosshairFrame.NameText:SetText(displayName)
        weizPVP_CrosshairFrame.NameText:Show()
    else
        weizPVP_CrosshairFrame.NameText:Hide()
    end
end

--> Refresh Guild Text <---------------------------------------------
local function RefreshGuildText()
    if NS.Options.Crosshair.GuildEnabled then
        if select(1, GetGuildInfo("target")) then
            weizPVP_CrosshairFrame.GuildText:SetText("|cffcccccc" .. (select(1, GetGuildInfo("target")) or "") .. "|r")
            weizPVP_CrosshairFrame.GuildGradient:Show()
            weizPVP_CrosshairFrame.GuildTextBG:Show()
            weizPVP_CrosshairFrame.GuildText:Show()
        else
            weizPVP_CrosshairFrame.GuildGradient:Hide()
            weizPVP_CrosshairFrame.GuildTextBG:Hide()
            weizPVP_CrosshairFrame.GuildText:Hide()
        end
    else
        weizPVP_CrosshairFrame.GuildGradient:Hide()
        weizPVP_CrosshairFrame.GuildText:Hide()
        weizPVP_CrosshairFrame.GuildTextBG:Hide()
    end
end

--> VALID UNIT TARGETED <--------------------------------------------
local function ValidUnitTargeted()
    if not (C_NamePlate.GetNamePlateForUnit("target") and true or nil) then
        HideCrosshair()
        return
    end
    TargetRangeCheck()
    RefreshNameText()
    RefreshGuildText()
    ShowCrosshair()
    SetupCrosshairOnNameplate(C_NamePlate.GetNamePlateForUnit("target"))
end

--|> CROSSHAIR ALLOWED?
local function IsCrosshairAllowed(unit)
  -- friendly crosshairs enabled?
  if NS.Options.Crosshair.FriendlyCrosshairs == true then
    return true
  else
    return NS.IsUnitValidForTracking(unit)
  end
end

--|> EVENTS
-----------------------------------------------------------
-->  NAMEPLATE ADDED <-----------------------------------------------
local function NameplateAdded(unit)
    if UnitIsUnit("target", unit) then
        if not IsCrosshairAllowed("target") then
            HideCrosshair()
            return
        end
        ValidUnitTargeted()
    end
end

--> NAMEPLATE REMOVED <----------------------------------------------
local function NameplateRemoved(unit)
    if UnitIsUnit("target", unit) then
        HideCrosshair()
    end
end

--> NEW TARGET <-----------------------------------------------------
function NS.Crosshair.NewTarget()
    if IsCrosshairAllowed("target") then
        ValidUnitTargeted()
        NameplateAdded("target")
        RangeCheckTicker = C_Timer_NewTicker(0.6, RangeCheckPulse)
        eventFrame:RegisterEvent "NAME_PLATE_UNIT_REMOVED"
    else
        NS.Crosshair.Reset()
        eventFrame:UnregisterEvent "NAME_PLATE_UNIT_REMOVED"
    end
end

--|> FUNCTIONS: SETTINGS + CONFIG
--> SET ALPHA <------------------------------------------------------
function NS.Crosshair.SetAlpha()
    weizPVP_CrosshairFrame:SetAlpha(NS.Options.Crosshair.Alpha)
    weizPVP_CrosshairFrame.TopLine:SetAlpha(NS.Options.Crosshair.LineAlpha)
    weizPVP_CrosshairFrame.BottomLine:SetAlpha(NS.Options.Crosshair.LineAlpha)
    weizPVP_CrosshairFrame.LeftLine:SetAlpha(NS.Options.Crosshair.LineAlpha)
    weizPVP_CrosshairFrame.RightLine:SetAlpha(NS.Options.Crosshair.LineAlpha)
end

--> SET LINE THICKNESS <---------------------------------------------
function NS.Crosshair.SetLineThickness()
    weizPVP_CrosshairFrame.TopLine:SetIgnoreParentScale(true)
    weizPVP_CrosshairFrame.BottomLine:SetIgnoreParentScale(true)
    weizPVP_CrosshairFrame.LeftLine:SetIgnoreParentScale(true)
    weizPVP_CrosshairFrame.RightLine:SetIgnoreParentScale(true)

    PixelUtil.SetWidth(weizPVP_CrosshairFrame.TopLine, NS.Options.Crosshair.LineThickness, 1)
    PixelUtil.SetWidth(weizPVP_CrosshairFrame.BottomLine, NS.Options.Crosshair.LineThickness, 1)
    PixelUtil.SetHeight(weizPVP_CrosshairFrame.LeftLine, NS.Options.Crosshair.LineThickness, 1)
    PixelUtil.SetHeight(weizPVP_CrosshairFrame.RightLine, NS.Options.Crosshair.LineThickness, 1)
end

--> SET SCALE <------------------------------------------------------
function NS.Crosshair.SetScale()
    weizPVP_CrosshairFrame:SetScale(NS.Options.Crosshair.Scale)
end

--> RESET <----------------------------------------------------------
function NS.Crosshair.Reset()
    HideCrosshair()
    weizPVP_CrosshairFrame:ClearAllPoints()
    targetClassColor = {}
    if RangeCheckTicker then
        RangeCheckTicker:Cancel()
        RangeCheckTicker = nil
    end
end

--> ENABLE <---------------------------------------------------------
function NS.Crosshair.Enable()
    if not NS.Options.Crosshair.Enabled then
        return
    end
    NS.Crosshair.Reset()
    NS.Crosshair.SetLineThickness()
    NS.Crosshair.SetScale()
    NS.Crosshair.SetAlpha()
    ConfigureRange()
    eventFrame:RegisterEvent "NAME_PLATE_UNIT_ADDED"
    eventFrame:RegisterEvent "NAME_PLATE_UNIT_REMOVED"
    weizPVP_CrosshairFrame.NetOMatic:Show()
    NS.ResizeFrameToUiScale(weizPVP_CrosshairFrame)
    NS.Crosshair.Enabled = true
    NS.Crosshair.NewTarget()
end

--> DISABLE <--------------------------------------------------------
function NS.Crosshair.Disable()
    NS.Crosshair.Reset()
    NS.Crosshair.Enabled = nil
    NS.Crosshair.active = nil
    eventFrame:UnregisterEvent "NAME_PLATE_UNIT_ADDED"
    eventFrame:UnregisterEvent "NAME_PLATE_UNIT_REMOVED"
    if RangeCheckTicker then
        RangeCheckTicker:Cancel()
        RangeCheckTicker = nil
    end
end

--> TOGGLE <---------------------------------------------------------
function NS.Crosshair.Toggle()
    if NS.Crosshair.Enabled then
        NS.Crosshair.Reset()
        NS.Crosshair.Enabled = false
        eventFrame:UnregisterEvent "NAME_PLATE_UNIT_ADDED"
        eventFrame:UnregisterEvent "NAME_PLATE_UNIT_REMOVED"
    else
        NS.Crosshair.Enable()
        NS.Crosshair.Enabled = true
    end
end

--> OnLoad <---------------------------------------------------------
function NS.Crosshair.OnLoad()
    NS.Crosshair.Reset()
end

eventFrame:SetScript(
"OnEvent",
    function(_, event, ...)
        if eventFrame[event] then
            return eventFrame[event](eventFrame, event, ...)
        end
    end
)

--> NAME_PLATE_UNIT_ADDED <------------------------------------------
function eventFrame.NAME_PLATE_UNIT_ADDED(_, _, unit)
    if IsCrosshairAllowed(unit) then
        NameplateAdded(unit)
    end
end

--> NAME_PLATE_UNIT_REMOVED <----------------------------------------
function eventFrame.NAME_PLATE_UNIT_REMOVED(_, _, unit)
    if IsCrosshairAllowed(unit) then
        NameplateRemoved(unit)
    end
end

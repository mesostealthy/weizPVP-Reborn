---------------------------------------------------------------------------------------------------
--|> Player Bars
--: Manages the display of the bars and their elements representing detected players
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local UIFrameFadeIn = UIFrameFadeIn
local UIFrameFadeOut = UIFrameFadeOut
local InCombatLockdown = InCombatLockdown
local GetTime = GetTime
local GetUnitName = GetUnitName
local gsub = gsub

--: LIBS :-----------------------------
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

--> Build Bars <-----------------------------------------------------
NS.CoreUI.Bar = NS.CoreUI.Bar or {}
function NS.CoreUI.BuildBars()
    NS.CoreUI.Bar = NS.CoreUI.Bar or {}
    for k = 1, NS.Options.Bars.MaxNumBars do
        NS.CoreUI.Bar[k] = NS.CoreUI.Bar[k] or CreateFrame("StatusBar", "weizPVP_PlayerBar" .. k, weizPVP_CoreFrame.ScrollFrame.ListFrame)
        NS.CoreUI.Bar[k].id = k
        NS.CoreUI.Bar[k].fullName = ""
        NS.CoreUI.Bar[k].displayGuild = ""
        NS.CoreUI.Bar[k].displayName = ""
        NS.CoreUI.Bar[k]:SetHeight(NS.Options.Bars.RowHeight)
        --: Index Offset
        if k == 1 then
            NS.CoreUI.Bar[k]:SetPoint("TOP", weizPVP_CoreFrame.ScrollFrame.ListFrame, "TOP")
        else
            NS.CoreUI.Bar[k]:SetPoint("TOP", NS.CoreUI.Bar[(k - 1)], "BOTTOM", 0, (-1 * NS.Options.Bars.VerticalSpacing))
        end
        NS.CoreUI.Bar[k]:SetPoint("RIGHT", weizPVP_CoreFrame.ScrollFrame, "RIGHT", -1, 0)
        NS.CoreUI.Bar[k]:SetPoint("LEFT", weizPVP_CoreFrame.ScrollFrame, "LEFT", 1, 0)
        NS.CoreUI.Bar[k]:SetStatusBarTexture(SM:Fetch("statusbar", NS.Options.Bars.Texture))
        NS.CoreUI.Bar[k]:SetStatusBarColor(0, 0, 0, 0)
        NS.CoreUI.Bar[k]:SetMinMaxValues(0, 100)
        NS.CoreUI.Bar[k]:SetValue(100)
        --: bg
        NS.CoreUI.Bar[k].bg = NS.CoreUI.Bar[k].bg or NS.CoreUI.Bar[k]:CreateTexture(nil, "BACKGROUND")
        NS.CoreUI.Bar[k].bg:SetTexture(SM:Fetch("background", NS.Options.Bars.BarTexture))
        NS.CoreUI.Bar[k].bg:SetAllPoints(true)
        NS.CoreUI.Bar[k].bg:SetVertexColor(0, 0, 0, 0)
        --: Highlight
        NS.CoreUI.Bar[k].Highlight = NS.CoreUI.Bar[k].Highlight or NS.CoreUI.Bar[k]:CreateTexture(nil, "ARTWORK", nil, 1)
        NS.CoreUI.Bar[k].Highlight:SetAllPoints()
        NS.CoreUI.Bar[k].Highlight:SetColorTexture(1, 1, 1)
        NS.CoreUI.Bar[k].Highlight:SetBlendMode("ADD")
        NS.CoreUI.Bar[k].Highlight:SetAlpha(0)
        --: KOS
        NS.CoreUI.Bar[k].KOSRibbon = NS.CoreUI.Bar[k].KOSRibbon or NS.CoreUI.Bar[k]:CreateTexture(nil, "ARTWORK", nil, 5)
        NS.CoreUI.Bar[k].KOSRibbon:SetTexture("Interface/Addons/weizPVP/Addons/KOS/Media/kos_ribbon.tga")
        NS.CoreUI.Bar[k].KOSRibbon:SetPoint("LEFT", NS.CoreUI.Bar[k], "LEFT")
        NS.CoreUI.Bar[k].KOSRibbon:SetPoint("TOP", NS.CoreUI.Bar[k], "TOP")
        NS.CoreUI.Bar[k].KOSRibbon:SetPoint("BOTTOM", NS.CoreUI.Bar[k], "BOTTOM")
        NS.CoreUI.Bar[k].KOSRibbon:SetWidth(NS.Options.Bars.RowHeight)
        --: ROLE ICON
        NS.CoreUI.Bar[k].RoleIcon = NS.CoreUI.Bar[k].RoleIcon or NS.CoreUI.Bar[k]:CreateTexture(nil, "ARTWORK", nil, 2)
        NS.CoreUI.Bar[k].RoleIcon:SetPoint("LEFT", NS.CoreUI.Bar[k], "LEFT", 2, 0)
        NS.CoreUI.Bar[k].RoleIcon:SetSize(NS.Options.Bars.RowHeight - 3, NS.Options.Bars.RowHeight - 3)
        --: Name
        NS.CoreUI.Bar[k].Name = NS.CoreUI.Bar[k].Name or NS.CoreUI.Bar[k]:CreateFontString(nil, "ARTWORK", nil, 2)
        NS.CoreUI.Bar[k].Name:SetFont(SM:Fetch("font", NS.Options.Bars.NameFont), NS.Options.Bars.NameFontSize, "OUTLINE")
        NS.CoreUI.Bar[k].Name:SetHeight(NS.Options.Bars.NameFontSize)
        NS.CoreUI.Bar[k].Name:SetPoint("LEFT", NS.CoreUI.Bar[k].RoleIcon, "RIGHT", 3, 0)
        NS.CoreUI.Bar[k].Name:SetDrawLayer("OVERLAY", 7)
        NS.CoreUI.Bar[k].Name:SetJustifyH("LEFT")
        NS.CoreUI.Bar[k].Name:SetJustifyV("MIDDLE")
        NS.CoreUI.Bar[k].Name:SetTextColor(1, 1, 1, 1)
        NS.CoreUI.Bar[k].Name:SetShadowColor(0.2, 0.2, 0.2, 0.4)
        NS.CoreUI.Bar[k].Name:SetShadowOffset(1, -1)
        --: Level
        NS.CoreUI.Bar[k].Level = NS.CoreUI.Bar[k].Level or NS.CoreUI.Bar[k]:CreateFontString(nil, "ARTWORK", "GameFontNormal", 2)
        NS.CoreUI.Bar[k].Level:SetFont(
        SM:Fetch("font", NS.Options.Bars.LevelFont),
            NS.Options.Bars.LevelFontSize,
            "OUTLINE"
        )
        NS.CoreUI.Bar[k].Level:SetHeight(NS.Options.Bars.LevelFontSize)
        NS.CoreUI.Bar[k].Level:SetPoint("LEFT", NS.CoreUI.Bar[k].Name, "RIGHT", 2, 0)
        NS.CoreUI.Bar[k].Level:SetPoint("BOTTOM", NS.CoreUI.Bar[k].Name, "BOTTOM", 0, -1)
        NS.CoreUI.Bar[k].Level:SetJustifyH("LEFT")
        NS.CoreUI.Bar[k].Level:SetJustifyV("BOTTOM")
        NS.CoreUI.Bar[k].Level:SetTextColor(1, 1, 1, 1)
        NS.CoreUI.Bar[k].Level:SetShadowColor(0, 0, 0, 0.5)
        --: Guild
        NS.CoreUI.Bar[k].Guild = NS.CoreUI.Bar[k].Guild or NS.CoreUI.Bar[k]:CreateFontString(nil, "ARTWORK", "GameFontNormal", 2)
        NS.CoreUI.Bar[k].Guild:SetFont(
        SM:Fetch("font", NS.Options.Bars.GuildFont),
            NS.Options.Bars.GuildFontSize,
            "OUTLINE"
        )
        NS.CoreUI.Bar[k].Guild:SetHeight(NS.Options.Bars.GuildFontSize)
        NS.CoreUI.Bar[k].Guild:SetMaxLines(1)
        NS.CoreUI.Bar[k].Guild:SetPoint("RIGHT", NS.CoreUI.Bar[k], "RIGHT", -4, 0)
        NS.CoreUI.Bar[k].Guild:SetJustifyH("RIGHT")
        NS.CoreUI.Bar[k].Guild:SetJustifyV("MIDDLE")
        NS.CoreUI.Bar[k].Guild:SetTextColor(1, 1, 1, 1)
        NS.CoreUI.Bar[k].Guild:SetShadowColor(0, 0, 0, 0.5)
        --: DEAD ICON
        NS.CoreUI.Bar[k].DeadIcon = NS.CoreUI.Bar[k].DeadIcon or NS.CoreUI.Bar[k]:CreateTexture(nil, "ARTWORK", nil, 2)
        NS.CoreUI.Bar[k].DeadIcon:SetPoint("LEFT", NS.CoreUI.Bar[k].Level, "RIGHT", 4, 0)
        NS.CoreUI.Bar[k].DeadIcon:SetSize(NS.Options.Bars.RowHeight, NS.Options.Bars.RowHeight)
        NS.CoreUI.Bar[k].DeadIcon:SetTexture("Interface/Addons/weizPVP/Media/Icons/dead.tga", false)
        NS.CoreUI.Bar[k].DeadIcon:Hide()
        --> Button
        NS.CoreUI.Bar[k].Button = NS.CoreUI.Bar[k].Button or CreateFrame("Button", nil, NS.CoreUI.Bar[k], "InsecureActionButtonTemplate")
        NS.CoreUI.Bar[k].Button:SetPoint("TOPRIGHT")
        NS.CoreUI.Bar[k].Button:SetPoint("TOPLEFT")
        NS.CoreUI.Bar[k].Button:SetHeight(NS.CoreUI.Bar[k]:GetHeight() + NS.Options.Bars.VerticalSpacing)
        NS.CoreUI.Bar[k].Button:SetAlpha(0)
        NS.CoreUI.Bar[k].Button.id = k
        NS.CoreUI.Bar[k].Button:SetScript(
        "OnLoad",
            function()
                if not InCombatLockdown() then
                    NS.CoreUI.Bar[k].Button:SetAttribute("type1", "macro")
                    local target = gsub(NS.CoreUI.Bar[k].fullName, "-" .. NS.PlayerRealm, "")
                    NS.CoreUI.Bar[k].Button:SetAttribute("macrotext1", "/targetexact " .. target)
                    NS.CoreUI.Bar[k].Target = target
                end
            end
        )
        NS.CoreUI.Bar[k].Button:SetScript(
        "PostClick",
            function(_, button)
                NS.CoreUI.ButtonPostClick(k, button)
                NS.ShowPlayerTooltip(NS.CoreUI.Bar[k].GUID)
            end
        )
        NS.CoreUI.Bar[k].Button:SetScript(
        "OnMouseDown",
            function(_, button)
                NS.CoreUI.ButtonPreClick(k, button)
            end
        )
        NS.CoreUI.Bar[k].Button:SetScript(
        "OnEnter",
            function()
                UIFrameFadeIn(NS.CoreUI.Bar[k].Highlight, 0.05, 0, 0.2)
                NS.ShowPlayerTooltip(NS.CoreUI.Bar[k].GUID)
            end
        )
        NS.CoreUI.Bar[k].Button:SetScript(
        "OnLeave",
            function()
                UIFrameFadeOut(NS.CoreUI.Bar[k].Highlight, 0.2, 0.2, 0)
                NS.HidePlayerTooltip()
            end
        )
    end
end

-------------------------------------------------------------------------------
--|> SECURE BUTTON ACTIONS
-------------------------------------------------------------------------------

--> PLAYER BAR: PRE-CLICK <------------------------------------------
function NS.CoreUI.ButtonPreClick(barID, MouseButton)
    if not NS.CoreUI.Bar[barID].fullName then
        return
    end
    local playerName = NS.CoreUI.Bar[barID].fullName
    UIFrameFadeIn(NS.CoreUI.Bar[barID].Highlight, 0.05, 0.15, 0.3)
    if playerName then
        if MouseButton == "LeftButton" then
            if not InCombatLockdown() then
                NS.CoreUI.Bar[barID].Button:RegisterForClicks("AnyUp", "AnyDown")
                NS.CoreUI.Bar[barID].Button:SetAttribute("type1", "macro")
                local target = gsub(playerName, "-" .. NS.PlayerRealm, "")
                NS.CoreUI.Bar[barID].Button:SetAttribute("macrotext1", "/targetexact " .. target)
                NS.CoreUI.Bar[barID].Target = target
            end
        elseif MouseButton == "RightButton" then
            NS.PlayerBarMenu_OnClick(NS.CoreUI.Bar[barID])
        end
    end
end

--> PLAYER BAR: POST-CLICK <-----------------------------------------
function NS.CoreUI.ButtonPostClick(barID, MouseButton)
    local playerName = NS.CoreUI.Bar[barID].fullName
    local targetSetName = NS.CoreUI.Bar[barID].Target
    local playerGUID = NS.CoreUI.Bar[barID].GUID
    local targetName = GetUnitName("target", true)
    if playerName and NS.PlayerActiveCache[playerGUID] then
        if MouseButton == "LeftButton" and targetName ~= targetSetName then
            if not NS.PlayerActiveCache[playerGUID].Stealth then
                if targetSetName == gsub(playerName, "-" .. NS.PlayerRealm, "") then
                    if NS.ActiveList[playerGUID] then
                        NS.InactiveList[playerGUID] = NS.ActiveList[playerGUID]
                        NS.InactiveList[playerGUID].TimeUpdated = GetTime() + NS.Options.Sorting.NearbyActiveTimeout + 0.1
                        NS.ActiveList[playerGUID] = nil
                    elseif NS.ActiveDeadList[playerGUID] then
                        NS.InactiveDeadList[playerGUID] = NS.ActiveDeadList[playerGUID]
                        NS.InactiveDeadList[playerGUID].TimeUpdated = GetTime() + NS.Options.Sorting.NearbyActiveTimeout + 0.1
                        NS.ActiveDeadList[playerGUID] = nil
                    end
                    NS.SortNearbyList()
                    NS.RefreshCurrentList()
                    NS.CoreUI.ChangeTargetIcon()
                end
            end
        end
    end
end

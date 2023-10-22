---------------------------------------------------------------------------------------------------
--|> ALERTS
-- 📌 Alerts and Notifications of all kind
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: ⬆️ Upvalues :--
local C_Timer_After = C_Timer.After
local CreateColor = CreateColor
local PlaySoundFile = PlaySoundFile
local FlashClientIcon = FlashClientIcon

--: 📚 LIBS
-----------------------------------------------------------
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

-- ⚒️ BUILD FRAME
--------------------------------------------------------
local function CreateAlertFrame()
    -- Get a position 1/3rd from top of screen
    local topOffset = UIParent:GetTop() / 3
    -- Create Alert Frame
    NS.AlertFrame = NS.AlertFrame or CreateFrame("Frame", "weizPVP_AlertFrame", UIParent)
    NS.AlertFrame:SetFrameStrata("HIGH")
    NS.AlertFrame:SetPoint("TOP", UIParent, "CENTER", 0, topOffset)
    NS.AlertFrame:SetHeight(90)
    NS.AlertFrame:SetWidth(160)
    NS.AlertFrame:SetFrameLevel(2)
    NS.AlertFrame:Hide()
    -- Center Ring
    NS.AlertFrame.RightFade = NS.AlertFrame.RightFade or NS.AlertFrame:CreateTexture(nil, "ARTWORK")
    NS.AlertFrame.RightFade:SetWidth(60)
    NS.AlertFrame.RightFade:SetPoint("TOPLEFT", NS.AlertFrame, "TOPRIGHT")
    NS.AlertFrame.RightFade:SetPoint("BOTTOMLEFT", NS.AlertFrame, "BOTTOMRIGHT")
    NS.AlertFrame.RightFade:SetColorTexture(0, 0, 0, 1)
    NS.AlertFrame.RightFade:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0.6), CreateColor(0, 0, 0, 0))
    NS.AlertFrame.Center = NS.AlertFrame.Center or NS.AlertFrame:CreateTexture(nil, "ARTWORK")
    NS.AlertFrame.Center:SetPoint("TOPLEFT", NS.AlertFrame, "TOPLEFT")
    NS.AlertFrame.Center:SetPoint("BOTTOMRIGHT", NS.AlertFrame, "BOTTOMRIGHT")
    NS.AlertFrame.Center:SetColorTexture(0, 0, 0, 0.6)
    NS.AlertFrame.LeftFade = NS.AlertFrame.LeftFade or NS.AlertFrame:CreateTexture(nil, "ARTWORK")
    NS.AlertFrame.LeftFade:SetWidth(60)
    NS.AlertFrame.LeftFade:SetPoint("TOPRIGHT", NS.AlertFrame, "TOPLEFT")
    NS.AlertFrame.LeftFade:SetPoint("BOTTOMRIGHT", NS.AlertFrame, "BOTTOMLEFT")
    NS.AlertFrame.LeftFade:SetColorTexture(0, 0, 0, 1)
    NS.AlertFrame.LeftFade:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0), CreateColor(0, 0, 0, 0.6))
    -- playerNameText
    NS.AlertFrame.playerText = NS.AlertFrame.playerText or NS.AlertFrame:CreateFontString(nil, "OVERLAY")
    NS.AlertFrame.playerText:SetPoint("RIGHT", NS.AlertFrame, "RIGHT")
    NS.AlertFrame.playerText:SetFont(SM:Fetch("font", "Roboto Condensed Bold"), 20, "OUTLINE")
    NS.AlertFrame.playerText:SetJustifyH("LEFT")
    -- div
    NS.AlertFrame.div = NS.AlertFrame.div or NS.AlertFrame:CreateFontString(nil, "OVERLAY")
    NS.AlertFrame.div:SetPoint("RIGHT", NS.AlertFrame.playerText, "LEFT")
    NS.AlertFrame.div:SetFont(SM:Fetch("font", "Roboto Condensed Bold"), 20, "OUTLINE")
    NS.AlertFrame.div:SetJustifyH("CENTER")
    NS.AlertFrame.div:SetTextColor(0.7, 0.7, 0.7, 1)
    NS.AlertFrame.div:SetText(" : ")
    -- eventText
    NS.AlertFrame.eventText = NS.AlertFrame.eventText or NS.AlertFrame:CreateFontString(nil, "OVERLAY")
    NS.AlertFrame.eventText:SetPoint("RIGHT", NS.AlertFrame.div, "LEFT", 0, 0)
    NS.AlertFrame.eventText:SetFont(SM:Fetch("font", "Roboto Condensed BoldItalic"), 20, "OUTLINE")
    NS.AlertFrame.eventText:SetJustifyH("LEFT")
    NS.AlertFrame.eventText:SetTextColor(1, 0.3, 0.9, 1)
    -- ICON
    NS.AlertFrame.Icon = NS.AlertFrame.Icon or NS.AlertFrame:CreateTexture(nil, "OVERLAY")
    NS.AlertFrame.Icon:SetPoint("RIGHT", NS.AlertFrame.eventText, "LEFT", -8, 0)
    NS.AlertFrame:SetHeight(NS.AlertFrame.eventText:GetTop() - NS.AlertFrame.playerText:GetBottom() + 14)
    NS.AlertFrame.Icon:SetSize(NS.AlertFrame:GetHeight(), NS.AlertFrame:GetHeight())

    -- Animation
    NS.AlertFrame.anim = NS.AlertFrame:CreateAnimationGroup()
    NS.AlertFrame.anim:SetScript(
    "OnFinished",
        function()
            NS.AlertFrame:Hide()
        end
    )
    NS.AlertFrame.anim:SetScript(
    "OnPlay",
        function()
            NS.AlertFrame:Show()
        end
    )
    NS.AlertFrame.anim.ag0a = NS.AlertFrame.anim.ag0a or NS.AlertFrame.anim:CreateAnimation("Alpha")
    NS.AlertFrame.anim.ag0a:SetDuration(0)
    NS.AlertFrame.anim.ag0a:SetFromAlpha(0)
    NS.AlertFrame.anim.ag0a:SetToAlpha(0)
    NS.AlertFrame.anim.ag0a:SetOrder(1)
    NS.AlertFrame.anim.ag0t = NS.AlertFrame.anim.ag0t or NS.AlertFrame.anim:CreateAnimation("Translation")
    NS.AlertFrame.anim.ag0t:SetOffset(0, -100)
    NS.AlertFrame.anim.ag0t:SetDuration(0)
    NS.AlertFrame.anim.ag0t:SetOrder(1)
    NS.AlertFrame.anim.ag1 = NS.AlertFrame.anim.ag1 or NS.AlertFrame.anim:CreateAnimation("Alpha")
    NS.AlertFrame.anim.ag1:SetDuration(0.2)
    NS.AlertFrame.anim.ag1:SetFromAlpha(0)
    NS.AlertFrame.anim.ag1:SetToAlpha(1)
    NS.AlertFrame.anim.ag1:SetEndDelay(3.5)
    NS.AlertFrame.anim.ag1:SetOrder(2)
    NS.AlertFrame.anim.ag2t = NS.AlertFrame.anim.ag2t or NS.AlertFrame.anim:CreateAnimation("Translation")
    NS.AlertFrame.anim.ag2t:SetOffset(0, 100)
    NS.AlertFrame.anim.ag2t:SetDuration(0.2)
    NS.AlertFrame.anim.ag2t:SetOrder(2)
    NS.AlertFrame.anim.ag2t:SetEndDelay(3.5)
    NS.AlertFrame.anim.ag3a = NS.AlertFrame.anim.ag3a or NS.AlertFrame.anim:CreateAnimation("Alpha")
    NS.AlertFrame.anim.ag3a:SetDuration(0.6)
    NS.AlertFrame.anim.ag3a:SetFromAlpha(1)
    NS.AlertFrame.anim.ag3a:SetToAlpha(0)
    NS.AlertFrame.anim.ag3a:SetOrder(3)
    NS.AlertFrame.anim.ag3a:SetSmoothing("OUT")
    NS.AlertFrame.anim.ag3 = NS.AlertFrame.anim.ag3 or NS.AlertFrame.anim:CreateAnimation("Translation")
    NS.AlertFrame.anim.ag3:SetOffset(0, 200)
    NS.AlertFrame.anim.ag3:SetDuration(0.6)
    NS.AlertFrame.anim.ag3:SetOrder(3)
    NS.AlertFrame.anim.ag3:SetSmoothing("OUT")
end

--> Initialize Alerts <----------------------------------------------
function NS.InitializeAlerts()
    CreateAlertFrame()
end

--> Stealth Alert <--------------------------------------------------
local StealthSoundReadyToPlay = true

--> Stealth Chat Output <--------------------------------------------
local function StealthChatOutput(player, icon, text)
    -- print chat output
    if NS.Options.StealthAlert.ChatAlert then
        NS.PrintAddonMessage(
        player .. "|cffbbbbbb used|r |T" .. icon .. ":0|t " .. NS.ColorsLUT["stealth"]:WrapTextInColorCode(text)
        )
    end
end

--> Stealth PopUp <--------------------------------------------------
local function StealthPopUp(player, icon, text)
    if (not NS.ZoneKnown) or NS.LoadingScreenActive then
        C_Timer_After(
        0.2,
            function()
                StealthPopUp(player, icon, text)
            end
        )
        return
    end
    -- Stealth Pop Upvalues
    if NS.Options.StealthAlert.DisableVisualStealthAlertsInSanctuary and NS.Zone.pvpType == "sanctuary" then
        return
    end

    if NS.AlertFrame.anim:IsPlaying() then
        NS.AlertFrame.anim:Stop()
    end

    NS.AlertFrame.Icon:SetTexture(icon)
    NS.AlertFrame.eventText:SetText(text .. " Detected")
    NS.AlertFrame.playerText:SetText(player)
    NS.AlertFrame:SetHeight(NS.AlertFrame.eventText:GetTop() - NS.AlertFrame.playerText:GetBottom() + 14)
    NS.AlertFrame:SetWidth(
    NS.AlertFrame.playerText:GetWidth() + NS.AlertFrame.eventText:GetWidth() + NS.AlertFrame.div:GetWidth() +
        NS.AlertFrame:GetHeight()
    )
    NS.AlertFrame:SetPoint("TOP", UIParent, "CENTER", 0, UIParent:GetTop() / 3)
    NS.AlertFrame.Icon:SetSize(NS.AlertFrame:GetHeight(), NS.AlertFrame:GetHeight())
    NS.AlertFrame.anim:Play()
end

--> 🔊 Play Audio Alert <---------------------------------------------
local AlertSoundReadyToPlay = true
local function PlayAudioAlert(url, now, channel)
    if (not NS.ZoneKnown) or NS.LoadingScreenActive then
        return
    end

    channel = channel or "Master"
    if now or AlertSoundReadyToPlay then
        PlaySoundFile(url, channel)
        AlertSoundReadyToPlay = nil
        C_Timer_After(
        0.6,
            function()
                AlertSoundReadyToPlay = true
            end
        )
    end
end

--> Stealth Audio Alert <--------------------------------------------
local stealthAudioPending = nil
local function StealthAudioAlert()
    if (not NS.ZoneKnown) or NS.LoadingScreenActive then
        if stealthAudioPending then
            return
        end
        stealthAudioPending = true
        C_Timer_After(
        0.1,
            function()
                StealthAudioAlert()
            end
        )
        return
    end
    stealthAudioPending = nil
    -- Stealth Sound Alert
    if StealthSoundReadyToPlay and NS.Options.StealthAlert.EnableSound then
        if NS.Zone.instance == "pvp" and NS.Options.StealthAlert.DisableSoundInBG == true then
            return
        end
        if NS.Zone.pvpType == "sanctuary" and NS.Options.StealthAlert.DisableSoundInSanctuary == true then
            return
        end

        PlayAudioAlert(SM:Fetch("sound", NS.Options.StealthAlert.SoundFile), true, NS.Options.StealthAlert.SoundChannel)
        StealthSoundReadyToPlay = false
        C_Timer_After(
        1,
            function()
                StealthSoundReadyToPlay = true
            end
        )
    end
end



--> Stealth Alert Event <--------------------------------------------
function NS.StealthAlertEvent(event, player, icon)
    if (not event) or (not player) or (not icon) then
        return
    end
    StealthAudioAlert()
    StealthChatOutput(player, icon, event)
    StealthPopUp(player, icon, event)
end

--> ✔️ New Player Alert Check <--------------------------------------
function NS.NewPlayerAlert()
    if (not NS.ZoneKnown) or NS.LoadingScreenActive then
        return
    end
    -- Sound Enabled?
    if not NS.Options.AudioAlerts.DetectedPlayerSound then
        return
    end
    -- Sound to be played in BGs?
    if NS.Zone.instance ~= "none" and NS.Options.AudioAlerts.DetectedPlayerSoundBGDisabled == true then
        return
    end
    -- Sound in sanctuary zones?
    if NS.Options.AudioAlerts.DisableInSanctuary == true and NS.Zone.pvpType == "sanctuary" then
        return
    end

    -- ▶️ PLAY
    PlayAudioAlert(
    SM:Fetch("sound", NS.Options.AudioAlerts.DetectedPlayerSoundFile),
        false,
        NS.Options.AudioAlerts.SoundChannel
    )
end

--> 🎯 KOS Alert <----------------------------------------------------
function NS.KOSAlert(GUID)
    -- Audio Alert
    if NS.Options.KOS.AudioAlert then
        PlayAudioAlert(SM:Fetch("sound", NS.Options.KOS.AudioAlertFile), true, NS.Options.KOS.SoundChannel)
    end
    -- Flash OS program icon (taskbar)
    if NS.Options.KOS.TaskbarAlert then
        FlashClientIcon()
    end
    -- Chat Alert
    if NS.Options.KOS.ChatAlert then
        NS.PrintAddonMessage(
        "|TInterface/Addons/weizPVP/Media/Icons/kos.tga::0|t " ..
            NS.FormatPlayerNameAndRealm(NS.PlayerActiveCache[GUID].displayName, GUID) .. "|cff8fdaff detected!|r "
        )
    end
end

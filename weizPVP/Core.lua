---------------------------------------------------------------------------------------------------
--|> CORE
---------------------------------------------------------------------------------------------------
local _, NS = ...
NS = NS or {}

--: 🆙 Upvalues
local CopyTable = CopyTable

--: Settings
weizPVP.ENABLED = false

--|> Addon Control Functions
---------------------------------------------------------------------------------------------------
--> Enable
function weizPVP:OnEnable()
    if not weizPVP.ENABLED then
        weizPVP.ENABLED = true
        self:CancelAllTimers()
        NS.Options.Addon.Enabled = true
        NS.SetWindowSettings()
        NS.EnableEvents()
        self:ScheduleRepeatingTimer(NS.PulseEvent, 1)
    end
end

--> Disable <--------------------------------------------------------
function weizPVP:OnDisable()
    if weizPVP.ENABLED then
        weizPVP.ENABLED = false
        self:CancelAllTimers()
        NS.DisableEvents()
        NS.ClearListData()
        NS.Options.Addon.Enabled = false
        NS.SetWindowSettings()
    end
end

-- ⚒️ Clear List Data
function weizPVP_ClearListData()
    NS.ClearListData()
end

-- ⚒️ Toggle Window <--------------------------------------------------
function weizPVP_ToggleWindows()
    if NS.Options.Addon.Enabled then
        NS.Options.Window.Visible = not NS.Options.Window.Visible
        NS.SetWindowSettings()
    end
end

-- ⚒️ Toggle Crosshair <-----------------------------------------------
function weizPVP_ToggleCrosshair()
    NS.Crosshair.Toggle()
end

-- ⚒️ Reset All Customization <----------------------------------------
function NS.ResetAllCustomizations()
    NS.Options.Frames.Header = CopyTable(NS._DefaultOptions.profile.Options.Frames.Header)
    NS.Options.Frames.StatusPopUp = CopyTable(NS._DefaultOptions.profile.Options.Frames.StatusPopUp)
    NS.Options.Bars = CopyTable(NS._DefaultOptions.profile.Options.Bars)
    NS.Options.Frames.Scale = NS._DefaultOptions.profile.Options.Frames.Scale
    NS.Options.Frames.AutoScaleEnabled = NS._DefaultOptions.profile.Options.Frames.AutoScaleEnabled
    NS.Options.Frames.AutoScaleMultiplier = NS._DefaultOptions.profile.Options.Frames.AutoScaleMultiplier
    NS.Options.Frames.BackgroundColor = NS._DefaultOptions.profile.Options.Frames.BackgroundColor
    NS.CoreUI.Initialize()
end

-- ⚒️ Print Addon Message <--------------------------------------------
function NS.PrintAddonMessage(msg)
    (SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME):AddMessage(
    "|TInterface/Addons/weizPVP/Media/weizpvp_chat.tga:0|t " .. msg
    )
end

-- ⚒️ Bindings <-------------------------------------------------------
function NS.SetupBindings()
    _G.BINDING_HEADER_WEIZPVP = NS.Constants.AddonString
    _G.BINDING_NAME_WEIZPVPTOGGLE = "Toggle Window Visibility"
    _G.BINDING_NAME_WEIZPVPCLEARPLAYERLIST = "Clear Player List"
    _G.BINDING_NAME_WEIZPVPTOGGLECROSSHAIR = "Toggle Crosshair"
end

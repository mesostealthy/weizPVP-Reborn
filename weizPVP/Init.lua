--|> INIT
-- 📌 Loads saved options or applies defaults.
-- 📌 Checks for database changes and applies updates when needed.
-- 📌 Loads player data.
---------------------------------------------------------------------------------------------------
local ADDON_NAME, NS = ...

-- ⬆️ Upvalues
local GetUnitName = GetUnitName
local GetRealmName = GetRealmName
local UnitFactionGroup = UnitFactionGroup
local GetAddOnMetadata = GetAddOnMetadata
local UnitGUID = UnitGUID
local UnitLevel = UnitLevel
local gsub = gsub
local select = select

--: Build Addon Global
_G.weizPVP = _G.weizPVP or LibStub("AceAddon-3.0"):NewAddon("weizPVP", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

--|> 📚 LIB SHARED MEDIA
---------------------------------------------------------------------------------------------------
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

--: Status Bars
SM:Register("STATUSBAR", "weizPVP: StatusBar", [[Interface\Addons\weizPVP\Media\Textures\bar-default.tga]])
SM:Register("STATUSBAR", "weizPVP: SolidStatus", [[Interface\BUTTONS\WHITE8X8]])

--: Backgrounds
SM:Register("BACKGROUND", "weizPVP: #FFFFFF", [[Interface\BUTTONS\WHITE8X8]])
SM:Register("BACKGROUND", "weizPVP: Bar-BG", [[Interface\Addons\weizPVP\Media\Textures\bar-default.tga]])

--: Borders
SM:Register("BORDER", "weizPVP: Border", [[Interface\BUTTONS\WHITE8X8]])

--: Fonts
SM:Register("FONT", "Roboto Condensed", [[Interface\Addons\weizPVP\Media\Fonts\RobotoCondensed.ttf]])
SM:Register("FONT", "Roboto Condensed Bold", [[Interface\Addons\weizPVP\Media\Fonts\RobotoCondensed-Bold.ttf]])
SM:Register("FONT", "Roboto Condensed BoldItalic", [[Interface\Addons\weizPVP\Media\Fonts\RobotoCondensed-BoldItalic.ttf]])
SM:Register("FONT", "Accidental Presidency", [[Interface\Addons\weizPVP\Media\Fonts\AccidentalPresidency.ttf]])
SM:Register("FONT", "Accidental Presidency Italic", [[Interface\Addons\weizPVP\Media\Fonts\AccidentalPresidency-Italic.ttf]])

--: Sounds
SM:Register("SOUND", "weizPVP: MLG Air Horn 1", [[Interface\Addons\weizPVP\Media\Sounds\airhorn-1.ogg]])
SM:Register("SOUND", "weizPVP: Beep 1", [[Interface\Addons\weizPVP\Media\Sounds\beep-1.ogg]])
SM:Register("SOUND", "weizPVP: Beep 2", [[Interface\Addons\weizPVP\Media\Sounds\beep-2.ogg]])
SM:Register("SOUND", "weizPVP: Error 1", [[Interface\Addons\weizPVP\Media\Sounds\error-1.ogg]])
SM:Register("SOUND", "weizPVP: Notice 1", [[Interface\Addons\weizPVP\Media\Sounds\notice-1.ogg]])
SM:Register("SOUND", "weizPVP: Notice 2", [[Interface\Addons\weizPVP\Media\Sounds\notice-2.ogg]])
SM:Register("SOUND", "weizPVP: Notice 3", [[Interface\Addons\weizPVP\Media\Sounds\notice-3.ogg]])
SM:Register("SOUND", "weizPVP: Warning 1", [[Interface\Addons\weizPVP\Media\Sounds\warning-1.ogg]])
SM:Register("SOUND", "weizPVP: Warning 2", [[Interface\Addons\weizPVP\Media\Sounds\warning-2.ogg]])
SM:Register("SOUND", "weizPVP: Warning 3", [[Interface\Addons\weizPVP\Media\Sounds\warning-3.ogg]])
SM:Register("SOUND", "weizPVP: Warning 4", [[Interface\Addons\weizPVP\Media\Sounds\warning-4.ogg]])

-- ⬅️ Get Player Info
----------------------------------------------------------------
local function GetPlayerInfo()
    NS.Player = NS.Player or {}
    NS.Player.GUID = UnitGUID("player")
    NS.Player.Name = GetUnitName("player")
    NS.Player.Faction = select(1, UnitFactionGroup("player"))
    NS.Player.Level = UnitLevel("player")
    NS.Player.FromRealm = GetRealmName()
    NS.Player.FromSubRealm = gsub(NS.Player.FromRealm, "[%s%-]", "")
    NS.PlayerRealm = NS.Player.FromSubRealm
end

-- ⬅️ Get Addon Info
----------------------------------------------------------------
local function SetAddonInfo()
    weizPVP.Database_Version = 3
    weizPVP.Addon_Version = GetAddOnMetadata(ADDON_NAME, "Version")
end

-- ✨ Initialize
----------------------------------------------------------------
function weizPVP.OnInitialize()
    -- Initialization starting
    NS.addonInitializing = true

    -- Player and Addon settings loading
    GetPlayerInfo()
    SetAddonInfo()

    -- Bindings and Interface Options
    NS.SetupBindings()
    NS.CreateInterfaceOptions()

    -- Database
    NS.LoadDB()
    NS.InitializeAlerts()

    if NS.Options.Crosshair.Enabled then
        NS.Crosshair.Enable()
    else
        NS.Crosshair.Disable()
    end

    NS.KOS.Enable()
end

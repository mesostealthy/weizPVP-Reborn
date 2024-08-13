---------------------------------------------------------------------------------------------------
--|> ZONE DETECTION
-- TODO : Rework entire module
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local select = select
local wipe = wipe
local C_Timer_After = C_Timer.After
local IsInInstance = IsInInstance
local GetZoneText = GetZoneText
local GetZonePVPInfo = GetZonePVPInfo
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local StaticPopup_Show = StaticPopup_Show

--: Locals :---------------------------
NS.Zone = {}
NS.Zone.instance = ""
NS.Zone.pvpType = ""
NS.Zone.InInstance = nil
NS.ZoneKnown = nil
NS.LoadingScreenActive = true

--> Is Enabled Area? <-----------------------------------------------
local function IsEnabledArea()
    -- Warmode check
    NS.Player.WarMode = C_PvP.IsWarModeDesired()

    -- Sanctuary check
    if NS.Options.Addon.DisabledInSanctuary and NS.Zone.pvpType == "sanctuary" then
        return false
    end

    -- Instance or World?
    if NS.Zone.instance ~= "none" then ---- INSTANCE --------------------------
        -- BG Instance Check
        if NS.Zone.instance == "pvp" and NS.Options.Addon.EnabledInBattlegrounds then
            return true
        end

        -- Arena Instance Check
        if NS.Zone.instance == "arena" and NS.Options.Addon.EnabledInArena then
            return true
        end

        -- Options to be displayed are not enabled; disable the window
        return false
    else ---- WORLD -------------------------------------------------------------
        -- War Mode Check
        if (not NS.Player.WarMode) and NS.Options.Addon.DisabledWhenWarmodeOff then
            -- check if sanctuaries are allowed while WM is disabled
            if (not NS.Options.Addon.DisabledWhenWarmodeOffSanctuaries) and NS.Zone.pvpType == "sanctuary" then
                return true
            else
                return false
            end
        else
            return true
        end
    end
end

--> Get Zone Type <--------------------------------------------------
-- local gettingZone = nil
local inInstance = nil
local reattemptInQueue = nil
local FirstLogin = true

local function GetZoneType()
    -- Are we initializing still?
    if NS.addonInitializing then
        if not reattemptInQueue then
            reattemptInQueue = true
            C_Timer_After(0.5, GetZoneType)
            NS.ZoneKnown = nil
        end
        return
    end

    -- Not quite ready....
    if (GetZoneText() == "") or NS.LoadingScreenActive or (C_PvP.IsWarModeDesired() == nil) then
        if not reattemptInQueue then
            reattemptInQueue = true
            C_Timer_After(0.5, GetZoneType)
            NS.ZoneKnown = nil
        end
        return
    end

    -- Good to go! No more waiting
    reattemptInQueue = nil
    NS.Player.WarMode = C_PvP.IsWarModeDesired() -- get war mode
    NS.Zone.pvpType = select(1, GetZonePVPInfo()) -- get pvp zone type
    NS.Zone.InInstance, NS.Zone.instance = IsInInstance() -- bool; in instance? false if world

    -- instance change? to or from?
    if NS.Zone.InInstance ~= inInstance then
        if FirstLogin then
            C_Timer_After(0.5, GetZoneType)
            FirstLogin = nil
            -- else
            --   NS.ClearListData()
        end
        NS.ClearListData()
        inInstance = NS.Zone.InInstance
    end

    -- Are we in a valid instance/zone?
    if IsEnabledArea() then
        weizPVP:OnEnable()
    else
        weizPVP:OnDisable()
    end

    NS.ZoneKnown = true
end

--> Get PVP Zone <---------------------------------------------------
function NS.GetPVPZone()
    GetZoneType()
end

--> ⚡ LOADING_SCREEN_ENABLED ------------------------------
function NS.LoadingScreenEnabled()
    NS.ZoneKnown = nil
    NS.LoadingScreenActive = true
end

--> ⚡ LOADING_SCREEN_DISABLED -----------------------------
function NS.LoadingScreenDisabled()
    NS.LoadingScreenActive = nil
    NS.ZoneKnown = nil
    C_Timer_After(0.2, GetZoneType)
end

--> ⚡ Entering Battleground Instance ----------------------
function NS.PlayerEnteringBattlegroundEvent()
    NS.GetPVPZone()
    wipe(NS.CurrentNameplates)
end

--> ⚡ ZONE_CHANGED_NEW_AREA -------------------------------
function NS.ZoneChangedNewAreaEvent()
    NS.GetPVPZone()
end

--> ⚡ AREA_POIS_UPDATED -----------------------------------
function NS.AreaPositionUpdated()
    NS.GetPVPZone()
end

--> ⚡ Player Entering World -------------------------------
function NS.PlayerEnteringWorldEvent()
    if NS.addonInitializing then -- check if this is the first 'entering world' run since init was ran
        NS.PrintAddonMessage(
        NS.Constants.AddonString ..
            " |cffcccccc" .. GetAddOnMetadata("weizPVP", "Version") .. "|r : |cff37ff37Initialized!|r"
        )
        NS.addonInitializing = nil
    end

    -- ENABLE
    NS.EnableLDB()
    wipe(NS.CurrentNameplates)
    NS.Crosshair.NewTarget() -- check for target
    if NS.databaseReset then -- database update check for pre-1.9.0
        C_Timer_After(
        1,
            function()
                NS.databaseReset = nil
                StaticPopup_Show("WEIZPVP_UPGRADE_DB_RESET")
                NS.PrintAddonMessage("|cffFFA200Saved options and data have been reset!|r")
                NS.PrintAddonMessage(
                "The database reset was required to resolve potential issues with the new KOS features and player tracking, especially for players that play on multiple realms."
                )
                NS.PrintAddonMessage(
                "Database updates in the future will migrate all your data and settings; No more resets will be needed."
                )
            end
        )
    end
    NS.CoreUI.Initialize()
    NS.SetWindowSettings()
    GetZoneType()
end

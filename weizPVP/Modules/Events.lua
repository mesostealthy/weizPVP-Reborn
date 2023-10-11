---------------------------------------------------------------------------------------------------
--|> EVENTS
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local wipe = wipe
local UnitGUID = UnitGUID
local UnitLevel = UnitLevel
local C_Timer_After = C_Timer.After

NS.PlayerActiveCache = NS.PlayerActiveCache or {}

--> ENABLE EVENTS ---------------------------------------------------
function NS.EnableEvents()
    -- ADDON
    weizPVP:RegisterEvent("ADDON_LOADED", NS.AddonLoadedEvent)
    -- DATA COLLECTION
    weizPVP:RegisterEvent("NAME_PLATE_UNIT_ADDED", NS.NameplateAdded)
    weizPVP:RegisterEvent("NAME_PLATE_UNIT_REMOVED", NS.NameplateRemoved)
    weizPVP:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", NS.CombatLogEvent)
    weizPVP:RegisterEvent("PLAYER_TARGET_CHANGED", NS.PlayerTargetEvent)
    weizPVP:RegisterEvent("UPDATE_MOUSEOVER_UNIT", NS.PlayerMouseoverEvent)
    weizPVP:RegisterEvent("UNIT_HEALTH", NS.UnitHealthEvent)
    weizPVP:RegisterEvent("UNIT_TARGET", NS.UnitTargetEvent)
    weizPVP:RegisterEvent("UNIT_FLAGS", NS.UnitFlagsChanged)
    -- ZONE CHANGED
    weizPVP:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND", NS.PlayerEnteringBattlegroundEvent)
    weizPVP:RegisterEvent("PLAYER_ENTERING_WORLD", NS.PlayerEnteringWorldEvent)
    weizPVP:RegisterEvent("ZONE_CHANGED_NEW_AREA", NS.ZoneChangedNewAreaEvent)
    weizPVP:RegisterEvent("AREA_POIS_UPDATED", NS.AreaPositionUpdated)
    weizPVP:RegisterEvent("LOADING_SCREEN_ENABLED", NS.LoadingScreenEnabled)
    weizPVP:RegisterEvent("LOADING_SCREEN_DISABLED", NS.LoadingScreenDisabled)
    -- COMBAT/PVP
    -- weizPVP:RegisterEvent("WAR_MODE_STATUS_UPDATE", NS.WarModeChanged) --no longer working, thanks blizz -_-
    weizPVP:RegisterEvent("PLAYER_REGEN_DISABLED", NS.EnteringCombat)
    weizPVP:RegisterEvent("PLAYER_REGEN_ENABLED", NS.LeavingCombat)
    -- PLAYER UPDATES
    weizPVP:RegisterEvent("UI_INFO_MESSAGE", NS.UiInfoMessage)
    weizPVP:RegisterEvent("PLAYER_LEVEL_UP", NS.PlayerLevelUp)
    -- DISPLAY CHANGES
    weizPVP:RegisterEvent("DISPLAY_SIZE_CHANGED", NS.UpdateDisplayData)
    -- Crosshair
    NS.Crosshair.Enable()
end

--> DISABLE EVENTS <-------------------------------------------------
function NS.DisableEvents()
    -- ADDON
    weizPVP:UnregisterEvent("ADDON_LOADED")
    -- DATA COLLECTION
    weizPVP:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    weizPVP:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
    weizPVP:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    weizPVP:UnregisterEvent("PLAYER_TARGET_CHANGED")
    weizPVP:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
    weizPVP:UnregisterEvent("UNIT_HEALTH")
    weizPVP:UnregisterEvent("UNIT_TARGET")
    weizPVP:UnregisterEvent("UNIT_FLAGS")
    -- COMBAT/PVP
    weizPVP:UnregisterEvent("PLAYER_REGEN_DISABLED")
    weizPVP:UnregisterEvent("PLAYER_REGEN_ENABLED")
    -- PLAYER UPDATES
    weizPVP:UnregisterEvent("PLAYER_LEVEL_UP")
    -- DISPLAY CHANGES
    weizPVP:UnregisterEvent("DISPLAY_SIZE_CHANGED")
    -- Crosshair
    NS.Crosshair.Disable()
end

---------------------------------------------------------------------------------------------------
--|> ⚡ EVENTS ⚡ <|-------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--|> PLAYER
-------------------------------------------------------------------------------

--> ⚡ PLAYER LEVELED UP -----------------------------------
function NS.PlayerLevelUp()
    NS.Player.Level = UnitLevel("player")
end

--> ⚡ DISPLAY_SIZE_CHANGED --------------------------------
function NS.UpdateDisplayData()
    NS.CoreUI.Initialize()
end

--> ⚡ UI_INFO_MESSAGE -------------------------------------
function NS.UiInfoMessage(_, msgType, _)
    if msgType == 1035 or msgType == 998 then
        NS.WarModeChanged(false)
    elseif msgType == 1034 then
        NS.WarModeChanged(true)
    end
end

--> ⚡ WAR_MODE_STATUS_UPDATE ------------------------------
function NS.WarModeChanged(input)
    NS.Player.WarMode = input or C_PvP.IsWarModeDesired()
    NS.GetPVPZone()
    C_Timer_After(
    0.5,
        function()
            NS.GetPVPZone()
        end
    )
end

--|> UNITS
-------------------------------------------------------------------------------

--> ⚡ MOUSEOVER ------------------------------------------
function NS.PlayerMouseoverEvent()
    NS.GetUnitData("mouseover")
end

--> ⚡ TARGET_CHANGED --------------------------------------
function NS.PlayerTargetEvent()
    NS.GetUnitData("target")
    NS.Crosshair.NewTarget()
    NS.CoreUI.ChangeTargetIcon()
end

--> ⚡ NAMEPLATE_ADDED -------------------------------------
function NS.NameplateAdded(_, unit)
    if NS.IsUnitValidForTracking(unit) then
        NS.GetUnitData(unit)
        NS.CurrentNameplates[UnitGUID(unit)] = true
    end
end

--> ⚡ NAMEPLATE_REMOVED -----------------------------------
function NS.NameplateRemoved(_, unit)
    if NS.IsUnitValidForTracking(unit) then
        if NS.IsUnitValidForTracking(unit) then
            NS.CurrentNameplates[UnitGUID(unit)] = nil
        end
    end
end

--> ⚡ UNIT TARGET -----------------------------------------
function NS.UnitTargetEvent(_, unit)
    NS.GetUnitData(unit)
end

--> ⚡ UNIT FLAGS CHANGED ----------------------------------
function NS.UnitFlagsChanged(_, unit)
    local GUID = UnitGUID(unit)
    if (not NS.IsUnitValidForTracking(unit)) and NS.PlayerActiveCache[GUID] then
        wipe(NS.PlayerActiveCache[GUID])
        NS.PlayerActiveCache[GUID] = nil
        if NS.CurrentList[GUID] then
            wipe(NS.CurrentList[GUID])
            wipe(NS.NearbyList[GUID])
        end
        NS.CurrentList[GUID] = nil
        NS.NearbyList[GUID] = nil
        NS.SortNearbyList()
        if NS.PlayersOnBars[GUID] then
            NS.RefreshCurrentList()
        end
    end
end

--|> ADDON
-------------------------------------------------------------------------------

--> ⚡ ADDON_LOADED ----------------------------------------
function NS.AddonLoadedEvent()
    NS.Crosshair.OnLoad()
    weizPVP:UnregisterEvent("ADDON_LOADED")
end

--|> COMBAT
-------------------------------------------------------------------------------

--> ⚡ ENTERING COMBAT -------------------------------------
function NS.EnteringCombat()
    NS.CoreUI.CombatStart()
end

--> ⚡ LEAVING COMBAT --------------------------------------
function NS.LeavingCombat()
    NS.ManageListTimeouts()
    NS.CoreUI.CombatEnd()
end

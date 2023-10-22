---------------------------------------------------------------------------------------------------
--|> Dynamic Processing
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local GetFramerate = GetFramerate
local wipe = wipe

--: Settings :-------------------------
local FPS_THRESHOLD = 10
local TARGET_FPS = GetCVar("TargetFPS")
NS.DYNAMIC_PROCESSING_ACTIVE = nil

--> Dynamic Processing <---------------------------------------------
function NS.DynamicProcessing()
    if GetFramerate() < TARGET_FPS - FPS_THRESHOLD then
        if not NS.DYNAMIC_PROCESSING_ACTIVE then
            weizPVP:UnregisterEvent("UNIT_TARGET")
            weizPVP:UnregisterEvent("UNIT_HEALTH")
            weizPVP:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
            weizPVP:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
            wipe(NS.CurrentNameplates)
            NS.DYNAMIC_PROCESSING_ACTIVE = true
        end
    elseif NS.DYNAMIC_PROCESSING_ACTIVE then
        weizPVP:RegisterEvent("UNIT_TARGET", NS.UnitTargetEvent)
        weizPVP:RegisterEvent("UNIT_HEALTH", NS.UnitHealthEvent)
        weizPVP:RegisterEvent("NAME_PLATE_UNIT_ADDED", NS.NameplateAdded)
        weizPVP:RegisterEvent("NAME_PLATE_UNIT_REMOVED", NS.NameplateRemoved)
        NS.DYNAMIC_PROCESSING_ACTIVE = nil
    end
end

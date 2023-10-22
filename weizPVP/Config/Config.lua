---------------------------------------------------------------------------------------------------
--|> CONFIG
-- 📌 Slash Commands and Interface Options
---------------------------------------------------------------------------------------------------
local ADDON_NAME, NS = ...

--: ⬆️ Upvalues :--
local Settings_OpenToCategory = Settings.OpenToCategory
local SettingsPanel_CategoryList_ScrollBar = SettingsPanel.CategoryList.ScrollBar
local wipe = wipe

--|> CONFIG FUNCTIONS
--> RESET ALL
-----------------------------------------------------------
function NS.ResetAll()
    StaticPopup_Show("WEIZPVP_CONFIRM_RESET_ALL")
end

--> RESET OPTIONS
-----------------------------------------------------------
function NS.ResetOptions()
    StaticPopup_Show("WEIZPVP_CONFIRM_RESET_OPTIONS")
end

--> RESET PLAYER DB
-----------------------------------------------------------
function NS.ResetPlayerDB()
    StaticPopup_Show("WEIZPVP_CONFIRM_RESET_PLAYER_DB")
end

--> TOGGLE OPTIONS
-----------------------------------------------------------
function NS.ToggleOptions()
    if SettingsPanel:IsShown() then
        SettingsPanel:Hide()
    else
        Settings_OpenToCategory(ADDON_NAME) -- open options to ADDON_NAME
        --TODO: fix below -Meso
        --local _, max = SettingsPanel_CategoryList_ScrollBar:GetMinMaxValues() -- Get scrollbar min/max
        --SettingsPanel_CategoryList_ScrollBar:SetValue(max) -- Set scrollbar to max (top)
        Settings_OpenToCategory(ADDON_NAME) -- open options again (wow bug workaround)
    end
end

-- addon compartment - toggle settings
function weizPVP_AddonCompartmentOnClick(addonName, buttonName)
	NS.ToggleOptions()
end

--> VERSION UPGRADE CHECK
-----------------------------------------------------------
function NS.VersionUpgradeCheck()
    local upgrade = false
    -- version checks
    if not _weizpvp_global_info then -- check for migration (pre-1.9.1)
        if _weizpvp_addon then -- check for upgrade (pre-1.9.0)
            wipe(_weizpvp_addon)
            _weizpvp_addon = nil
        else
            upgrade = true
        end
    end
    -- Update addon info
    _weizpvp_global_info = {
    Database_Version = weizPVP.Database_Version,
    Addon_Version = weizPVP.Addon_Version
    }
    -- Upgrade / Wipe ?
    if upgrade then
        NS.globalDB.global = {}
        NS.databaseReset = true
    end
end

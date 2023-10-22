---------------------------------------------------------------------------------------------------
--|> LDB
---------------------------------------------------------------------------------------------------
local ADDON_NAME, NS = ...

--: Load LDB library :-----------------
local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then
    return
end

--> Create Plugin <--------------------------------------------------
local plugin =
ldb:NewDataObject(
ADDON_NAME,
    {
    type = "data source",
    text = "0",
    icon = "Interface/AddOns/weizPVP/Media/weizpvp_minimap.tga"
    }
)

--> ON CLICK <-------------------------------------------------------
function plugin.OnClick(_, button)
    if button == "RightButton" then --: RIGHT-CLICK: Toggle Interface Options
        NS.ToggleOptions()
    elseif button == "LeftButton" then --: LEFT-CLICK: Toggle window
        if weizPVP.ENABLED then
            NS.Options.Window.Visible = not NS.Options.Window.Visible
            NS.SetWindowSettings()
            _G.LibDBIconTooltip:ClearLines()
            plugin.OnTooltipShow(_G.LibDBIconTooltip)
        end
    end
end

--> Enable LDB <-----------------------------------------------------
function NS.EnableLDB()
    hooksecurefunc(
    NS,
        "UpdateNearbyCount",
        function()
            plugin.text = weizPVP_CoreBar.Title:GetText()
            plugin.icon = "Interface/AddOns/weizPVP/Media/weizpvp_minimap.tga"
        end
    )
end

--> Tooltip Show <---------------------------------------------------
function plugin.OnTooltipShow(tip)
    if not weizPVP.ENABLED then
        tip:AddDoubleLine(NS.Constants.AddonString .. " |cff999999(disabled)|r", "")
    elseif not NS.Options.Window.Visible then
        tip:AddDoubleLine(NS.Constants.AddonString .. " |cffbbbbbb(hidden)|r", weizPVP_CoreBar.Title:GetText())
    else
        tip:AddDoubleLine(NS.Constants.AddonString, weizPVP_CoreBar.Title:GetText())
    end
    tip:AddLine(" ")
    tip:AddDoubleLine(NS.ColorsLUT["uiMouse"]:WrapTextInColorCode("Right-Click"), "Toggle Options")
    tip:AddDoubleLine(NS.ColorsLUT["uiMouse"]:WrapTextInColorCode("Left-Click"), "Toggle Main Window")
end

--: Local Event Frame :----------------
local f = CreateFrame("Frame")
f:SetScript(
"OnEvent",
    function()
        NS.LDBIcon = NS.LDBIcon or LibStub("LibDBIcon-1.0", true)
        if not NS.LDBIcon then
            return
        end
        NS.LDBIcon:Register(ADDON_NAME, plugin, NS.Options.LDB)
        if NS.Options.LDB.minimap then
            LibStub("LibDBIcon-1.0"):Show(ADDON_NAME)
        else
            LibStub("LibDBIcon-1.0"):Hide(ADDON_NAME)
        end
    end
)

-- Register Login
f:RegisterEvent("PLAYER_LOGIN")

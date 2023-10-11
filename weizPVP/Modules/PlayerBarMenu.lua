---------------------------------------------------------------------------------------------------
--|> PLAYER BAR MENU
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local gsub = gsub
local GetClassColor = GetClassColor
local WrapTextInColorCode = WrapTextInColorCode
local select = select
local wipe = wipe

local menuPlayerGUID = ""
local info = {}

--> OnLoad <---------------------------------------------------------
function weizPVP_PlayerBarMenu_OnLoad()
    if not NS.PlayerActiveCache[menuPlayerGUID] then
        return
    end
    -- NAME
    local printedName =
    WrapTextInColorCode(
    gsub(NS.KOS.menuPlayerName, "-(.*)", ""),
        select(4, GetClassColor(NS.PlayerDB[NS.KOS.menuPlayerName].C))
    )
    local printedRealm = gsub(NS.KOS.menuPlayerName, "^(.*-)", "")
    info.text = printedName .. " |cffbbbbbb-|r |cffdddddd" .. printedRealm .. "|r"
    info.notCheckable = 1
    info.notClickable = 1
    info.padding = 0
    info.leftPadding = 0
    UIDropDownMenu_AddButton(info)
    -- KOS TOGGLE
    wipe(info)
    info.text = NS.KOS.SetMenuText(NS.KOS.menuPlayerName)
    info.notCheckable = 1
    info.padding = 0
    info.leftPadding = 0
    info.func = function()
        NS.KOS.ChangeKosStatus(NS.KOS.menuPlayerName)
    end
    UIDropDownMenu_AddButton(info)
    wipe(info)
end

--> Player Bar Menu: On Click <--------------------------------------
function NS.PlayerBarMenu_OnClick(bar)
    if not bar then
        return
    end
    NS.KOS.menuPlayerName = bar.fullName
    menuPlayerGUID = bar.GUID
    ToggleDropDownMenu(1, nil, weizPVP_PlayerBarMenu, "cursor", 0, 0)
end

---------------------------------------------------------------------------------------------------
--|> TAINT PREVENTION AND BCC COMPATABILITY <|-----------------------------------------------------
---------------------------------------------------------------------------------------------------

--> WPVP_DropDownMenuButtonMixin <-----------------------------------
WPVP_DropDownMenuButtonMixin = WPVP_DropDownMenuButtonMixin or {}
function WPVP_DropDownMenuButtonMixin:OnEnter(...)
    ExecuteFrameScript(self:GetParent(), "OnEnter", ...)
end

function WPVP_DropDownMenuButtonMixin:OnLeave(...)
    ExecuteFrameScript(self:GetParent(), "OnLeave", ...)
end

function WPVP_DropDownMenuButtonMixin:OnMouseDown()
    if self:IsEnabled() then
        ToggleDropDownMenu(nil, nil, self:GetParent())
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
end

--> WPVP_LargeDropDownMenuButtonMixin <-----------------------------------
WPVP_LargeDropDownMenuButtonMixin = WPVP_LargeDropDownMenuButtonMixin or CreateFromMixins(WPVP_DropDownMenuButtonMixin)
function WPVP_LargeDropDownMenuButtonMixin:OnMouseDown()
    if self:IsEnabled() then
        local parent = self:GetParent()
        ToggleDropDownMenu(nil, nil, parent, parent, -8, 8)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
end

-----------------------------------------------------------
--|> UNIT MENU
--: Creates a new entry in the unit right click popup menu for adding/removing a player on the KOS list
-----------------------------------------------------------
local _, NS = ...

--> ShowMenu <-------------------------------------------------------
local function ShowMenu(self)
  local isUnitMenu = self.unit and true or false

  if
    (not isUnitMenu) or (not NS.IsUnitValidForTracking(self.unit)) or InCombatLockdown() or
      (UIDROPDOWNMENU_MENU_LEVEL > 1)
   then
    return
  end

  local playerName = NS.GetFullNameOfUnit(self.unit)
  if not NS.PlayerDB[playerName] or not NS.PlayerDB[playerName].C then -- confirm player exists in db
    return
  end
  local classColoredPlayerName = WrapTextInColorCode(playerName, select(4, GetClassColor(NS.PlayerDB[playerName].C)))
  local info = UIDropDownMenu_CreateInfo()
  info.text = NS.KOS.SetMenuText(playerName)
  info.notCheckable = 1
  info.padding = 0
  info.leftPadding = 0
  info.func = function()
    NS.KOS.ChangeKosStatus(classColoredPlayerName)
  end
  UIDropDownMenu_AddButton(info)
end

--> UnitPopup_ShowMenu <---------------------------------------------
hooksecurefunc(
  "UnitPopup_ShowMenu",
  function(self)
    ShowMenu(self)
  end
)

---------------------------------------------------------------------------------------------------
--|> STATIC POPUPS
-- 📌 Popup message dialogs for events that need user intervention
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local wipe = wipe
local Reload_UI = C_UI.Reload

--> Reset All Popup <------------------------------------------------
StaticPopupDialogs["WEIZPVP_CONFIRM_RESET_ALL"] = {
  text = "Are you sure you want to reset all weizPVP settings and wipe its player data?\n|cffff0000This will reload your UI.|r",
  button1 = YES,
  button2 = NO,
  OnAccept = function()
      wipe(NS.charDB)
      wipe(NS.globalDB)
      wipe(NS.Options)
      wipe(NS.PlayerDB)
      wipe(NS.KosList)
      wipe(_weizpvp_chardb)
      wipe(_weizpvp_global_info)
      wipe(_weizpvp_globaldb)
      Reload_UI()
  end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  showAlert = 1,
  OnShow = function(self)
      self:SetFrameStrata("FULLSCREEN_DIALOG")
      self:SetFrameLevel(99)
  end
}

--> Reset Options <--------------------------------------------------
StaticPopupDialogs["WEIZPVP_CONFIRM_RESET_OPTIONS"] = {
  text = "Are you sure you want to reset the weizPVP options & settings?\n|cffff0000This will reload your UI.|r",
  button1 = YES,
  button2 = NO,
  OnAccept = function()
      if NS.charDB.profile and NS.charDB.profile.Options then
          NS.charDB.profile.Options = nil
      end
      NS.Options = nil
      Reload_UI()
  end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  showAlert = 1,
  OnShow = function(self)
      self:SetFrameStrata("FULLSCREEN_DIALOG")
      self:SetFrameLevel(99)
  end
}

--> Reset Customizations <-------------------------------------------
StaticPopupDialogs["WEIZPVP_CONFIRM_RESET_CUSTOMIZATIONS"] = {
  text = "Are you sure you want to revert all customizations and restore default settings?",
  button1 = YES,
  button2 = NO,
  OnAccept = function()
      NS.ResetAllCustomizations()
  end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  showAlert = 1,
  OnShow = function(self)
      self:SetFrameStrata("FULLSCREEN_DIALOG")
      self:SetFrameLevel(99)
  end
}

--> Reset Player Database <------------------------------------------
StaticPopupDialogs["WEIZPVP_CONFIRM_RESET_PLAYER_DB"] = {
  text = "Are you sure you want to wipe the player database?",
  button1 = YES,
  button2 = NO,
  OnAccept = function()
      wipe(NS.globalDB)
      wipe(NS.PlayerDB)
      wipe(NS.PlayerActiveCache)
      wipe(_weizpvp_globaldb)
      NS.globalDB = LibStub("AceDB-3.0"):New("_weizpvp_globaldb", {}, false)
      NS.PlayerDB = NS.globalDB.global
      NS.ClearListData()
  end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  showAlert = 1,
  OnShow = function(self)
      self:SetFrameStrata("FULLSCREEN_DIALOG")
      self:SetFrameLevel(99)
  end
}

--> Version Update - Options and DB reset ---------------------------
StaticPopupDialogs["WEIZPVP_UPGRADE_DB_RESET"] = {
  text = "|cffFFA200weizPVP options and data have been reset due to some major updates!|r\n|cffaaaaaa(Details in chat)|r",
  button1 = OKAY,
  button2 = nil,
  OnAccept = function()
  end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  showAlert = 1,
  OnShow = function(self)
      self:SetFrameStrata("FULLSCREEN_DIALOG")
      self:SetFrameLevel(99)
  end
}

--> Version Update - Options and DB reset ---------------------------
StaticPopupDialogs["WEIZPVP_UPGRADE_1_9_5"] = {
  text = "|cffFFA200Welcome to weizPVP 1.9.5!|r\n|cffeeeeeeThe UI has been completely rebuilt, so you may need to reposition your main frame once.|r",
  button1 = OKAY,
  button2 = nil,
  OnAccept = function()
  end,
  timeout = 30,
  whileDead = 1,
  hideOnEscape = 1,
  showAlert = 1,
  OnShow = function(self)
      self:SetFrameStrata("FULLSCREEN_DIALOG")
      self:SetFrameLevel(99)
  end
}

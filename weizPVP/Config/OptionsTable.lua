---------------------------------------------------------------------------------------------------
--|> OPTIONS TABLE
---------------------------------------------------------------------------------------------------
local ADDON_NAME, NS = ...

--: 🆙 Upvalues :----------------------
local collectgarbage = collectgarbage
local GetCVarDefault = GetCVarDefault
local SecondsToTime = SecondsToTime
local SetCVar = SetCVar
local time = time
local tostring = tostring
local pairs = pairs
local type = type
local next = next
local tonumber = tonumber
local BreakUpLargeNumbers = BreakUpLargeNumbers
local Round = Round
local C_CVar_GetCVar = C_CVar.GetCVar
local C_Timer_After = C_Timer.After

--: Libs :-----------------------------
local SM = LibStub("LibSharedMedia-3.0")
local sounds = SM:List("sound")
local fonts = SM:List("font")
local statusBarTextures = SM:List("statusbar")

--: Locals :---------------------------
local cVarVolumeLUT = {
  ["Master"] = "Sound_MasterVolume",
  ["SFX"] = "Sound_SFXVolume",
  ["Music"] = "Sound_MusicVolume",
  ["Ambience"] = "Sound_AmbienceVolume",
  ["Dialog"] = "Sound_DialogVolume"
}

---------------------------------------------------------------------------------------------------
--|> LOCAL FUNCTIONS <|----------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--> Get Sound Channel Volume <---------------------------------------
local GetSoundChannelVolume = function(channel)
    if channel and cVarVolumeLUT[channel] then
        if Round(C_CVar_GetCVar(cVarVolumeLUT[channel]) * 100) == 0 then
            return "  |cffff4444(0%, muted)|r"
        else
            return "  |cff4fe9ff" .. Round(C_CVar_GetCVar(cVarVolumeLUT[channel]) * 100) .. "|r |cff70edff%|r"
        end
    end
end

--> Validate option input <------------------------------------------
local ValidateNumeric = function(_, val)
    if val ~= nil and val ~= "" and not tonumber(val) then
        return false
    end
    return true
end

---------------------------------------------------------------------------------------------------
--|> INTERFACE OPTIONS / ACE3 OPTIONS TABLE <|-----------------------------------------------------
---------------------------------------------------------------------------------------------------

--> GENERAL GROUP <--------------------
---------------------------------------
local generalGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/general.tga:16|t  |cffffffffGeneral|r",
  type = "group",
  order = 1,
  args = {
    introGeneral = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/general.tga:20|t  |cffffffffGeneral|r",
      type = "header",
      order = 1,
      width = "full"
    },
    --: Options
    minimapIcon = {
      name = " |TInterface/Addons/weizPVP/Media/Icons/minimap_icon.tga:16|t  Show Minimap Icon",
      desc = "Show or hide the weizPVP Minimap Icon.",
      type = "toggle",
      width = "full",
      order = 2,
      get = function()
          return NS.Options.LDB.minimap
      end,
      set = function(_, value)
          if value then
              LibStub("LibDBIcon-1.0"):Show(ADDON_NAME)
          else
              LibStub("LibDBIcon-1.0"):Hide(ADDON_NAME)
          end
          NS.Options.LDB.minimap = value
      end
    },
    spacer1 = {
      name = "",
      type = "description",
      order = 10,
      width = "full"
    },
    EnableBGs = {
      name = " |TInterface/Addons/weizPVP/Media/Icons/battlegrounds.tga:16|t  Enable in Battlegrounds",
      desc = "Enable weizPVP in Battlegrounds\n" ..
          NS.ColorsLUT["info"]:WrapTextInColorCode("(Not designed for BGs, but still can be useful)"),
      type = "toggle",
      order = 11,
      width = "full",
      get = function()
          return NS.Options.Addon.EnabledInBattlegrounds
      end,
      set = function(_, value)
          --: Double check that we were already disabled. If so, initialize addon again.
          NS.Options.Addon.EnabledInBattlegrounds = value
          NS.GetPVPZone()
      end
    },
    EnableArenas = {
      name = " |TInterface/Addons/weizPVP/Media/Icons/arena.tga:16|t  Enable in Arenas",
      desc = "Enable weizPVP in Arenas\n" ..
          NS.ColorsLUT["info"]:WrapTextInColorCode("(Not designed for arenas, but can be useable)"),
      type = "toggle",
      order = 12,
      width = "full",
      get = function()
          return NS.Options.Addon.EnabledInArena
      end,
      set = function(_, value)
          --: Double check that we were already disabled. If so, initialize addon again.
          NS.Options.Addon.EnabledInArena = value
          NS.GetPVPZone()
      end
    },
    spacer2 = {
      name = "",
      type = "description",
      order = 20,
      width = "full"
    },
    DisabledInSanctuary = {
      name = " |TInterface/Addons/weizPVP/Media/Icons/sanctuary.tga:16|t  Disabled when in Sanctuary zones",
      desc = "Disables the addon's main functions while in a Sanctuary zone",
      type = "toggle",
      width = "full",
      order = 30,
      get = function()
          return NS.Options.Addon.DisabledInSanctuary
      end,
      set = function(_, value)
          NS.Options.Addon.DisabledInSanctuary = value
          NS.GetPVPZone()
      end
    },
    spacer3 = {
      name = "",
      type = "description",
      order = 35,
      width = "full"
    },
    DisabledWhenWarmodeOff = {
      name = " |TInterface/Addons/weizPVP/Media/Icons/warmode.tga:16|t  Disable addon when War Mode is turned off",
      desc = "Disables the addon's main functions when you have War Mode off",
      type = "toggle",
      order = 40,
      width = "full",
      get = function()
          return NS.Options.Addon.DisabledWhenWarmodeOff
      end,
      set = function(_, value)
          NS.Options.Addon.DisabledWhenWarmodeOff = value
          NS.GetPVPZone()
      end
    },
    WarModeSpecifics = {
      name = "War Mode Specifics",
      type = "group",
      inline = true,
      order = 50,
      args = {
        -- Disable in Sanctuaries
        DisabledWhenWarmodeOffSanctuaries = {
          name = " Remain disabled in Sanctuaries while WM of off",
          desc = "Disables the addon's main functions when you have War Mode off in Sanctuaries as well as PVP World Zones",
          type = "toggle",
          order = 1,
          width = "full",
          get = function()
              return NS.Options.Addon.DisabledWhenWarmodeOffSanctuaries
          end,
          set = function(_, value)
              NS.Options.Addon.DisabledWhenWarmodeOffSanctuaries = value
              NS.GetPVPZone()
          end,
          disabled = function()
              return not NS.Options.Addon.DisabledWhenWarmodeOff
          end
        }
      }
    }
  }
}

--> MAIN WINDOW GROUP <----------------
---------------------------------------
local numBars = nil
local MainWindowGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/mainWindow.tga:16|t  |cffffffffMain Window|r",
  type = "group",
  order = 10,
  args = {
    introMain = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/mainWindow.tga:20|t  |cffffffffMain Window|r",
      type = "header",
      order = 1,
      width = "full"
    },
    Visible = {
      name = " Show Window",
      desc = "Show the main window",
      type = "toggle",
      order = 2,
      width = "full",
      get = function()
          return NS.Options.Window.Visible
      end,
      set = function(_, value)
          NS.Options.Window.Visible = value
          NS.SetWindowSettings()
      end
    },
    AutoResize = {
      name = " Auto-Resize Window",
      desc = "Auto-Resize the main window based on number of players detected",
      type = "toggle",
      order = 3,
      width = "full",
      get = function()
          return NS.Options.Frames.AutoResize
      end,
      set = function(_, value)
          NS.Options.Frames.AutoResize = value
          if value then
              NS.AutoResize()
          end
      end
    },
    ShowPlayerTooltips = {
      name = "Player Tooltips",
      desc = "Show tooltips when your cursor hovers over a player on the list; given you additional info",
      type = "toggle",
      order = 4,
      width = "full",
      get = function()
          return NS.Options.Frames.PlayerTooltips
      end,
      set = function(_, value)
          NS.Options.Frames.PlayerTooltips = value
      end
    }
  }
}

--> CUSTOMIZE GROUP <------------------
---------------------------------------
local customizeGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/theme.tga:16|t  |cffffffffUI Customization|r",
  type = "group",
  order = 11,
  childGroups = "tab",
  args = {
    intro = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/theme.tga:20|t  |cffffffffUI Customization|r",
      type = "header",
      order = 1,
      width = "full"
    },
    ResetCustomization = {
      type = "execute",
      name = "Reset to default",
      desc = "Revert all customization changes to default settings",
      width = "full",
      order = 30,
      func = function()
          StaticPopup_Show("WEIZPVP_CONFIRM_RESET_CUSTOMIZATIONS")
      end
    },
    --> Scale -13
    ScaleGroup = {
      name = "Scale",
      type = "group",
      order = 13,
      args = {
        ManualScale = {
          name = "Main Window Scale",
          desc = "Manually adjust the scale of the main window",
          type = "range",
          order = 1,
          width = "full",
          min = 0.1,
          max = 8,
          step = 0.01,
          validate = ValidateNumeric,
          get = function()
              return NS.Options.Frames.Scale
          end,
          set = function(_, value)
              NS.Options.Frames.Scale = value
              NS.ScaleMainWindow()
          end
        }
      }
    },
    --> Bars -12
    BarsGroup = {
      name = "Player Bars",
      type = "group",
      order = 12,
      args = {
        BarHeight = {
          name = "Bar Height",
          desc = "Change the bar height of the player bars",
          width = "full",
          type = "range",
          order = 1,
          min = 4,
          max = 96,
          step = 1,
          validate = ValidateNumeric,
          get = function()
              return NS.Options.Bars.RowHeight
          end,
          set = function(_, value)
              NS.Options.Bars.RowHeight = value
              NS.CoreUI.Initialize()
          end
        },
        BarTexture = {
          type = "select",
          name = "Bar Texture",
          desc = "Change the texture of the player bars.",
          values = statusBarTextures,
          width = "full",
          order = 2,
          get = function()
              for i, v in next, statusBarTextures do
                  if v == NS.Options.Bars.Texture then
                      return i
                  end
              end
          end,
          set = function(_, value)
              NS.Options.Bars.Texture = statusBarTextures[value]
              NS.CoreUI.Initialize()
          end,
          itemControl = "DDI-Statusbar"
        },
        --> spacer
        spacer_1 = {
          name = "\n\n",
          type = "description",
          width = "full",
          order = 3
        },
        fontsGroup = {
          name = "Fonts",
          type = "group",
          inline = true,
          order = 10,
          args = {
            PlayerNameFont = {
              type = "select",
              name = "Name Font",
              desc = "Change the font of the player's name on the player bars.",
              values = fonts,
              width = "full",
              order = 10,
              get = function()
                  for i, v in next, fonts do
                      if v == NS.Options.Bars.NameFont then
                          return i
                      end
                  end
              end,
              set = function(_, value)
                  NS.Options.Bars.NameFont = fonts[value]
                  NS.CoreUI.Initialize()
              end,
              itemControl = "DDI-Font"
            },
            PlayerNameFontSize = {
              type = "range",
              name = "Name Font Size",
              desc = "Change the font size of the player's name on the player bars. \n|cff42dcf4(Max size will be limited to the bar height)|r",
              width = "full",
              order = 11,
              min = 4,
              max = 96,
              step = 1,
              validate = ValidateNumeric,
              get = function()
                  return NS.Options.Bars.NameFontSize
              end,
              set = function(_, value)
                  if value > NS.Options.Bars.RowHeight then
                      value = NS.Options.Bars.RowHeight
                  end
                  NS.Options.Bars.NameFontSize = value
                  NS.CoreUI.Initialize()
              end
            },
            PlayerLevelFont = {
              type = "select",
              name = "Level Font",
              desc = "Change the font of the player's level on the player bars.",
              values = fonts,
              width = "full",
              order = 12,
              get = function()
                  for i, v in next, fonts do
                      if v == NS.Options.Bars.LevelFont then
                          return i
                      end
                  end
              end,
              set = function(_, value)
                  NS.Options.Bars.LevelFont = fonts[value]
                  NS.CoreUI.Initialize()
              end,
              itemControl = "DDI-Font"
            },
            PlayerLevelFontSize = {
              type = "range",
              name = "Level Font Size",
              desc = "Change the font size of the player's level on the player bars. \n|cff42dcf4(Max size will be limited to the bar height)|r",
              width = "full",
              order = 13,
              min = 4,
              max = 96,
              step = 1,
              validate = ValidateNumeric,
              get = function()
                  return NS.Options.Bars.LevelFontSize
              end,
              set = function(_, value)
                  if value > NS.Options.Bars.RowHeight then
                      value = NS.Options.Bars.RowHeight
                  end
                  NS.Options.Bars.LevelFontSize = value
                  NS.CoreUI.Initialize()
              end
            },
            PlayerGuildFont = {
              type = "select",
              name = "Guild Font",
              desc = "Change the font of the player's guild on the player bars.",
              values = fonts,
              width = "full",
              order = 14,
              get = function()
                  for i, v in next, fonts do
                      if v == NS.Options.Bars.GuildFont then
                          return i
                      end
                  end
              end,
              set = function(_, value)
                  NS.Options.Bars.GuildFont = fonts[value]
                  NS.CoreUI.Initialize()
              end,
              itemControl = "DDI-Font"
            },
            PlayerGuildFontSize = {
              type = "range",
              name = "Guild Font Size",
              desc = "Change the font size of the player's guild on the player bars. \n|cff42dcf4(Max size will be limited to the bar height)|r",
              width = "full",
              order = 15,
              min = 4,
              max = 96,
              step = 1,
              validate = ValidateNumeric,
              get = function()
                  return NS.Options.Bars.GuildFontSize
              end,
              set = function(_, value)
                  if value > NS.Options.Bars.RowHeight then
                      value = NS.Options.Bars.RowHeight
                  end
                  NS.Options.Bars.GuildFontSize = value
                  NS.CoreUI.Initialize()
              end
            }
          }
        }
      }
    },
    --> Main Window -11
    MainWindow = {
      name = "Main Window",
      type = "group",
      order = 11,
      args = {
        TitleBarHeight = {
          name = "Title Bar Height",
          desc = "Change the height of the title bar.",
          width = "full",
          type = "range",
          order = 1,
          min = 4,
          max = 96,
          step = 1,
          validate = ValidateNumeric,
          get = function()
              return NS.Options.Frames.Header.Height
          end,
          set = function(_, value)
              NS.Options.Frames.Header.Height = value
              NS.CoreUI.Initialize()
          end
        },
        TitleBarBGColor = {
          name = "  Title Bar: Background Color",
          desc = "Change the background color of the title bar",
          width = "full",
          type = "color",
          hasAlpha = true,
          order = 2,
          get = function()
              return NS.Options.Frames.Header.BackgroundColor.r, NS.Options.Frames.Header.BackgroundColor.g, NS.Options.Frames.Header.BackgroundColor.b, NS.Options.Frames.Header.BackgroundColor.a
          end,
          set = function(_, r, g, b, a)
              NS.Options.Frames.Header.BackgroundColor = {
              ["r"] = r,
              ["g"] = g,
              ["b"] = b,
              ["a"] = a
              }
              weizPVP_CoreBar.BG:SetVertexColor(
              NS.Options.Frames.Header.BackgroundColor.r,
                  NS.Options.Frames.Header.BackgroundColor.g,
                  NS.Options.Frames.Header.BackgroundColor.b
              )
              weizPVP_CoreBar.BG:SetAlpha(NS.Options.Frames.Header.BackgroundColor.a)
          end
        },
        MainWindowBGColor = {
          name = "  Window Background Color",
          desc = "Change the background color of the main window; the layer below the player bars.",
          width = "full",
          type = "color",
          hasAlpha = true,
          order = 3,
          get = function()
              return NS.Options.Frames.BackgroundColor.r, NS.Options.Frames.BackgroundColor.g, NS.Options.Frames.BackgroundColor.b, NS.Options.Frames.BackgroundColor.a
          end,
          set = function(_, r, g, b, a)
              NS.Options.Frames.BackgroundColor = {
              ["r"] = r,
              ["g"] = g,
              ["b"] = b,
              ["a"] = a
              }
              weizPVP_CoreFrame.ScrollFrame.BG:SetVertexColor(
              NS.Options.Frames.BackgroundColor.r,
                  NS.Options.Frames.BackgroundColor.g,
                  NS.Options.Frames.BackgroundColor.b
              )
              weizPVP_CoreFrame.ScrollFrame.BG:SetAlpha(NS.Options.Frames.BackgroundColor.a)
          end
        }
      }
    }
  }
}

--> REGIONAL GROUP <-------------------
---------------------------------------
local regionalGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/region.tga:16|t  |cffffffffRegional|r",
  type = "group",
  order = 12,
  args = {
    introMain = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/region.tga:20|t  |cffffffffRegional Settings|r",
      type = "header",
      width = "full",
      order = 1
    },
    ConvertRussianGroup = {
      name = "Convert Fonts: Russian To Roman",
      type = "group",
      inline = true,
      order = 2,
      args = {
        name = {
          name = " Convert Player Names",
          desc = "Convert Russian font characters in player names to Roman",
          type = "toggle",
          order = 1,
          width = "full",
          get = function()
              return NS.Options.Region.ConvertRussianNames
          end,
          set = function(_, value)
              NS.Options.Region.ConvertRussianNames = value
          end
        },
        guild = {
          name = " Convert Guild Names",
          desc = "Convert Russian font characters in guild names to Roman",
          type = "toggle",
          order = 2,
          width = "full",
          get = function()
              return NS.Options.Region.ConvertRussianGuilds
          end,
          set = function(_, value)
              NS.Options.Region.ConvertRussianGuilds = value
          end
        }
      }
    }
  }
}

--> ALERTS GROUP <---------------------------
---------------------------------------
local alertsGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/alert.tga:16|t  |cffffffffAlerts|r",
  type = "group",
  order = 20,
  args = {
    introAlerts = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/alert.tga:20|t  |cffffffffAlerts|r",
      type = "header",
      order = 1,
      width = "full"
    },
    AlertDetectedSection = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/Speaker.tga:16|t  New Player Audio Alert",
      type = "group",
      inline = true,
      order = 1,
      args = {
        AlertDetectedPlayer = {
          name = " Enable",
          desc = "Play a sound when a new player is detected that is not already on the list",
          type = "toggle",
          width = "full",
          order = 1,
          get = function()
              return NS.Options.AudioAlerts.DetectedPlayerSound
          end,
          set = function(_, value)
              NS.Options.AudioAlerts.DetectedPlayerSound = value
          end
        },
        AlertDetectedPlayerSoundFile = {
          type = "select",
          name = " New Player Detected Sound",
          desc = "The sound to play on detection of a new player.",
          values = sounds,
          width = "full",
          order = 2,
          get = function()
              for i, v in next, sounds do
                  if v == NS.Options.AudioAlerts.DetectedPlayerSoundFile then
                      return i
                  end
              end
          end,
          set = function(_, value)
              NS.Options.AudioAlerts.DetectedPlayerSoundFile = sounds[value]
          end,
          itemControl = "DDI-Sound",
          disabled = function()
              return not NS.Options.AudioAlerts.DetectedPlayerSound
          end
        },
        SoundChannel = {
          name = "Sound Channel",
          type = "select",
          order = 3,
          values = {
            ["Master"] = "Master |cff888888:|r " .. tostring(GetSoundChannelVolume("Master")),
            ["SFX"] = "SFX |cff888888:|r " .. tostring(GetSoundChannelVolume("SFX")),
            ["Music"] = "Music |cff888888:|r " .. tostring(GetSoundChannelVolume("Music")),
            ["Ambience"] = "Ambience |cff888888:|r " .. tostring(GetSoundChannelVolume("Ambience")),
            ["Dialog"] = "Dialog |cff888888:|r " .. tostring(GetSoundChannelVolume("Dialog"))
          },
          get = function()
              return NS.Options.AudioAlerts.SoundChannel
          end,
          set = function(_, value)
              NS.Options.AudioAlerts.SoundChannel = value
          end,
          disabled = function()
              return not NS.Options.AudioAlerts.DetectedPlayerSound
          end
        },
        AlertDetectedBGDisabled = {
          name = "Disable while in instanced PVP",
          desc = "Disables the new player audio alert while in instanced PVP.\n" ..
              "|cffcccccc(BGs, Arenas, Brawls, etc.)|r",
          type = "toggle",
          width = "full",
          order = 4,
          get = function()
              return NS.Options.AudioAlerts.DetectedPlayerSoundBGDisabled
          end,
          set = function(_, value)
              NS.Options.AudioAlerts.DetectedPlayerSoundBGDisabled = value
          end,
          disabled = function()
              return not NS.Options.AudioAlerts.DetectedPlayerSound
          end
        },
        AlertDetectedSanctuaryDisabled = {
          name = "Disable in Sanctuary Zones",
          desc = "Disables the new player audio alert while in a Sanctuary zone",
          type = "toggle",
          width = "full",
          order = 5,
          get = function()
              return NS.Options.AudioAlerts.DisableInSanctuary
          end,
          set = function(_, value)
              NS.Options.AudioAlerts.DisableInSanctuary = value
          end,
          disabled = function()
              return not NS.Options.AudioAlerts.DetectedPlayerSound
          end
        }
      }
    },
    --> Stealth
    stealthSection = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/stealth.tga:16|t  Stealth Alerts",
      type = "group",
      inline = true,
      order = 2,
      args = {
        sound = {
          name = "|TInterface/Addons/weizPVP/Media/Icons/Speaker.tga:16|t  Audio Alert",
          type = "group",
          inline = true,
          order = 1,
          args = {
            StealthAlertSoundEnabled = {
              name = " Enable",
              desc = "Play a sound when a unit is detected using a stealth-like ability.",
              type = "toggle",
              width = "full",
              order = 4,
              get = function()
                  return NS.Options.StealthAlert.EnableSound
              end,
              set = function(_, value)
                  NS.Options.StealthAlert.EnableSound = value
              end
            },
            StealthAlertSoundFile = {
              type = "select",
              name = " Stealth Audio Alert",
              desc = "The sound to play on stealth detection, if enabled.",
              values = sounds,
              width = "full",
              order = 5,
              get = function()
                  for i, v in next, sounds do
                      if v == NS.Options.StealthAlert.SoundFile then
                          return i
                      end
                  end
              end,
              set = function(_, value)
                  NS.Options.StealthAlert.SoundFile = sounds[value]
              end,
              itemControl = "DDI-Sound",
              disabled = function()
                  return not NS.Options.StealthAlert.EnableSound
              end
            },
            SoundChannel = {
              name = "Sound Channel",
              type = "select",
              order = 6,
              values = {
                ["Master"] = "Master |cff888888:|r " .. tostring(GetSoundChannelVolume("Master")),
                ["SFX"] = "SFX |cff888888:|r " .. tostring(GetSoundChannelVolume("SFX")),
                ["Music"] = "Music |cff888888:|r " .. tostring(GetSoundChannelVolume("Music")),
                ["Ambience"] = "Ambience |cff888888:|r " .. tostring(GetSoundChannelVolume("Ambience")),
                ["Dialog"] = "Dialog |cff888888:|r " .. tostring(GetSoundChannelVolume("Dialog"))
              },
              get = function()
                  return NS.Options.StealthAlert.SoundChannel
              end,
              set = function(_, value)
                  NS.Options.StealthAlert.SoundChannel = value
              end,
              disabled = function()
                  return not NS.Options.StealthAlert.EnableSound
              end
            },
            DisableSoundInBG = {
              type = "toggle",
              name = "Disable Audio alert while in instanced PVP",
              desc = "If enabled, the stealth audio alerts will be muted while in instances such as BGs, Arenas, Brawls, etc.",
              width = "full",
              order = 7,
              get = function()
                  return NS.Options.StealthAlert.DisableSoundInBG
              end,
              set = function(_, value)
                  NS.Options.StealthAlert.DisableSoundInBG = value
              end,
              disabled = function()
                  return not NS.Options.StealthAlert.EnableSound
              end
            },
            DisableSoundInSanctuary = {
              name = "Disable Audio Alert in Sanctuary Zones",
              desc = "Disable the stealth alert sound while in Sanctuary (non-combat) zones",
              type = "toggle",
              width = "full",
              order = 8,
              get = function()
                  return NS.Options.StealthAlert.DisableSoundInSanctuary
              end,
              set = function(_, value)
                  NS.Options.StealthAlert.DisableSoundInSanctuary = value
              end,
              disabled = function()
                  return not NS.Options.StealthAlert.EnableSound
              end
            }
          }
        },
        popup = {
          name = "|TInterface/Addons/weizPVP/Media/Icons/popup.tga:16|t  Pop Up Alert",
          type = "group",
          inline = true,
          order = 2,
          args = {
            StealthAlertEnabled = {
              name = " Enable",
              desc = "Show an alert when a unit is detected using a stealth-like ability.",
              type = "toggle",
              width = "full",
              order = 1,
              get = function()
                  return NS.Options.StealthAlert.Enabled
              end,
              set = function(_, value)
                  NS.Options.StealthAlert.Enabled = value
              end
            },
            DisableVisualStealthAlertsInSanctuary = {
              name = " Disable while in a Sanctuary zone",
              desc = "Disable alert pop-up while in a Sanctuary.",
              type = "toggle",
              width = "full",
              order = 2,
              get = function()
                  return NS.Options.StealthAlert.DisableVisualStealthAlertsInSanctuary
              end,
              set = function(_, value)
                  NS.Options.StealthAlert.DisableVisualStealthAlertsInSanctuary = value
              end,
              disabled = function()
                  return not NS.Options.StealthAlert.Enabled
              end
            }
          }
        },
        StealthChatAlerts = {
          name = "|TInterface/Addons/weizPVP/Media/Icons/chat.tga:16|t Post Stealth Alerts in chat",
          desc = "Show a chat alert when a unit is detected using a stealth-like ability.",
          type = "toggle",
          width = "full",
          order = 3,
          get = function()
              return NS.Options.StealthAlert.ChatAlert
          end,
          set = function(_, value)
              NS.Options.StealthAlert.ChatAlert = value
          end
        }
      }
    }
  }
}

--> DATABASE GROUP <-------------------
---------------------------------------

local dbCleanTimesTable = {
  [30] = "1 Month" .. " |cff00f7ff(30 Days)|r",
  [60] = "2 Months " .. " |cff00f7ff(60 Days)|r",
  [90] = "3 Months " .. " |cff00f7ff(90 Days)|r",
  [180] = "6 Months " .. " |cff00f7ff(180 Days)|r"
}

local databaseGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/database.tga:16|t  |cffffffffDatabase|r",
  type = "group",
  order = 30,
  args = {
    intro = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/database.tga:20|t  |cffffffffDatabase|r",
      type = "header",
      order = 1,
      width = "full"
    },
    --> Maintenance
    maintenanceGroup = {
      name = "Maintenance",
      type = "group",
      inline = true,
      order = 2,
      args = {
        maintenance = {
          name = "Remove players from the database that have not been seen for:",
          desc = "Removes older players who have not been detected in the given amount of time.\n" ..
              "|cffbbbbbb(Runs no more than once every 24 hours on login)|r",
          type = "select",
          values = dbCleanTimesTable,
          width = "full",
          order = 1,
          get = function()
              return NS.Options.Database.CleanTime
          end,
          set = function(_, value)
              NS.Options.Database.CleanTime = value
          end
        },
        applyNow = {
          name = "Manually run maintenance now!",
          type = "execute",
          width = "full",
          order = 2,
          func = function()
              weizPVP:OnDisable()
              NS.ClearListData()
              NS.CleanDB_SpecificDays(NS.Options.Database.CleanTime)
              NS.Options.Database.LastCleaned = time()
              weizPVP:OnEnable()
              NS.GetPVPZone()
              NS.PrintAddonMessage("Database maintenance completed!")
              collectgarbage()
              C_Timer_After(2, function() collectgarbage() end)
          end
        },
        stats = {
          name = function()
              local guilds = {}
              local numGuilds = 0
              local timeAgo = time() - NS.Options.Database.LastCleaned
              if timeAgo < 1 then
                  timeAgo = 1
              end
              local lastUpdated = SecondsToTime(timeAgo)
              local statsText
              local numPlayers = 0
              for _, k in pairs(NS.PlayerDB) do
                  if k.G and not guilds[k.G] then
                      guilds[k.G] = true
                      numGuilds = numGuilds + 1
                  end
                  numPlayers = numPlayers + 1
              end

              statsText = "\n" .. "Last maintenance:  " .. NS.ColorsLUT["lightBlue"]:WrapTextInColorCode(lastUpdated) .. " ago"
              return statsText
          end,
          type = "description",
          width = "full",
          fontSize = "medium",
          order = 3
        }
      }
    },
    statsGroup = {
      name = "Stats",
      type = "group",
      inline = true,
      order = 3,
      args = {
        stats = {
          name = function()
              local guilds = {}
              local numGuilds = 0
              local statsText
              local numPlayers = 0
              for _, k in pairs(NS.PlayerDB) do
                  if k.G and not guilds[k.G] then
                      guilds[k.G] = true
                      numGuilds = numGuilds + 1
                  end
                  numPlayers = numPlayers + 1
              end

              statsText = NS.ColorsLUT["info"]:WrapTextInColorCode("Number of Players :   ") ..
                  BreakUpLargeNumbers(numPlayers) ..
                  "\n" ..
                  NS.ColorsLUT["green"]:WrapTextInColorCode("Number of Guilds :   ") .. BreakUpLargeNumbers(numGuilds)
              statsText = statsText .. "\n"
              return statsText
          end,
          type = "description",
          width = "full",
          fontSize = "medium",
          order = 1
        }
      }
    }
  }
}

--> CROSSHAIR GROUP <------------------
---------------------------------------
local crosshairTips =
NS.ColorsLUT["info"]:WrapTextInColorCode(
"Enemy Player Nameplates must be Enabled in order for the Crosshair to be displayed!"
)
local crosshairGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/crosshair.tga:16|t  |cffffffffCrosshair|r",
  type = "group",
  order = 40,
  args = {
    intro = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/crosshair.tga:20|t  |cffffffffCrosshair|r",
      type = "header",
      order = 1,
      width = "full"
    },
    --> tips
    tips = {
      name = " \n |TInterface/Addons/weizPVP/Media/Icons/warning.tga:0|t  " .. crosshairTips .. "  \n\n",
      fontSize = "small",
      type = "description",
      width = "full",
      order = 2
    },
    --> Options
    Enabled = {
      name = " Enable Crosshair",
      desc = "Toggles the Crosshair on/off",
      type = "toggle",
      width = "full",
      order = 2,
      get = function()
          return NS.Options.Crosshair.Enabled
      end,
      set = function(_, value)
          if value then
              NS.Options.Crosshair.Enabled = true
              NS.Crosshair.Enable()
          else
              NS.Options.Crosshair.Enabled = false
              NS.Crosshair.Disable()
          end
      end
    },
    FriendlyCrosshairs = {
      name = " Enable Friendly Crosshairs",
      desc = "Toggles the Crosshair on/off for friendly (Requires Friendly Nameplates Enabled.)",
      type = "toggle",
      width = "full",
      order = 3,
      get = function()
          return NS.Options.Crosshair.FriendlyCrosshairs
      end,
      set = function(_, value)
          if value then
              NS.Options.Crosshair.FriendlyCrosshairs = true
          else
              NS.Options.Crosshair.FriendlyCrosshairs = false
          end
      end
    },
    ShowRange = {
      name = " Enable Range Text",
      desc = "Show the estimated range of the target while the crosshair is active. Text fades away under 30 yards.",
      type = "toggle",
      width = "full",
      order = 10,
      get = function()
          return NS.Options.Crosshair.ShowRange
      end,
      set = function(_, value)
          if value then
              NS.Options.Crosshair.ShowRange = true
              _G.weizPVP_CrosshairFrame.RangeText:Show()
              NS.Crosshair.Enable()
          else
              NS.Options.Crosshair.ShowRange = false
              _G.weizPVP_CrosshairFrame.RangeText:Hide()
              NS.Crosshair.Enable()
          end
      end,
      disabled = function()
          return not NS.Options.Crosshair.Enabled
      end
    },
    --> GUILD AND NAME TEXT
    NameEnabled = {
      name = " Enable Name Text",
      desc = "Shows the the target's name being shown on the Crosshair.",
      type = "toggle",
      width = "full",
      order = 11,
      get = function()
          return NS.Options.Crosshair.NameEnabled
      end,
      set = function(_, value)
          NS.Options.Crosshair.NameEnabled = value
          NS.Crosshair.Reset()
          NS.Crosshair.NewTarget()
      end,
      disabled = function()
          return not NS.Options.Crosshair.Enabled
      end
    },
    GuildEnabled = {
      name = " Enable Guild Text",
      desc = "Shows the the target's guild being shown on the Crosshair.",
      type = "toggle",
      width = "full",
      order = 12,
      get = function()
          return NS.Options.Crosshair.GuildEnabled
      end,
      set = function(_, value)
          NS.Options.Crosshair.GuildEnabled = value
          NS.Crosshair.Reset()
          NS.Crosshair.NewTarget()
      end,
      disabled = function()
          return not NS.Options.Crosshair.Enabled
      end
    },
    Customize = {
      name = "Customize",
      type = "group",
      inline = true,
      order = 14,
      args = {
        Alpha = {
          name = " Alpha Multiplier",
          desc = "Adjust Crosshair Alpha. 0 = transparent, 1.0 = max opacity/visibility",
          type = "range",
          min = 0,
          max = 1,
          width = "full",
          validate = ValidateNumeric,
          step = 0.05,
          order = 20,
          get = function()
              if type(NS.Options.Crosshair.Alpha) == "number" then
                  return NS.Options.Crosshair.Alpha
              else
                  return 1
              end
          end,
          set = function(_, value)
              if type(NS.Options.Crosshair.Alpha) == "number" then
                  NS.Options.Crosshair.Alpha = value
                  NS.Crosshair.SetAlpha()
              else
                  NS.Options.Crosshair.Alpha = 1
                  NS.Crosshair.SetAlpha()
              end
          end,
          disabled = function()
              return not NS.Options.Crosshair.Enabled
          end
        },
        Scale = {
          name = " Scale",
          desc = "Adjust the Scale of the Crosshair",
          type = "range",
          min = 0.1,
          max = 4,
          width = "full",
          validate = ValidateNumeric,
          step = 0.1,
          order = 21,
          get = function()
              if type(NS.Options.Crosshair.Scale) == "number" then
                  return NS.Options.Crosshair.Scale
              else
                  return 1
              end
          end,
          set = function(_, value)
              if type(NS.Options.Crosshair.Scale) == "number" then
                  NS.Options.Crosshair.Scale = value
                  NS.Crosshair.SetScale(value)
              else
                  NS.Options.Crosshair.Scale = 1
                  NS.Crosshair.SetScale(1)
              end
          end,
          disabled = function()
              return not NS.Options.Crosshair.Enabled
          end
        },
        LineThickness = {
          name = " Line Thickness",
          desc = "Change the thickness of the lines",
          type = "range",
          min = 1,
          max = 12,
          width = "full",
          step = 1,
          order = 22,
          get = function()
              return NS.Options.Crosshair.LineThickness
          end,
          set = function(_, value)
              NS.Options.Crosshair.LineThickness = value
              NS.Crosshair.SetLineThickness(value)
          end,
          disabled = function()
              return not NS.Options.Crosshair.Enabled
          end
        },
        LineAlpha = {
          name = " Line Alpha",
          desc = "Change the alpha value of the lines",
          type = "range",
          min = 0,
          max = 1,
          width = "full",
          step = 0.01,
          order = 23,
          get = function()
              return NS.Options.Crosshair.LineAlpha
          end,
          set = function(_, value)
              NS.Options.Crosshair.LineAlpha = value
              NS.Crosshair.SetAlpha()
          end,
          disabled = function()
              return not NS.Options.Crosshair.Enabled
          end
        }
      }
    },
    --> CVars header
    CVars = {
      name = "Nameplate CVars",
      type = "group",
      inline = true,
      order = 20,
      args = {
        clampTargetNameplateToScreen = {
          type = "toggle",
          name = "|cff42dcf4clampTargetNameplateToScreen|r (|cff37ff37Enabled is recommended|r)",
          desc = "Keep the nameplate of your target on screen, even when the character is offscreen (behind you, etc)",
          width = "full",
          order = 1,
          get = function()
              return C_CVar_GetCVar("clampTargetNameplateToScreen") == "1" and true or false
          end,
          set = function(_, value)
              if value then
                  SetCVar("clampTargetNameplateToScreen", "1")
              else
                  SetCVar("clampTargetNameplateToScreen", "0")
              end
          end
        },
        nameplateTargetRadialPosition = {
          type = "toggle",
          name = "|cff42dcf4nameplateTargetRadialPosition|r (|cff37ff37Enabled is recommended|r)",
          desc = "When target is off screen, position its nameplate radially around sides and bottom",
          width = "full",
          order = 2,
          get = function()
              return C_CVar_GetCVar("nameplateTargetRadialPosition") == "1" and true or false
          end,
          set = function(_, value)
              if value then
                  SetCVar("nameplateTargetRadialPosition", "1")
              else
                  SetCVar("nameplateTargetRadialPosition", "0")
              end
          end
        },
        nameplateTargetBehindMaxDistance = {
          type = "range",
          name = "|cff42dcf4nameplateTargetBehindMaxDistance|r |cffffffff(|r|cff37ff3760 is recommended|r|cffffffff)|r",
          desc = "The max distance to show the target nameplate when the target is behind the camera.",
          width = "full",
          min = 15,
          max = 60,
          validate = ValidateNumeric,
          step = 1,
          order = 3,
          get = function()
              return tonumber(C_CVar_GetCVar("nameplateTargetBehindMaxDistance"))
          end,
          set = function(_, value)
              SetCVar("nameplateTargetBehindMaxDistance", tostring(value))
          end
        },
        NamePlateHorizontalScale = {
          type = "range",
          name = "|cff42dcf4NamePlateHorizontalScale|r |cffffffff(|r|cff37ff371 is default. Requires UI reload|r|cffffffff)|r",
          desc = "The Crosshair size is based off the size of the nameplate, where width is the determining factor. Decreasing the width from the very large default can result in much better looking/fitting Crosshair.",
          width = "full",
          min = 0.1,
          max = 2,
          validate = ValidateNumeric,
          step = 0.1,
          order = 4,
          get = function()
              return tonumber(C_CVar_GetCVar("NamePlateHorizontalScale"))
          end,
          set = function(_, value)
              SetCVar("NamePlateHorizontalScale", tostring(value))
          end
        },
        ResetCVars = {
          type = "execute",
          name = "Reset the above CVars to default values",
          desc = "The CVars nameplateTargetRadialPosition, nameplateTargetBehindMaxDistance, and nameplateMaxDistance will be reset to default",
          width = "full",
          order = 5,
          func = function()
              SetCVar("nameplateTargetRadialPosition", GetCVarDefault("nameplateTargetRadialPosition"))
              SetCVar("nameplateTargetBehindMaxDistance", GetCVarDefault("nameplateTargetBehindMaxDistance"))
              SetCVar("NamePlateHorizontalScale", GetCVarDefault("NamePlateHorizontalScale"))
              NS.PrintAddonMessage("|cff27e817CVars reset|r :")
          end
        }
      }
    }
  }
}

--> KOS GROUP <------------------------
---------------------------------------
local kosHelpText =
[[
  |cff00ff75To add or remove a player from the main window|r:
      |cff42dcf4Right-Click|r the player's bar

  |cff00ff75To add or remove a player from a unit frame (such as target or focus)|r:
      |cff42dcf4Right-Click|r the unit frame |cffbbbbbb(such as target, focus, etc)|r

  ]]
local kosGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/kos.tga:16|t  |cffffffffKill On Sight|r",
  type = "group",
  order = 50,
  args = {
    introKOS = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/kos.tga:20|t  |cffffffffKill On Sight|r",
      type = "header",
      order = 1,
      width = "full"
    },
    sound = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/speaker.tga:16|t Alert Sound",
      type = "group",
      inline = true,
      order = 2,
      args = {
        AudioAlert = {
          name = " Enable",
          desc = "Play's a sound when a player on the KOS list has been found.",
          type = "toggle",
          width = "full",
          order = 2,
          get = function()
              return NS.Options.KOS.AudioAlert
          end,
          set = function(_, value)
              NS.Options.KOS.AudioAlert = value
          end
        },
        AudioAlertFile = {
          type = "select",
          name = " Detection Sound",
          desc = "The sound that plays when a player on the KOS list is detected.",
          values = sounds,
          width = "full",
          order = 3,
          get = function()
              for i, v in next, sounds do
                  if v == NS.Options.KOS.AudioAlertFile then
                      return i
                  end
              end
          end,
          set = function(_, value)
              NS.Options.KOS.AudioAlertFile = sounds[value]
          end,
          itemControl = "DDI-Sound",
          disabled = function()
              return not NS.Options.KOS.AudioAlert
          end
        },
        SoundChannel = {
          name = "Sound Channel",
          type = "select",
          order = 4,
          values = {
            ["Master"] = "Master |cff888888:|r " .. tostring(GetSoundChannelVolume("Master")),
            ["SFX"] = "SFX |cff888888:|r " .. tostring(GetSoundChannelVolume("SFX")),
            ["Music"] = "Music |cff888888:|r " .. tostring(GetSoundChannelVolume("Music")),
            ["Ambience"] = "Ambience |cff888888:|r " .. tostring(GetSoundChannelVolume("Ambience")),
            ["Dialog"] = "Dialog |cff888888:|r " .. tostring(GetSoundChannelVolume("Dialog"))
          },
          get = function()
              return NS.Options.KOS.SoundChannel
          end,
          set = function(_, value)
              NS.Options.KOS.SoundChannel = value
          end,
          disabled = function()
              return not NS.Options.KOS.AudioAlert
          end
        }
      }
    },
    ChatOutput = {
      type = "toggle",
      name = "|TInterface/Addons/weizPVP/Media/Icons/chat.tga:16|t Chat alert",
      desc = "Outputs a message to your chat frame when a player from the KOS list is first found (only you will see this)",
      width = "full",
      order = 5,
      get = function()
          return NS.Options.KOS.ChatAlert
      end,
      set = function(_, value)
          NS.Options.KOS.ChatAlert = value
      end
    },
    TaskbarAlert = {
      type = "toggle",
      name = "|TInterface/Addons/weizPVP/Media/Icons/flash.tga:16|t  Flash the taskbar icon on KOS detect",
      desc = "Flashes the WoW application icon on your taskbar/dock when a KOS target is detected. Useful for when WoW is minimized, using multiple monitors, etc.",
      width = "full",
      order = 6,
      get = function()
          return NS.Options.KOS.TaskbarAlert
      end,
      set = function(_, value)
          NS.Options.KOS.TaskbarAlert = value
      end
    },
    helpHeader = {
      name = " \n |TInterface/Addons/weizPVP/Media/Icons/help.tga:0|t |cfffdffd7 Adding and Removing players:|r",
      type = "description",
      fontSize = "large",
      width = "full",
      order = 7
    },
    help = {
      type = "description",
      name = kosHelpText,
      width = "full",
      order = 8
    }
  }
}

--> HELP GROUP <-----------------------
---------------------------------------
local commandsText =
[[
  |cffbbbbbb(Commands can be executed with either|r |cff42dcf4/wpvp|r|cffbbbbbb or|r |cff42dcf4/weizpvp|r|cffbbbbbb)|r

  |cff00ff75Show Window|r:  |cff42dcf4/wpvp show|r
  |cff00ff75Hide Window|r:  |cff42dcf4/wpvp hide|r
  |cff00ff75Toggle Lock Window|r:  |cff42dcf4/wpvp lock|r
  |cff00ff75Toggle Pin Window|r:  |cff42dcf4/wpvp pin|r

  |cffff0000RESET COMMANDS|r |cffbbbbbb(in case you're having issues)|r
    |cffff0000Reset all options and player data|r:  |cff42dcf4/wpvp resetall|r
    |cffff0000Reset all saved player data|r:  |cff42dcf4/wpvp resetall|r
    |cffff0000Reset options|r:  |cff42dcf4/wpvp resetoptions|r
  ]]

local interfaceTipsText =
[[
  |cff00ff75Toggle Options|r -  |cff42dcf4Right-Click|r  the minimap icon
  |cff00ff75Show/Hide Window|r -  |cff42dcf4Left-Click|r the minimap icon
  |cff00ff75Pin/Unpin the Window|r -  |cff42dcf4Right-Click|r title/header bar of the main window
  |cff00ff75Lock/Unlock the Window|r -  |cff42dcf4Ctrl+Right-Click|r title/header bar of the main window
  ]]
local bindingsTips = [[
    Find key bindings in the 'AddOns' section in the key bindings options.
    ]]
local helpGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/help.tga:16|t  |cffffffffHelp|r",
  type = "group",
  order = 60,
  args = {
    intro = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/help.tga:20|t  |cffffffffHelp|r",
      type = "header",
      order = 1,
      width = "full"
    },
    --> commands
    commandsHeader = {
      name = "|cffffa012Commands|r",
      type = "description",
      fontSize = "large",
      width = "full",
      order = 2
    },
    commands = {
      type = "description",
      fontSize = "medium",
      name = commandsText,
      width = "full",
      order = 3
    },
    --> interface
    interfaceHeader = {
      name = "\n|cffffa012Interface|r",
      type = "description",
      fontSize = "large",
      width = "full",
      order = 4
    },
    interfaceTips = {
      type = "description",
      fontSize = "medium",
      name = interfaceTipsText,
      width = "full",
      order = 5
    },
    --> kos
    kosHeader = {
      name = "\n|cffffa012Kill On Sight|r",
      type = "description",
      fontSize = "large",
      width = "full",
      order = 6
    },
    kosHelp = {
      type = "description",
      fontSize = "medium",
      name = kosHelpText,
      width = "full",
      order = 7
    },
    --> bindings
    bindingsHeader = {
      name = "\n |TInterface/Addons/weizPVP/Media/Icons/bindings.tga:0|t |cffffa012Key Bindings|r",
      type = "description",
      fontSize = "large",
      width = "full",
      order = 8
    },
    bindingsHelp = {
      type = "description",
      fontSize = "medium",
      name = bindingsTips,
      width = "full",
      order = 9
    }
  }
}

--> SEPARATOR <------------------------
---------------------------------------
local separatorGroup1 = {
  name = "",
  desc = "",
  type = "group",
  disabled = true,
  order = 100,
  args = {}
}

--> LAB GROUP <------------------------
---------------------------------------
local labGroup = {
  name = "|TInterface/Addons/weizPVP/Media/Icons/lab.tga:16|t  |cffffffffDev Lab|r",
  desc = NS.ColorsLUT["info"]:WrapTextInColorCode("(Experimental)"),
  type = "group",
  order = 110,
  args = {
    intro = {
      name = "|TInterface/Addons/weizPVP/Media/Icons/lab.tga:20|t  |cffffffffDev Lab|r  " ..
          NS.ColorsLUT["info"]:WrapTextInColorCode("(Experimental)"),
      type = "header",
      order = 1,
      width = "full"
    },
    intro2 = {
      type = "description",
      fontSize = "small",
      name = "\nThe options in this section are for those wanting to test new features out that are still being developed. There may be bugs, and if so; please report them!\n\n" ..
          NS.ColorsLUT["yellow"]:WrapTextInColorCode(
          "If you have any ideas for new features, create a feature request 'issue' on the weizPVP Curseforge project page!"
          ) ..
          "\n\n",
      width = "full",
      order = 2
    },
    --> DynamicProcessing
    DynamicProcessingModeGroup = {
      name = NS.ColorsLUT["info"]:WrapTextInColorCode("Dynamic Processing"),
      type = "group",
      inline = true,
      order = 10,
      args = {
        tips = {
          type = "description",
          fontSize = "small",
          name = "The Dynamic Processing option will change the way weizPVP detects players based on a few different factors.\n" ..
              "This option aims to reduce processing by selectively turning different detection methods on or off.\n\n",
          width = "full",
          order = 1
        },
        DynamicProcessing = {
          name = "Enable Dynamic Processing",
          type = "toggle",
          width = "full",
          order = 10,
          get = function()
              return NS.Options.Lab.DynamicProcessing
          end,
          set = function(_, value)
              NS.Options.Lab.DynamicProcessing = value
          end
        }
      }
    },
    SortingGroup = {
      name = NS.ColorsLUT["info"]:WrapTextInColorCode("Sorting and Timing"),
      type = "group",
      inline = true,
      order = 20,
      args = {
        ActiveTimeout = {
          name = "Active Timeout (seconds)",
          desc = "The amount time in seconds when a player stays on the 'active' list since last seen \n" ..
              NS.ColorsLUT["info"]:WrapTextInColorCode("(Default = 20)") ..
              "\n|cffff00bbActive Timeout must be less than Inactive timeout!|r",
          type = "range",
          order = 1,
          width = "full",
          min = 5,
          max = 60,
          step = 1,
          get = function()
              return NS.Options.Sorting.NearbyActiveTimeout
          end,
          set = function(_, value)
              if value < NS.Options.Sorting.NearbyInactiveTimeout then
                  NS.Options.Sorting.NearbyActiveTimeout = value
              end
          end
        },
        InactiveTimeout = {
          name = "Inactive Timeout (seconds)",
          desc = "The amount total time the player will remain on the list since last seen\n" ..
              NS.ColorsLUT["info"]:WrapTextInColorCode("(Default = 32)") ..
              "\n|cffff00bbActive Timeout must be less than Inactive timeout!|r",
          type = "range",
          order = 1,
          width = "full",
          min = 10,
          max = 60,
          step = 1,
          get = function()
              return NS.Options.Sorting.NearbyInactiveTimeout
          end,
          set = function(_, value)
              if NS.Options.Sorting.NearbyActiveTimeout < value then
                  NS.Options.Sorting.NearbyInactiveTimeout = value
              end
          end
        }
      }
    },
    BarGroup = {
      name = NS.ColorsLUT["info"]:WrapTextInColorCode("Number of Player Bars"),
      type = "group",
      inline = true,
      order = 30,
      args = {
        maxNumberBars = {
          name = " Max Number of Bars to show",
          desc = "Change the maximum number of player bars that are shown\n" ..
              NS.ColorsLUT["info"]:WrapTextInColorCode("(Default = 80)"),
          type = "range",
          order = 1,
          width = "full",
          min = 4,
          max = 80,
          step = 1,
          get = function()
              if not numBars then
                  numBars = NS.Options.Bars.MaxNumBars
              end
              return numBars
          end,
          set = function(_, value)
              numBars = value
          end
        },
        Apply = {
          name = " Apply and Refresh",
          desc = "|cffbbbbbbRequired for saving the bar settings\n Clears player list|r",
          type = "execute",
          order = 2,
          width = "full",
          func = function()
              NS.Options.Bars.MaxNumBars = numBars
              NS.CoreUI.Initialize()
              weizPVP_ClearListData()
              collectgarbage()
          end
        }
      }
    }
  }
}

--> Create Options Table <-------------------------------------------
function NS.CreateInterfaceOptions()
    local OptionsTable = {
    name = " " ..
        "|TInterface/Addons/weizPVP/Media/weizpvp_nobg_offset_high.tga:24|t" ..
        "  " .. NS.Constants.AddonString .. " |cffbbbbbb - |r|cffcafdff " .. _G.weizPVP.Addon_Version .. "|r",
    type = "group",
    args = {
      generalGroup = generalGroup,
      MainWindowGroup = MainWindowGroup,
      customizeGroup = customizeGroup,
      regionalGroup = regionalGroup,
      alertsGroup = alertsGroup,
      databaseGroup = databaseGroup,
      crosshairGroup = crosshairGroup,
      kosGroup = kosGroup,
      separatorGroup1 = separatorGroup1,
      labGroup = labGroup,
      helpGroup = helpGroup
    }
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable(ADDON_NAME, OptionsTable)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME, ADDON_NAME)
end

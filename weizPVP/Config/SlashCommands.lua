--|> SLASH COMMANDS
---------------------------------------------------------------------------------------------------
local ADDON_NAME, NS = ...

-- ⬆️ Upvalues
-----------------------------------------------------------
local print = print

-- : SLASH COMMANDS TABLE
-----------------------------------------------------------
NS.SlashCommands = {
  name = "Slash Commands",
  order = -3,
  type = "group",
  args = {
    intro = {
      name = "weizPVP Slash Commands",
      type = "description",
      order = 1,
      cmdHidden = true
    },
    -- Config
    config = {
      name = "config",
      desc = "Opens the configuration menu.",
      type = "execute",
      func = function()
          NS.ToggleOptions()
      end,
      guiHidden = true,
      order = 2
    },
    -- Show
    show = {
      name = "Show",
      desc = "Show the weizPVP window.",
      type = "execute",
      order = 3,
      func = function()
          NS.Options.Window.Visible = true
          NS.SetWindowSettings()
      end,
      dialogHidden = true
    },
    -- Hide
    hide = {
      name = "Hide",
      desc = "Hide the weizPVP window.",
      type = "execute",
      order = 4,
      func = function()
          NS.Options.Window.Visible = false
          NS.SetWindowSettings()
      end,
      dialogHidden = true
    },
    -- Lock
    lock = {
      name = "Lock",
      desc = "Toggle locking of the window's position and size.",
      type = "execute",
      order = 5,
      func = function()
          NS.CoreUI.ToggleLock()
      end,
      dialogHidden = true
    },
    -- Pin
    pin = {
      name = "Pin",
      desc = "Toggle pinning of the window.",
      type = "execute",
      order = 6,
      func = function()
          if NS.Options.Window.Locked then
              NS.PrintAddonMessage(
              "Window is currently |cffff3838LOCKED|r. Window can only be pinned after being unlocked."
              )
          else
              NS.CoreUI.TogglePin()
          end
      end,
      dialogHidden = true
    },
    -- Crosshairs
    ch = {
      name = "Crosshair",
      desc = "Toggles the Crosshair on or off",
      type = "execute",
      order = 7,
      func = function()
          if not NS.Options.Crosshair.Enabled then
              NS.Options.Crosshair.Enabled = true
              NS.Crosshair.Enable()
              NS.PrintAddonMessage("Crosshair is |cff37ff37ENABLED|r.")
          else
              NS.Options.Crosshair.Enabled = false
              NS.Crosshair.Disable()
              NS.PrintAddonMessage("Crosshair is |cffff3838DISABLED|r.")
          end
      end,
      dialogHidden = true
    },
    -- Enable
    enable = {
      name = "Enable",
      desc = "Enable the weizPVP addon",
      type = "execute",
      order = 10,
      func = function()
          if weizPVP.ENABLED then
              NS.PrintAddonMessage("weizPVP is already enabled!")
              return
          end
          weizPVP:OnEnable()
          NS.WarModeChanged()
          NS.PrintAddonMessage("Addon Enabled!")
      end,
      dialogHidden = true
    },
    -- Disable
    disable = {
      name = "Disable",
      desc = "Disable the weizPVP addon",
      type = "execute",
      order = 11,
      func = function()
          if not weizPVP.ENABLED then
              NS.PrintAddonMessage("weizPVP is already disabled!")
              return
          end
          weizPVP:OnDisable()
          NS.PrintAddonMessage("Addon Disabled!")
      end,
      dialogHidden = true
    },
    --!! RESETALL: RESETS EVERYTHING TO DEFAULT
    resetall = {
      cmdHidden = true,
      name = "Reset All",
      desc = "Resets all settings and wipes player data",
      type = "execute",
      order = 61,
      func = function()
          NS.ResetAll()
      end
    },
    --!! RESET OPTIONS
    resetoptions = {
      cmdHidden = true,
      name = "Reset Options",
      desc = "Resets all Options but doesn't change player data at all",
      type = "execute",
      order = 63,
      func = function()
          NS.ResetOptions()
      end
    },
    --!! RESET PLAYER DB
    resetPlayers = {
      cmdHidden = true,
      name = "Reset Player DB",
      desc = "Wipes the player database. Options remain untouched.",
      type = "execute",
      order = 64,
      func = function()
          NS.ResetPlayerDB()
      end
    },
    --!! RESET PLAYER DB
    debug = {
      cmdHidden = true,
      name = "debug",
      desc = "toggle debug",
      type = "execute",
      order = 99,
      func = function()
          -- NS.DebugToggle()
          print("DEBUG DISABLED")
      end
    }
  }
}

-- ✅ Register Command
LibStub("AceConfig-3.0"):RegisterOptionsTable(ADDON_NAME .. " Commands", NS.SlashCommands, { "wpvp", "weizpvp" })

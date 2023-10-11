---------------------------------------------------------------------------------------------------
--|> Defaults
---------------------------------------------------------------------------------------------------
local _, NS = ...

NS._DefaultOptions = {}

--: Create Default Options
---------------------------------------
local Options = {}

--: Addon
---------------------------------------
Options.Addon = {
  Enabled = true,
  EnabledInBattlegrounds = true,
  EnabledInArena = false,
  DisabledWhenWarmodeOff = false,
  DisabledWhenWarmodeOffSanctuaries = true,
  DisabledInSanctuary = false,
  Debug = false
}

--: Region
---------------------------------------
Options.Region = {
  ConvertRussianNames = true,
  ConvertRussianGuilds = true
}

--: Lab
---------------------------------------
Options.Lab = {
  DynamicProcessing = false
}

--: Database
---------------------------------------
Options.Database = {
  CleanTime = 30,
  LastCleaned = 0
}

--: Window
---------------------------------------
Options.Window = {
  Locked = false,
  Pinned = false,
  Collapsed = false,
  Visible = true
}

--: LDB
---------------------------------------
Options.LDB = {
  minimapPos = 222,
  minimap = true
}

--: Alerts
---------------------------------------
Options.Alerts = {
  PhasingChat = false
}

--: Audio Alerts
---------------------------------------
Options.AudioAlerts = {
  DetectedPlayerSound = true,
  SoundChannel = "Master",
  DetectedPlayerSoundBGDisabled = false,
  DisableInSanctuary = true,
  DetectedPlayerSoundFile = "weizPVP: Notice 1"
}

--: Bars
---------------------------------------
Options.Bars = {
  MaxNumBars = 40,
  AlphaDead = 0.8,
  AlphaInactive = 0.6,
  AlphaDefault = 1,
  RowHeight = 17,
  VerticalSpacing = 1,
  Texture = "weizPVP: StatusBar",
  BarTexture = "weizPVP: Bar-BG",
  BarSolid = "weizPVP: SolidStatus",
  NameFont = "Accidental Presidency",
  NameFontSize = 14,
  LevelFont = "Accidental Presidency Italic",
  LevelFontSize = 15,
  GuildFont = "Accidental Presidency",
  GuildFontSize = 13,
  ShowUnattackable = false,
  ShowUnattackableColor = {
    ["r"] = NS.ColorsLUT["unattackableLight"].r,
    ["g"] = NS.ColorsLUT["unattackableLight"].g,
    ["b"] = NS.ColorsLUT["unattackableLight"].b,
    ["hex"] = NS.ColorsLUT["unattackableLight"].hex
  }
}

--: Sorting
---------------------------------------
Options.Sorting = {
  NearbyInactiveTimeout = 32,
  NearbyActiveTimeout = 20
}

--: Frames
---------------------------------------
Options.Frames = {
  BackgroundColor = {
    ["r"] = 0.039,
    ["g"] = 0.039,
    ["b"] = 0.039,
    ["a"] = 0.47
  },
  PlayerTooltips = true,
  AutoResize = false,
  Width = 251,
  Height = 247,
  X = nil,
  Y = nil,
  Scale = 1,
  Point = "CENTER",
  BorderSize = 1,
  --: Scroll Frame
  Scroll = {
    Height = 0
  },
  --: List Frame
  List = {
    Height = 0
  },
  --: Header Frame
  Header = {
    Height = 19,
    BackgroundColor = {
      ["r"] = 0.039,
      ["g"] = 0.039,
      ["b"] = 0.039,
      ["a"] = 0.9
    },
    Font = "Roboto Condensed BoldItalic"
  },
  --: StatusPopUp Frame
  StatusPopUp = {
    Height = 24,
    Font = "Accidental Presidency",
    FontOutline = "OUTLINE",
    BackgroundColor = {
      ["r"] = 1,
      ["g"] = 1,
      ["b"] = 1,
      ["a"] = 0.8
    },
    BorderColor = {
      ["r"] = 0,
      ["g"] = 0,
      ["b"] = 0,
      ["a"] = 1
    }
  }
}

--: Stealth Alert
---------------------------------------
Options.StealthAlert = {
  Enabled = true,
  EnableSound = true,
  SoundFile = "weizPVP: Warning 1",
  SoundChannel = "Master",
  ChatAlert = true,
  DisableSoundInBG = false,
  DisableSoundInSanctuary = true,
  DisableVisualStealthAlertsInSanctuary = true
}

--: KOS
---------------------------------------
Options.KOS = {
  AudioAlert = true,
  SoundChannel = "Master",
  AudioAlertFile = "weizPVP: Warning 2",
  ChatAlert = true,
  TaskbarAlert = true
}

--: Crosshair
---------------------------------------
Options.Crosshair = {
  Enabled = true,
  FriendlyCrosshairs = false,
  Alpha = 1,
  Scale = 1,
  ShowBountyOverlay = false,
  NameEnabled = false,
  GuildEnabled = false,
  ShowRange = true,
  LineThickness = 1,
  LineAlpha = 0.4
}

-- ace3 wildcard
Options["*"] = {}

-- ⚒️ Calculate additional sizes based on the dimensions of other elements
---------------------------------------
--: Dynamic values adjusted from other values needed during initial frame construction
Options.Frames.List.Height = Options.Bars.RowHeight + Options.Bars.VerticalSpacing
Options.Frames.Scroll.Height = (Options.Frames.List.Height * 12) + Options.Bars.VerticalSpacing
Options.Frames.Height = Options.Frames.Scroll.Height
Options.Frames.List.Height = Options.Frames.List.Height * Options.Bars.MaxNumBars

-- ➡️ Apply Defaults
---------------------------------------
NS._DefaultOptions = {
  profile = {
    Options = Options,
    KosList = {}
  }
}

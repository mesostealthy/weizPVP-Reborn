---------------------------------------------------------------------------------------------------
--|> CONSTANTS
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: ⬆️ Upvalues :--
NS.Constants = {}

--: addon
NS.Constants.AddonString = "|cffffffffweiz|r|cffffa012PVP|r"
NS.Constants.LogoNoBG = "|TInterface/Addons/weizPVP/Media/weizpvp_nobg.tga:0|t"

--: combat
NS.Constants.InCombat = NS.ColorsLUT["InCombat"]:WrapTextInColorCode("In Combat")
NS.Constants.OutOfCombat = NS.ColorsLUT["OutOfCombat"]:WrapTextInColorCode("Out of Combat")

--|> CREATE: ICON LUT
-----------------------------------------------------------
local IconLUT = {}
--: Window Status
IconLUT["move"] = "!" --:  MOVE
IconLUT["pin"] = "1" --:  PIN
IconLUT["unpin"] = "2" --:  UNPIN
IconLUT["lock"] = "3" --:  LOCK
IconLUT["unlock"] = "4" --:  UNLOCK

--: misc
IconLUT["phasing"] = "."

--: UI
IconLUT["bentUp"] = "5" --:  BENT ARROW : UP
IconLUT["bentDown"] = "6" --:  BENT ARROW: DOWN
IconLUT["arrowDown"] = "7" --:  ARROW: DOWN
IconLUT["arrowUp"] = "8" --:  ARROW: UP

--: factions
IconLUT["horde"] = "A" --:
IconLUT["alliance"] = "B" --:
IconLUT["warcraftW"] = "\\" --:

--: general icons
IconLUT["gear"] = "z"
IconLUT["wrench"] = "y"
IconLUT["lightningBolt"] = "k"
IconLUT["eye"] = "n"
IconLUT["locationPin"] = "o"
IconLUT["star"] = "Z"
IconLUT["starOutline"] = "."
IconLUT["chevronDown"] = "T"
IconLUT["bug"] = "g"
IconLUT["cpu"] = "f"
IconLUT["fire"] = "e"
IconLUT["hot"] = "e"
IconLUT["addUser"] = "m"
IconLUT["refresh"] = ","
IconLUT["refreshCCW"] = ","
IconLUT["refreshCW"] = "0"

--: notices
IconLUT["info"] = "J"
IconLUT["warning"] = "N"
IconLUT["halt"] = "P"
IconLUT["stop"] = "P"
IconLUT["minus"] = "R"
IconLUT["subtract"] = "R"
IconLUT["plus"] = "S"
IconLUT["add"] = "S"
IconLUT["new"] = "s"

--: shapes
IconLUT["no"] = "F"
IconLUT["ring"] = "G"
IconLUT["circle"] = "G"
IconLUT["circleOutline"] = "G"
IconLUT["triangle"] = "O"
IconLUT["triangleOutline"] = "O"

--: form
IconLUT["checkBoxChecked"] = "X"
IconLUT["checkBoxEmpty"] = "Y"

--: crosshair
IconLUT["crosshairFilledCenter"] = "C"
IconLUT["crosshair"] = "C"
IconLUT["crosshairOutline"] = "D"
IconLUT["crosshairNegative"] = "E"

--> APPLY
NS.IconLUT = CopyTable(IconLUT)

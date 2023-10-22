---------------------------------------------------------------------------------------------------
--|> Colors
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local pairs = pairs
local tonumber = tonumber

--: 🔎 COLORS LUT :-------------------
NS.ColorsLUT = {}

--: SOURCE COLOR TABLE :---------------
local ColorsLUT = {}
-- Addon Colors
ColorsLUT["logo"] = "ffa012" -- #ffa012
ColorsLUT["addon"] = ColorsLUT["logo"] -- #ffa012
ColorsLUT["phasing"] = "e32dff" -- #e32dff
ColorsLUT["stealth"] = "ff19b3" -- #ff19b3
-- Base Colors
ColorsLUT["black"] = "000000" -- #000000
ColorsLUT["darkGrey"] = "0f0f0f" -- #0f0f0f
ColorsLUT["lightGrey"] = "bbbbbb" -- #bbbbbb
ColorsLUT["white"] = "ffffff" -- #ffffff
ColorsLUT["red"] = "ff003b" -- #ff003b
ColorsLUT["pink"] = "ff5757" --  #ff5757
ColorsLUT["fuchsia"] = "ff19b3" --  #ff19b3
ColorsLUT["purple"] = "a100ff" -- #a100ff
ColorsLUT["lavender"] = "6060ff" -- #6060ff
ColorsLUT["darkBlue"] = "0077ff" -- #0077ff
ColorsLUT["lightBlue"] = "00f7ff" -- #00f7ff
ColorsLUT["paleBlue"] = "bffdff" -- ##bffdff
ColorsLUT["green"] = "3bff00" -- #3bff00
ColorsLUT["yellow"] = "ffff14" -- #ffff14
ColorsLUT["lightYellow"] = "feffce" -- #feffce
ColorsLUT["gold"] = "ffb300" -- #ffb300
ColorsLUT["orange"] = "ff6300" -- #ff6300
ColorsLUT["r"] = "ff0000" -- #ff0000
ColorsLUT["g"] = "00ff00" -- #00ff00
ColorsLUT["b"] = "0000ff" -- #0000ff
ColorsLUT["y"] = "ffff00" -- #ffff00
-- Combat
ColorsLUT["InCombat"] = ColorsLUT["red"] -- #ff003b
ColorsLUT["OutOfCombat"] = ColorsLUT["green"] -- #3bff00
-- Reaction
ColorsLUT["unattackable"] = ColorsLUT["lavender"] -- #6060ff
ColorsLUT["unattackableLight"] = "c1c1ff" -- #c1c1ff
ColorsLUT["neutral"] = ColorsLUT["y"] -- #ffff00
ColorsLUT["friendly"] = ColorsLUT["g"] -- #00ff00
ColorsLUT["hostile"] = ColorsLUT["r"] -- #ff0000
-- Notices
ColorsLUT["warning"] = ColorsLUT["yellow"] -- #ffff14
ColorsLUT["error"] = ColorsLUT["red"] -- #ff003b
ColorsLUT["info"] = ColorsLUT["lightBlue"] -- #00f7ff
ColorsLUT["notice"] = ColorsLUT["paleBlue"] -- #bffdff
ColorsLUT["complete"] = ColorsLUT["red"] -- #3bff00
-- Window State
ColorsLUT["Pinned"] = ColorsLUT["yellow"] -- #ffff14
ColorsLUT["pin"] = ColorsLUT["yellow"] -- #ffff14
ColorsLUT["Unpinned"] = ColorsLUT["lightBlue"] -- #00f7ff
ColorsLUT["unpin"] = ColorsLUT["lightBlue"] -- #00f7ff
ColorsLUT["Locked"] = ColorsLUT["red"] -- #ff003b
ColorsLUT["lock"] = ColorsLUT["red"] -- #ff003b
ColorsLUT["Unlocked"] = ColorsLUT["green"] -- #3bff00
ColorsLUT["unlock"] = ColorsLUT["green"] -- #3bff00
-- UI
ColorsLUT["uiMouse"] = ColorsLUT["lightBlue"] -- #00f7ff
ColorsLUT["uiDull"] = ColorsLUT["lightGrey"] -- #bbbbbb
-- MISC
ColorsLUT["realm"] = ColorsLUT["lightYellow"] -- #feffce

--> Extract Color Value From Hex <-----------------------------------
local function ExtractColorValueFromHex(str, index)
    return tonumber(str:sub(index, index + 1), 16) / 255
end

--> Create Color From Hex String <-----------------------------------
local function CreateColorFromHexString(hexColor)
    if #hexColor == 8 then
        local a, r, g, b =
        ExtractColorValueFromHex(hexColor, 1),
            ExtractColorValueFromHex(hexColor, 3),
            ExtractColorValueFromHex(hexColor, 5),
            ExtractColorValueFromHex(hexColor, 7)
        return CreateColor(r, g, b, a)
    else
        GMError("weizPVP: CreateColorFromHexString input must be hexadecimal digits")
    end
end

--> BUILD ADDITIONAL COLOR FORMATS <---------------------------------
for name, hex in pairs(ColorsLUT) do
    NS.ColorsLUT[name] = {}
    NS.ColorsLUT[name] = CreateColorFromHexString("ff" .. hex)
end
table.wipe(ColorsLUT)

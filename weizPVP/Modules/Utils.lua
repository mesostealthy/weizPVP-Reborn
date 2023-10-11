--|> 🧰 UTILS
-- A variety of functions used across the addon's namespace
---------------------------------------------------------------------------------------------------
local _, NS = ...

-- ⬆️ Upvalues
local gsub = gsub
local abs = abs
local pairs = pairs
local select = select
local ConvertPixelsToUI = ConvertPixelsToUI
local string_format = string.format
local math_modf = math.modf

-- Escape Sequence Table
local escapeSequences = {
  ["|c%x%x%x%x%x%x%x%x"] = "", -- color start
  ["|r"] = "", -- color end
  ["|H.-|h(.-)|h"] = "%1", -- links
  ["|T.-|t"] = "", -- textures
  ["{.-}"] = "" -- raid target icons
}

-- ⚒️ Unescape
--------------------------------
function NS.Unescape(str)
    for k, v in pairs(escapeSequences) do
        str = gsub(str, k, v)
    end
    return str
end

-- ⬅️ GET COLOR VALUE FROM GRADIENT
--: value = 0-1 value
--: ... = color values
function NS.GetColorValueFromGradient(value, ...)
    local rGrad, gGrad, bGrad
    local numGrad
    local segment, relperc
    local r1, g1, b1, r2, g2, b2
    if value >= 1 then
        rGrad, gGrad, bGrad = select(select("#", ...) - 2, ...)
        NS.RGB2Hex(abs(rGrad * 255), abs(gGrad * 255), abs(bGrad * 255))
    elseif value <= 0 then
        rGrad, gGrad, bGrad = ...
        NS.RGB2Hex(abs(rGrad * 255), abs(gGrad * 255), abs(bGrad * 255))
    end
    numGrad = select("#", ...) / 3
    segment, relperc = math_modf(value * (numGrad - 1))
    r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)
    rGrad = r1 + (r2 - r1) * relperc
    gGrad = g1 + (g2 - g1) * relperc
    bGrad = b1 + (b2 - b1) * relperc
    return NS.RGB2Hex(abs(rGrad * 255), abs(gGrad * 255), abs(bGrad * 255))
end

--⚒️ RGB TO HSV
function NS.RGB2Hex(r, g, b)
    r = r <= 255 and r >= 0 and r or 0
    g = g <= 255 and g >= 0 and g or 0
    b = b <= 255 and b >= 0 and b or 0
    return string_format("%02x%02x%02x", r, g, b)
end

-- ⚒️ SCALE PIXELS TO WIDTH
local function ScalePixelsToUi(pixels)
    if not pixels then
        return nil
    end
    return (NS.GetUiMultiplier() * pixels)
end

-- ⚒️ RESCALE FRAME
local function RescaleRegionSize(region)
    if not region then
        return
    end
    if not region.rescaled then
        region:SetWidth(ScalePixelsToUi(region:GetWidth()))
        region:SetHeight(ScalePixelsToUi(region:GetHeight()))
        region.rescaled = true
    end
end

-- ⚒️ Resize Frame to UI Scale
function NS.ResizeFrameToUiScale(frame)
    if (not frame) or (not frame.rescaled) then
        return
    end
    RescaleRegionSize(frame)
    return
end

-- ⬅️ GET UI MULTIPLIER
function NS.GetUiMultiplier()
    return ConvertPixelsToUI(1, UIParent:GetEffectiveScale())
end

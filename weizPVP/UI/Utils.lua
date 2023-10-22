---------------------------------------------------------------------------------------------------
--|> Core UI: Utils
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local gsub = gsub
local string_find = string.find
local WrapTextInColorCode = WrapTextInColorCode
local GetClassColor = GetClassColor
local select = select

--> GET Frame Position <---------------------------------------------
local function GetFramePosition(frame)
    if frame then
        local s = frame:GetScale()
        local left, top = frame:GetLeft() * s, frame:GetTop() * s
        local w, h = frame:GetWidth() * s, frame:GetHeight() * s
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left / s, top / s)
        frame:SetWidth(w / s)
        frame:SetHeight(h / s)
        return left, top, w, h, s, "TOPLEFT"
    else
        return nil
    end
end

--> SAVE Core Position <---------------------------------------------
function NS.SaveCoreFramePosition()
    NS.Options.Frames.X, NS.Options.Frames.Y, NS.Options.Frames.Width, _, NS.Options.Frames.Scale, NS.Options.Frames.Point = GetFramePosition(weizPVP_CoreFrame)
    NS.Options.Frames.Height = weizPVP_CoreFrame:GetHeight()
    NS.Options.Frames.List.Height = weizPVP_CoreFrame.ScrollFrame.ListFrame:GetHeight()
end

--> SET Core Position <----------------------------------------------
function NS.SetCoreFramePosition()
    weizPVP_CoreFrame:ClearAllPoints()
    weizPVP_CoreFrame:SetHeight(NS.Options.Frames.Height / NS.Options.Frames.Scale)
    weizPVP_CoreFrame:SetWidth(NS.Options.Frames.Width / NS.Options.Frames.Scale)
    weizPVP_CoreFrame:SetScale(NS.Options.Frames.Scale)
    if (not NS.Options.Frames.X) or (not NS.Options.Frames.Y) then
        weizPVP_CoreFrame:SetPoint("CENTER", UIParent)
        NS.Options.Frames.X,
            NS.Options.Frames.Y,
            NS.Options.Frames.Width,
            _,
            NS.Options.Frames.Scale,
            NS.Options.Frames.Point = GetFramePosition(weizPVP_CoreFrame)
    end
    weizPVP_CoreFrame:SetPoint(
    "TOPLEFT",
        UIParent,
        "BOTTOMLEFT",
        NS.Options.Frames.X / NS.Options.Frames.Scale,
        NS.Options.Frames.Y / NS.Options.Frames.Scale
    )
end

--> Format Player Name Only <----------------------------------------
function NS.FormatPlayerNameOnly(playerName)
    local charName =
    WrapTextInColorCode(gsub(playerName, "-(.*)", ""), select(4, GetClassColor(NS.PlayerDB[playerName].C)))
    if not string_find(playerName, NS.PlayerRealm) then
        charName = charName .. "|cFFFF00CC*|r"
    end
    return charName
end

--> Format Player Name And Realm <-----------------------------------
function NS.FormatPlayerNameAndRealm(playerName, GUID)
    if (not playerName) or (not GUID) then
        return "???"
    end

    local charNameAndRealm

    if NS.PlayerDB[playerName] then
        charNameAndRealm = WrapTextInColorCode(gsub(playerName, "-(.*)", ""), select(4, GetClassColor(NS.PlayerDB[playerName].C)))
        charNameAndRealm = charNameAndRealm .. " |cffbbbbbb-|r " .. NS.ColorsLUT["realm"]:WrapTextInColorCode(gsub(playerName, "^(.*-)", ""))
    else
        charNameAndRealm = WrapTextInColorCode(
        gsub(playerName, "-(.*)", ""),
            select(4, GetClassColor(NS.PlayerDB[NS.PlayerActiveCache[GUID].Name].C))
        )
        charNameAndRealm = charNameAndRealm ..
            " |cffbbbbbb-|r " ..
            NS.ColorsLUT["realm"]:WrapTextInColorCode(gsub(NS.PlayerActiveCache[GUID].Name, "^(.*-)", ""))
    end
    return charNameAndRealm
end

--> Scale Main Window <----------------------------------------------
function NS.ScaleMainWindow()
    weizPVP_CoreFrame:SetScale(NS.Options.Frames.Scale)
    NS.SaveCoreFramePosition()
end

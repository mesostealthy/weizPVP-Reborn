---------------------------------------------------------------------------------------------------
--|> Player ToolTip
-- 📌 Detailed tooltips for player bars
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local WrapTextInColorCode = WrapTextInColorCode
local GetClassColor = GetClassColor
local select = select
local strsplit = strsplit
local gsub = gsub

local roleIcons = {
  ["TANK"] = "|TInterface/Addons/weizPVP/Media/Roles/tank.tga:0|t",
  ["DAMAGER"] = "|TInterface/Addons/weizPVP/Media/Roles/damager.tga:0|t",
  ["HEALER"] = "|TInterface/Addons/weizPVP/Media/Roles/healer.tga:0|t",
  ["UNKNOWN"] = "|TInterface/Addons/weizPVP/Media/Roles/unknown.tga:0|t"
}

--> Show Player Tooltip <--------------------------------------------
function NS.ShowPlayerTooltip(GUID)
    if not NS.Options.Frames.PlayerTooltips then
        NS.HidePlayerTooltip()
        return
    end
    if GUID and NS.PlayerActiveCache[GUID] then
        -- Get player info

        local fullName = NS.PlayerActiveCache[GUID].Name
        local name, realmName = strsplit("-", fullName)
        local formattedName = NS.PlayerActiveCache[GUID].displayName
        formattedName = gsub(formattedName, "-(.*)", "")
        NS.PlayerActiveCache[GUID].displayName = formattedName
        local class = NS.PlayerDB[fullName].C
        local estimated = NS.PlayerDB[fullName].E
        local race = NS.PlayerDB[fullName].RC or nil
        local level = NS.FormatLevelString(estimated, NS.PlayerDB[fullName].L)

        -- Realm
        local realm
        if realmName == NS.Player.FromSubRealm then
            realm = "|cff75e6ff" .. NS.Player.FromSubRealm .. "|r" -- blue for same realm
        else
            realm = "|cFFFF00CC" .. realmName .. "|r" -- bright purple for other realms
        end

        -- Guild
        local guild = NS.PlayerActiveCache[GUID].displayGuild or NS.PlayerDB[fullName].G or nil
        if (not guild) and (not estimated) then
            guild = "|c44999999[no guild]|r "
        elseif not guild then
            guild = nil
        elseif guild then
            guild = " |cffe3fff3" .. guild .. "|r"
        end

        -- Role
        local role = NS.PlayerDB[fullName].RL or nil
        local roleIcon
        if role then
            roleIcon = roleIcons[role]
        else
            roleIcon = nil
        end

        -- Set Tooltip
        weizPVP_CoreTooltip:SetOwner(weizPVP_CoreBar)
        weizPVP_CoreTooltip:ClearAllPoints()
        weizPVP_CoreTooltip:SetAnchorType("ANCHOR_TOPRIGHT")

        -- : Build Title Left (Name, Level, Role)
        local titleLeft = ""

        -- * Weiz????
        if name == "Weiz" and realmName == "EmeraldDream" then
            titleLeft = "|TInterface/Addons/weizPVP/Media/weizpvp_nobg.tga:0|t "
        end

        -- * Add Role Icon, if we have one
        if roleIcon then
            titleLeft = titleLeft .. roleIcon .. " "
        end

        -- * KOS check
        if NS.KosList[fullName] then
            titleLeft = titleLeft ..
                "|TInterface/Addons/weizPVP/Media/Icons/kos.tga:0|t |cFFFF0040>|r" ..
                WrapTextInColorCode(formattedName .. "|cFFFF0040<|r", select(4, GetClassColor(class)))
        else
            titleLeft = titleLeft .. WrapTextInColorCode(formattedName .. " ", select(4, GetClassColor(class)))
        end

        -- * Level Format
        titleLeft = titleLeft .. " |cffffffff" .. level .. "|r "

        -- : Build top line
        weizPVP_CoreTooltip:AddLine(titleLeft)
        if guild then
            weizPVP_CoreTooltip:AddLine(guild)
        end

        if race then
            weizPVP_CoreTooltip:AddLine(" |cfff8ffa6" .. race .. "|r" .. "      " .. realm .. " ")
        else
            weizPVP_CoreTooltip:AddLine("|cffdfe1d0 [race unknown]|r      " .. realm .. " ")
        end

        if estimated then
            weizPVP_CoreTooltip:AddLine(" |cFFff59f8(Estimated Values)|r")
        end

        weizPVP_CoreTooltip:Show()
    end
end

--> Hide Player Tooltip <--------------------------------------------
function NS.HidePlayerTooltip()
    weizPVP_CoreTooltip:Hide()
end

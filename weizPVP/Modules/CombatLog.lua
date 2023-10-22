---------------------------------------------------------------------------------------------------
--|> COMBAT LOG
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local bit_band = bit.band
local strfind = strfind
local strsub = strsub
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local time = time
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local CL_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local CL_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local GetSpellInfo = GetSpellInfo

--: Auras Constants :------------------
local holyPriest = {
  [27827] = GetSpellInfo(27827),
  [20711] = GetSpellInfo(20711),
  [126094] = GetSpellInfo(126094)
}
local stealthIDs = {
  [1784] = true, -- Stealth
  [6770] = true, -- Sap
  [199483] = true, -- Camouflage
  [6409] = true, -- Cheap Shot
  [9736] = true, -- Arantir's Deception
  [11327] = true, -- Vanish
  [66] = true, -- Invisibility
  [5215] = true, -- Prowl
  [113862] = true, -- Greater Invisibility
  -- Shroud
  [115834] = true, -- Shroud of Concealment
  [114018] = true, -- Shroud of Concealment
  -- Hide
  [180592] = true, -- Hide
  [6920] = true, -- Hide, rank 2
  [67340] = true, -- Hide, rank 2, again?
  -- See Stealth
  [188501] = true, -- Spectral Sight
  -- Malicious
  [341189] = true, -- Malicious (Construct Ability)
  [341194] = true, -- Malicious (Construct Ability)
  [339254] = true, -- Malicious (Construct Ability)
  --Items
  [156136] = true, -- Stealth Field (Stealthman)
  [250960] = true, -- Potion of Concealment
  [307195] = true -- Invisible
}
local stealthNames = {
  ["Stealth"] = true,
  ["Sap"] = true,
  ["Invisible"] = true,
  ["Camouflage"] = true,
  ["Cheap Shot"] = true,
  ["Shroud of Concealment"] = true,
  ["Vanish"] = true,
  ["Prowl"] = true,
  ["Spectral Sight"] = true,
  ["Arantir's Deception"] = true,
  ["Invisibility"] = true,
  ["Stealth Field"] = true,
  ["Greater Invisibility"] = true
}

--> Static Role Assignment <-----------------------------------------
local function RoleAssign(class)
    if class == "ROGUE" or class == "MAGE" or class == "WARLOCK" or class == "HUNTER" then
        return "DAMAGER"
    end
    return nil
end

--> Role Check <-----------------------------------------------------
local function ClRoleCheck(spellId, class)
    return RoleAssign(class) or NS.GetRoleFromSpellId(spellId)
end

--> Is Valid Player? <-----------------------------------------------
local function IsValidPlayer(flags, guid, name)
    -- Valid Check
    if not flags or not guid or not name then
        return
    end
    -- Check for 'Unknown': Reserved Name for players that don't have name information yet
    name = name or "Unknown"
    if strfind(name, "Unknown") then
        return
    end
    -- Is this a Hostile Player?
    if bit_band(flags, CL_HOSTILE) == CL_HOSTILE and bit_band(flags, CL_PLAYER) == CL_PLAYER then
        return true
    end
    return
end

--> CL: CREATE NEW PLAYER ENTRY IN DB <------------------------------
local abilityType
local function AddNewPlayerToDatabase(event, srcName, srcGUID, spellId)
    if srcName and srcGUID then
        NS.PlayerDB[srcName] = {}
        NS.PlayerDB[srcName].T = time()
        NS.PlayerDB[srcName].E = true
        abilityType = strsub(event, 1, 5)
        if abilityType == "SWING" or abilityType == "SPELL" or abilityType == "RANGE" then
            NS.PlayerDB[srcName].L = NS.GetLevelFromSpellId(spellId) or 0
        else
            NS.PlayerDB[srcName].L = 0
        end
        _, NS.PlayerDB[srcName].C = GetPlayerInfoByGUID(srcGUID)
        NS.PlayerDB[srcName].RL = ClRoleCheck(spellId, NS.PlayerDB[srcName].C) or nil
    end
    abilityType = nil
end

--> CL: DEATH CHECK <------------------------------------------------
local function CLDeath(event, GUID, name)
    if (not NS.PlayerActiveCache[GUID]) or event ~= "UNIT_DIED" then
        return false --: return false on no death seen
    end
    NS.PlayerActiveCache[GUID].Dead = true
    NS.UpdatePlayerActiveCache(name, nil, true, nil, GUID)
    return true
end

--> Aura Check <-----------------------------------------------------
local spellIcon
local function AuraCheck(spellID, spellName, srcGUID, srcName)
    -- * Stealth check
    if stealthNames[spellName] or stealthIDs[spellID] then
        if NS.Options.StealthAlert.Enabled then
            _, _, spellIcon = GetSpellInfo(spellID)
            NS.StealthAlertEvent(spellName, NS.FormatPlayerNameAndRealm(srcName, srcGUID), spellIcon)
        end
        NS.UpdatePlayerActiveCache(srcName, true, false, nil, srcGUID)
        return true
    end

    -- * Redemption check
    if holyPriest[spellID] then
        NS.UpdatePlayerActiveCache(srcName, nil, true, "HEALER", srcGUID)
        return true --: Return after updating player cache
    end

    return false
end

--> Format CLog Name <-----------------------------------------------
local function FormatCLogName(srcName)
    if not strfind(srcName, "-") then
        srcName = srcName .. "-" .. NS.PlayerRealm
    end
    return srcName
end

--> Process Source <-------------------------------------------------
local srcName
local newLevel
local srcRole
local function ParseSource(eventData)
    if IsValidPlayer(eventData[6], eventData[4], eventData[5]) then
        srcName = FormatCLogName(eventData[5])

        -- * Check if unit is not in DB yet
        if not NS.PlayerDB[srcName] then
            AddNewPlayerToDatabase(eventData[2], srcName, eventData[4], eventData[12])
        end

        -- * Level Check, if Estimated
        if NS.PlayerDB[srcName].E then
            newLevel = NS.GetLevelFromSpellId(eventData[12]) or nil
            if newLevel then
                NS.PlayerDB[srcName].L = (newLevel > (NS.PlayerDB[srcName].L or 0)) and newLevel or NS.PlayerDB[srcName].L
            end
        end

        -- * AuraCheck
        if eventData[2] == "SPELL_AURA_APPLIED" then
            if AuraCheck(eventData[12], eventData[13], eventData[4], srcName) then
                return
            end
        end

        NS.UpdatePlayerActiveCache(srcName, nil, false, nil, eventData[4]) --(name, stealth, dead, role, GUID)

        -- * Check role
        if NS.PlayersOnBars[eventData[4]] and not NS.PlayerActiveCache[eventData[4]].RoleFound then
            srcRole = ClRoleCheck(eventData[12], NS.PlayerDB[srcName].C)
            if srcRole then
                if NS.PlayerDB[srcName].RL ~= srcRole then
                    NS.PlayerDB[srcName].RL = srcRole
                end
                NS.PlayerActiveCache[eventData[4]].RoleFound = true
            end
        end
    end
end

--> Process Destination <--------------------------------------------
-- Only checks for deaths; basic player data would be overkill as being hit will trigger another event instantly anyways
local function ParseDestination(eventData)
    -- * Check for unit death
    if eventData[2] == "UNIT_DIED" then -- unit died?
        if IsValidPlayer(eventData[10], eventData[8], eventData[9]) then
            CLDeath(eventData[2], eventData[8], FormatCLogName(eventData[9]))
        end
    end
end

--> ⚡ COMBAT LOG ------------------------------------------
function NS.CombatLogEvent()
    ParseSource({ CombatLogGetCurrentEventInfo() })
    ParseDestination({ CombatLogGetCurrentEventInfo() })
end

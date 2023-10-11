---------------------------------------------------------------------------------------------------
-- |> DATA PROCESSING
-- 📌 Functions that help acquire and manage data involving the PlayerDB
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local UnitName = UnitName
local GetGuildInfo = GetGuildInfo
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitOnTaxi = UnitOnTaxi
local UnitIsPlayer = UnitIsPlayer
local GetUnitName = GetUnitName
local UnitLevel = UnitLevel
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsEnemy = UnitIsEnemy
local UnitGUID = UnitGUID
local UnitFactionGroup = UnitFactionGroup
local select = select
local gsub = gsub
local time = time

--> AddNewPlayer <---------------------------------------------------
-- : Updates data in the PlayerActiveCache
-- : Sends data off the Lists to be processed
local function AddNewPlayer(GUID, name)
  -- Update PlayerCache info
  NS.PlayerActiveCache[GUID] = NS.PlayerActiveCache[GUID] or {}
  NS.PlayerActiveCache[GUID].GUID = GUID
  -- NAME
  NS.PlayerActiveCache[GUID].Name = name

  -- DISPLAY NAME
  if NS.Options.Region.ConvertRussianNames == true then
    NS.PlayerActiveCache[GUID].displayName = NS.ConvertString_CyrillicToRomanian(gsub(name, "-(.*)", ""))
  else
    NS.PlayerActiveCache[GUID].displayName = gsub(name, "-(.*)", "")
  end

  -- DISPLAY GUILD
  if NS.Options.Region.ConvertRussianGuilds then
    NS.PlayerActiveCache[GUID].displayGuild = NS.ConvertString_CyrillicToRomanian(NS.PlayerDB[name].G)
  else
    NS.PlayerActiveCache[GUID].displayGuild = NS.PlayerDB[name].G
  end

  -- LEVEL
  NS.PlayerActiveCache[GUID].L = NS.PlayerDB[name].L
  NS.PlayerActiveCache[GUID].E = NS.PlayerDB[name].E
end

--> UpdatePlayerActiveCache <----------------------------------------
local newPlayerOnList = false
function NS.UpdatePlayerActiveCache(name, stealth, dead, role, GUID)
  -- Verify GUID exists
  if not GUID or not name then
    return
  end

  -- : Check for player already in cache

  if not NS.PlayerActiveCache[GUID] then
    AddNewPlayer(GUID, name)
    newPlayerOnList = true
  end

  -- : STEALTH
  if stealth ~= nil then
    NS.PlayerActiveCache[GUID].Stealth = stealth
  end

  -- : DEAD
  if dead ~= nil then
    NS.PlayerActiveCache[GUID].Dead = dead
    if dead then
      NS.PlayerActiveCache[GUID].Health = 0
    elseif not dead and NS.PlayerActiveCache[GUID].Health == 0 then
      NS.PlayerActiveCache[GUID].Health = 1
    end
  end

  -- : Formatted Guild
  if (not NS.PlayerActiveCache[GUID].displayGuild) and NS.PlayerDB[name].G then
    NS.PlayerActiveCache[GUID].displayGuild = NS.ConvertString_CyrillicToRomanian(NS.PlayerDB[name].G)
  end

  -- : ROLE
  if role ~= nil then
    NS.PlayerActiveCache[GUID].RL = role
    NS.PlayerDB[name].RL = role
  end

  NS.AddPlayerDataToNearby(GUID, newPlayerOnList)

  newPlayerOnList = false
end

--> Static Role Assignment <-----------------------------------------
function NS.ClassRoleAssign(class)
  if class == "ROGUE" or class == "MAGE" or class == "WARLOCK" or class == "HUNTER" then
    return "DAMAGER"
  end
  return nil
end

--> Get Unit Data <--------------------------------------------------
local currentTime
local fullName
local getGUID
local unitUpdateThreshold = 120 -- 2 minutes between guild/race/level/role checks
function NS.GetUnitData(unit)
  if not unit then
    return
  end
  if UnitExists(unit) and NS.IsUnitValidForTracking(unit) then
    currentTime = time()
    fullName = NS.GetFullNameOfUnit(unit) or nil
    getGUID = UnitGUID(unit) or nil
    if fullName and getGUID then
      -- : Add player to DB if not found
      if not NS.PlayerDB[fullName] then
        NS.PlayerDB[fullName] = {}
        _, NS.PlayerDB[fullName].C = UnitClass(unit)
        NS.PlayerDB[fullName].RL = NS.ClassRoleAssign(NS.PlayerDB[fullName].C)
      end

      NS.PlayerDB[fullName].T = currentTime

      -- : Update player info if estimated or past update threshold
      if NS.PlayerDB[fullName].T + unitUpdateThreshold > currentTime or NS.PlayerDB[fullName].E then
        NS.PlayerDB[fullName].G = GetGuildInfo(unit)
        NS.PlayerDB[fullName].L = UnitLevel(unit)
        NS.PlayerDB[fullName].RC = UnitRace(unit)
      end

      -- : Player On Bars?
      if NS.PlayersOnBars[getGUID] and NS.PlayerActiveCache[getGUID] then
        NS.PlayerActiveCache[getGUID].OnTaxi = UnitOnTaxi(unit) or nil
        NS:UnitHealthEvent(unit)
      end

      NS.PlayerDB[fullName].E = nil
      NS.UpdatePlayerActiveCache(fullName, nil, nil, nil, getGUID) -- (name, stealth, dead, role, GUID)
    end
  end
end

--> Remove Friendly Player <-----------------------------------------
local removeFriendGUID
local function RemoveFriendlyPlayer(unit)
  removeFriendGUID = UnitGUID(unit) or nil

  --: Remove from Cache
  NS.PlayerActiveCache[removeFriendGUID] = nil

  --: Remove player for lists
  -- Alive
  if NS.ActiveList[removeFriendGUID] then
    NS.ActiveList[removeFriendGUID].TimeAdded = 0
    NS.ActiveList[removeFriendGUID].TimeUpdated = 0
  elseif NS.ActiveDeadList[removeFriendGUID] then
    -- Dead
    NS.ActiveDeadList[removeFriendGUID].TimeAdded = 0
    NS.ActiveDeadList[removeFriendGUID].TimeUpdated = 0
  elseif NS.InactiveList[removeFriendGUID] then
    -- Inactive
    NS.InactiveList[removeFriendGUID].TimeAdded = 0
    NS.InactiveList[removeFriendGUID].TimeUpdated = 0
  elseif NS.InactiveDeadList[removeFriendGUID] then
    -- Inactive Dead
    NS.InactiveDeadList[removeFriendGUID].TimeAdded = 0
    NS.InactiveDeadList[removeFriendGUID].TimeUpdated = 0
  end

  --: Wipe from Current List
  if NS.CurrentNameplates[removeFriendGUID] then
    NS.CurrentNameplates[removeFriendGUID] = nil
  end

  --: Refresh list by re-checking timeouts (which we zeroed)
  NS.ManageListTimeouts()
end

--> Is Unit Valid For Tracking <-------------------------------------
function NS.IsUnitValidForTracking(unit)
  --: Is Player?
  if (not unit) or (not UnitIsPlayer(unit)) then -- input check
    return false
  end

  --: "Unknown" check
  -- (The name given to players in edge cases were blizzard does not yet have the name of the unit)
  if GetUnitName(unit) == "Unknown" then
    return false
  end

  --: Can we attack this unit?
  if UnitCanAttack("player", unit) or UnitIsEnemy("player", unit) then -- enemy player check
    return true
  end

  --: Check for previously mind-controlled friendly players
  if NS.PlayerActiveCache[UnitGUID(unit)] and select(1, UnitFactionGroup(unit)) == NS.Player.Faction then
    RemoveFriendlyPlayer(unit)
  end
end

-->  Get Full Name of Unit <-----------------------------------------
local name, realm
function NS.GetFullNameOfUnit(unit)
  if not unit then -- check for unit
    return
  end

  -- get name
  name, realm = UnitName(unit, true)
  if not name then
    return
  end

  -- add "-" + realm
  if not realm then
    --  same realm
    return name .. "-" .. NS.PlayerRealm
  else
    --  different realm
    realm = gsub(realm, "[%s%-]", "")
    return name .. "-" .. realm
  end
end

--> UnitHealthCheck <------------------------------------------------
local function UnitHealthCheck(unit, GUID)
  NS.PlayerActiveCache[GUID].Dead = UnitIsDeadOrGhost(unit)
  NS.PlayerActiveCache[GUID].Health = UnitHealth(unit) / UnitHealthMax(unit) * 100
  NS.RefreshBarByGUID(GUID)
end

--> ⚡ : UNIT_HEALTH ---------------------------------------
function NS.UnitHealthEvent(_, unit)
  if NS.IsUnitValidForTracking(unit) and NS.PlayersOnBars[UnitGUID(unit)] then
    UnitHealthCheck(unit, UnitGUID(unit))
  end
end

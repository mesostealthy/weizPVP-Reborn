---------------------------------------------------------------------------------------------------
--|> DATABASE
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local time = time
local pairs = pairs
local wipe = wipe

--: Constants :------------------------
local SECOND_IN_DAY = 86400
local DATABASE_VERSION = 3

--> Optimize Database <----------------------------------------------
local function OptimizeDatabase(currentTime, days)
    NS.Options.Database.LastCleaned = currentTime
    NS.Options.Database.VERSION = DATABASE_VERSION
    local additionalTime = days * SECOND_IN_DAY

    for player, k in pairs(NS.PlayerDB) do
        --* v2 -  clean old db leftovers (Name)
        if NS.PlayerDB[player].Role then
            NS.PlayerDB[player].RL = NS.PlayerDB[player].Role
            NS.PlayerDB[player].Role = nil
        end
        if NS.PlayerDB[player].Race then
            NS.PlayerDB[player].RC = NS.PlayerDB[player].Race
            NS.PlayerDB[player].Race = nil
        end
        if NS.PlayerDB[player].Guild then
            NS.PlayerDB[player].G = NS.PlayerDB[player].Guild
            NS.PlayerDB[player].Guild = nil
        end
        if NS.PlayerDB[player].Class then
            NS.PlayerDB[player].C = NS.PlayerDB[player].Class
            NS.PlayerDB[player].Class = nil
        end
        if NS.PlayerDB[player].Timestamp then
            NS.PlayerDB[player].T = NS.PlayerDB[player].Timestamp
            NS.PlayerDB[player].Timestamp = nil
        end
        if NS.PlayerDB[player].Level then
            NS.PlayerDB[player].L = NS.PlayerDB[player].Level
            NS.PlayerDB[player].Level = nil
        end
        if NS.PlayerDB[player].Estimated ~= nil then
            NS.PlayerDB[player].E = NS.PlayerDB[player].Estimated
            NS.PlayerDB[player].Estimated = nil
        end
        if NS.PlayerDB[player].E == false then
            NS.PlayerDB[player].E = nil
        end

        --* v1 -  clean old db leftovers (Name)
        if NS.PlayerDB[player].Name then
            NS.PlayerDB[player].Name = nil
        end

        --* v0 - Clean out players not seen since x days
        if k.T and k.T + additionalTime < currentTime then
            wipe(NS.PlayerDB[player])
            NS.PlayerDB[player] = nil
        end
    end
end

--> CLEAN DB: Specific Days <----------------------------------------
function NS.CleanDB_SpecificDays(days)
    days = days or NS.Options.Database.CleanTime
    local currentTime = time()
    if NS.Options.Database.VERSION ~= DATABASE_VERSION then
        OptimizeDatabase(currentTime, days)
    elseif NS.Options.Database.LastCleaned + SECOND_IN_DAY < currentTime then -- only update once a day
        OptimizeDatabase(currentTime, days)
    end
end

--> Load Database <--------------------------------------------------
function NS.LoadDB()
    -- LOAD CHARACTER DB
    NS.charDB = LibStub("AceDB-3.0"):New("_weizpvp_chardb", NS._DefaultOptions, true)
    NS.Options = NS.charDB.profile.Options
    NS.oldKosList = NS.charDB.profile.KosList or nil

    -- LOAD GLOBAL INFO (ACCOUNT-WIDE) DB
    NS.global_info = LibStub("AceDB-3.0"):New("_weizpvp_global_info", {}, false)

    -- LOAD GLOBAL (ACCOUNT-WIDE) DB
    NS.globalDB = LibStub("AceDB-3.0"):New("_weizpvp_globaldb", {}, false)
    NS.GlobalVersionUpgradeCheck()
    NS.PlayerDB = NS.globalDB.global.PlayerDB or {}
    NS.KosList = NS.globalDB.global.KosList or {}

    -- MAINTAIN DB
    NS.CleanDB_SpecificDays(NS.Options.Database.CleanTime)
    NS.VersionUpgradeCheck() -- update check
end

---------------------------------------------------------------------------------------------------
--|> NEARBY LISTS
-- 📌 Manages the lists of players nearby
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: ⬆️ Upvalues :--
local CopyTable = CopyTable
local tinsert, sort, wipe = tinsert, sort, wipe
local pairs = pairs
local GetTime = GetTime

--: NS Lists :-------------------------
NS.CurrentNameplates = {}
NS.CurrentNameplatesSize = {}

NS.Nearby = {}

NS.NearbyListSize = 0
NS.NearbyList = {}

NS.ActiveList = {}
NS.InactiveList = {}
NS.ActiveDeadList = {}
NS.InactiveDeadList = {}

NS.PlayersOnBars = {}
NS.PlayersOnBarsSize = {}

--> Manage List Timeouts <-------------------------------------------
function NS.ManageNearbyListTimeouts()
    local expired = false
    local removed = false
    local expiredCount = 0
    local count = 1
    local timestamp = GetTime()
    --: ACTIVE
    for player in pairs(NS.ActiveList) do
        if (timestamp - NS.ActiveList[player].TimeUpdated) > NS.Options.Sorting.NearbyActiveTimeout and
            NS.CurrentNameplates[player] == nil then
            NS.InactiveList[player] = NS.ActiveList[player]
            NS.InactiveList[player].TimeAdded = timestamp + (count * 0.001)
            NS.ActiveList[player] = nil
            count = count + 1
            expired = true
        end
    end
    count = 0
    --: ACTIVE DEAD
    timestamp = GetTime()
    for player in pairs(NS.ActiveDeadList) do
        if (timestamp - NS.ActiveDeadList[player].TimeUpdated) > NS.Options.Sorting.NearbyActiveTimeout then
            NS.InactiveDeadList[player] = NS.ActiveDeadList[player]
            NS.InactiveDeadList[player].TimeAdded = timestamp + (count * 0.001)
            NS.ActiveDeadList[player] = nil
            expired = true
            count = count + 1
        end
    end
    --: INACTIVE
    timestamp = GetTime()
    for player in pairs(NS.InactiveList) do
        if (timestamp - NS.InactiveList[player].TimeUpdated) > NS.Options.Sorting.NearbyInactiveTimeout then
            NS.InactiveList[player] = nil
            NS.NearbyList[player] = nil
            NS.PlayerActiveCache[player] = nil
            expiredCount = expiredCount + 1
            expired = true
            removed = true
        end
    end
    --: INACTIVE DEAD
    timestamp = GetTime()
    for player in pairs(NS.InactiveDeadList) do
        if (timestamp - NS.InactiveDeadList[player].TimeUpdated) > NS.Options.Sorting.NearbyInactiveTimeout then
            NS.InactiveDeadList[player] = nil
            NS.NearbyList[player] = nil
            NS.PlayerActiveCache[player] = nil
            expiredCount = expiredCount + 1
            expired = true
            removed = true
        end
    end
    if expired or removed then
        NS.NearbyListSize = NS.NearbyListSize - expiredCount
        NS.SortNearbyList()
        NS.UpdateNearbyCount()
        NS.RefreshCurrentList()
        NS.CoreUI.ChangeTargetIcon()
    end
    if removed then
        NS.ManageBarsDisplayed()
    end
end

--> Sort Nearby List <-----------------------------------------------
local tempCurrentList = {}
local tempActiveList = {}
local tempActiveDeadList = {}
local tempInactiveList = {}
local tempInactiveDeadList = {}
function NS.SortNearbyList()
    --: ActiveList
    for player in pairs(NS.ActiveList) do
        if NS.NearbyList[player] then
            if NS.NearbyList[player].TimeAdded then
                tinsert(tempActiveList, { player = player, time = NS.NearbyList[player].TimeAdded })
            end
        end
    end
    --: ActiveDeadList
    for player in pairs(NS.ActiveDeadList) do
        if NS.NearbyList[player] then
            if NS.NearbyList[player].TimeAdded then
                tinsert(tempActiveDeadList, { player = player, time = NS.NearbyList[player].TimeAdded })
            end
        end
    end
    --: InactiveDeadList
    for player in pairs(NS.InactiveDeadList) do
        if NS.NearbyList[player] then
            if NS.NearbyList[player].TimeAdded then
                tinsert(tempInactiveDeadList, { player = player, time = NS.NearbyList[player].TimeAdded })
            end
        end
    end
    --: InactiveList
    for player in pairs(NS.InactiveList) do
        if NS.NearbyList[player] then
            if NS.NearbyList[player].TimeAdded then
                tinsert(tempInactiveList, { player = player, time = NS.NearbyList[player].TimeAdded })
            end
        end
    end
    --: sorts
    sort(
    tempActiveList,
        function(a, b)
            return a.time < b.time
        end
    )
    sort(
    tempActiveDeadList,
        function(a, b)
            return a.time < b.time
        end
    )
    sort(
    tempInactiveList,
        function(a, b)
            return a.time < b.time
        end
    )
    sort(
    tempInactiveDeadList,
        function(a, b)
            return a.time < b.time
        end
    )
    --: create player list
    for player in pairs(tempActiveList) do
        if NS.PlayerActiveCache[tempActiveList[player].player] then
            if NS.KosList[NS.PlayerActiveCache[tempActiveList[player].player].Name] then
                tinsert(tempCurrentList, tempActiveList[player])
                tempActiveList[player] = nil
            end
        end
    end
    for player in pairs(tempActiveList) do
        tinsert(tempCurrentList, tempActiveList[player])
    end
    for player in pairs(tempActiveDeadList) do
        tinsert(tempCurrentList, tempActiveDeadList[player])
    end
    for player in pairs(tempInactiveList) do
        tinsert(tempCurrentList, tempInactiveList[player])
    end
    for player in pairs(tempInactiveDeadList) do
        tinsert(tempCurrentList, tempInactiveDeadList[player])
    end
    NS.CurrentList = CopyTable(tempCurrentList)
    wipe(tempCurrentList)
    wipe(tempActiveList)
    wipe(tempActiveDeadList)
    wipe(tempInactiveList)
    wipe(tempInactiveDeadList)
end

--> Clear List Data <------------------------------------------------
function NS.ClearNearbyListData()
    if NS.NearbyCount ~= 0 then
        wipe(NS.CurrentList)
        wipe(NS.CurrentNameplates)
        wipe(NS.NearbyList)
        wipe(NS.ActiveList)
        wipe(NS.InactiveList)
        wipe(NS.ActiveDeadList)
        wipe(NS.InactiveDeadList)
        wipe(NS.PlayersOnBars)
        wipe(NS.PlayerActiveCache)
        NS.NearbyListSize = 0
        NS.SortNearbyList()
        NS.ManageBarsDisplayed()
        NS.RefreshCurrentList()
        NS.UpdateNearbyCount()
        weizPVP_CoreFrame.ScrollFrame:SetVerticalScroll(0)
        NS:PlayerTargetEvent()
        NS.AutoResize()
        NS.CoreUI.ChangeTargetIcon()
    end
end

---------------------------------------------------------------------------------------------------
--|> KOS
-- 📌 Kill On Sight player tracking, notifications and visual indicators
---------------------------------------------------------------------------------------------------
local _, NS = ...

--: 🆙 Upvalues :----------------------
local select = select
local gsub = gsub
local GetClassColor = GetClassColor
local WrapTextInColorCode = WrapTextInColorCode

--: NAMESPACE :------------------------
NS.KOS = {}

--> Is Player Target <-----------------------------------------------
local function IsPlayerTarget()
    if NS.GetFullNameOfUnit("target") == NS.KOS.menuPlayerName then
        NS.Crosshair.Reset()
        NS.Crosshair.NewTarget()
    end
end

--> Change Kos Status <----------------------------------------------
function NS.KOS.ChangeKosStatus(playerName)
    if not playerName then
        return
    end
    local unescapedName = NS.Unescape(playerName)
    NS.KOS.menuPlayerName = unescapedName
    local printedName =
    WrapTextInColorCode(gsub(unescapedName, "-(.*)", ""), select(4, GetClassColor(NS.PlayerDB[unescapedName].C)))
    local printedRealm = gsub(unescapedName, "^(.*-)", "")
    if NS.KosList[NS.KOS.menuPlayerName] then
        NS.KOS.RemovePlayer(NS.KOS.menuPlayerName)
        NS.PrintAddonMessage(
        "|TInterface/Addons/weizPVP/Media/Icons/kos.tga:0|t |cff8fdaffRemoved|r |cff666666:|r " ..
            printedName .. " |cffbbbbbb-|r " .. printedRealm
        )
    elseif NS.KOS.menuPlayerName then
        NS.KOS.AddPlayer(NS.KOS.menuPlayerName)
        NS.PrintAddonMessage(
        "|TInterface/Addons/weizPVP/Media/Icons/kos.tga:0|t |cff8fdaffAdded|r |cff666666:|r " ..
            printedName .. " |cffbbbbbb-|r " .. printedRealm
        )
    end
    IsPlayerTarget()
end

--> Set Menu Text <--------------------------------------------------
function NS.KOS.SetMenuText(playerName)
    return NS.KosList[playerName] and
        "|TInterface/Addons/weizPVP/Addons/KOS/Media/kos_icon_remove.tga:0|t |cff8fdaffRemove from|r |cffff0037KOS|r" or
        "|TInterface/Addons/weizPVP/Addons/KOS/Media/kos_icon_add.tga:0|t |cff8fdaffAdd to|r |cffff0037KOS|r"
end

--> Clear Stored List <----------------------------------------------
function NS.KOS.ClearStoredList()
    wipe(NS.KosList)
end

--> Enable <---------------------------------------------------------
function NS.KOS.Enable()
    IsPlayerTarget()
end

--> Disable <--------------------------------------------------------
function NS.KOS.Disable()
    IsPlayerTarget()
end

--> AddPlayer <------------------------------------------------------
function NS.KOS.AddPlayer(playerName)
    if not playerName then
        return
    end
    -- Add player to KOS list and refresh the core player list
    NS.KosList[playerName] = true
    NS.SortNearbyList()
    NS.RefreshCurrentList()
    -- Refresh Crosshair is targeting the added player
    if (NS.GetFullNameOfUnit("target") == playerName) and NS.Options.Crosshair.Enabled then
        NS.Crosshair.Reset()
        NS.Crosshair.NewTarget()
    end
end

--> RemovePlayer <---------------------------------------------------
function NS.KOS.RemovePlayer(playerName)
    -- Remove from KOS list and refresh list
    NS.KosList[playerName] = nil
    NS.SortNearbyList()
    NS.RefreshCurrentList()
    -- Refresh Crosshair is targeting the added player
    if (NS.GetFullNameOfUnit("target") == playerName) and NS.Options.Crosshair.Enabled then
        NS.Crosshair.Reset()
        NS.Crosshair.NewTarget()
    end
end

--> Migrate character list to global KOS list
function NS.KOS.MigrateKosList()
    -- has old KOS?
    if (NS.oldKosList) then
        -- global not created?
        if (not NS.KosList) then
           -- initialize
           NS.KosList = {}
        end

        -- process all local KOS
        for k,v in pairs(NS.oldKosList) do
            -- not global KOS already?
            if (not NS.KosList[k]) then
                -- add player to global KOS list
                NS.KosList[k] = true

                -- remove player from local KOS list
                NS.oldKosList[k] = nil
            end
        end
        NS.charDB.profile.KosList = nil
        NS.oldKosList = nil
    end
end

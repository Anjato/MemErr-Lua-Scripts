local API = require("api")
local OUTILS = require("offline_utils")
local OAREAS = require("offline_areas")


-------------------------------------------------------------------------------------------------------------------
local startTime = os.time()
local startXp = API.GetSkillXP("MINING")
local numOres, final = 0, 0
local isBanking = true

-- Rounds a number to the nearest integer or to a specified number of decimal places.
local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

-- Format a number with commas as thousands separator
local function formatNumberWithCommas(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

-- Format script elapsed time to [hh:mm:ss]
local function formatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function printProgressReport(final)
    local currentXp = API.GetSkillXP("MINING")
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp);
    local xpPH = round((diffXp * 60) / elapsedMinutes);
    local orePH = round((numOres * 60) / elapsedMinutes);
    local time = formatElapsedTime(startTime)
    IG.string_value = "Mining XP : " .. formatNumberWithCommas(diffXp) .. " (" .. formatNumberWithCommas(xpPH) .. ")"
    IG2.string_value = "   Ore : " .. formatNumberWithCommas(numOres) .. " (" .. formatNumberWithCommas(orePH) .. ")"
    IG4.string_value = time
    if final then
        print(os.date("%H:%M:%S") .. " Script Finished\nRuntime : " .. time .. "\nMining XP : " .. formatNumberWithCommas(diffXp) .. " \nOre : " .. formatNumberWithCommas(numOres))
    end
end

local function setupGUI()
    IG = API.CreateIG_answer()
    IG.box_start = FFPOINT.new(15, 40, 0)
    IG.box_name = "MINE"
    IG.colour = ImColor.new(255, 255, 255);
    IG.string_value = "Mining XP : 0 (0)"

    IG2 = API.CreateIG_answer()
    IG2.box_start = FFPOINT.new(15, 55, 0)
    IG2.box_name = "STRING"
    IG2.colour = ImColor.new(255, 255, 255);
    IG2.string_value = "  Ore : 0 (0)"

    IG3 = API.CreateIG_answer()
    IG3.box_start = FFPOINT.new(40, 5, 0)
    IG3.box_name = "TITLE"
    IG3.colour = ImColor.new(0, 255, 0);
    IG3.string_value = "- Offline's Miner v0.1 -"

    IG4 = API.CreateIG_answer()
    IG4.box_start = FFPOINT.new(70, 21, 0)
    IG4.box_name = "TIME"
    IG4.colour = ImColor.new(255, 255, 255);
    IG4.string_value = "[00:00:00]"

    IG_Back = API.CreateIG_answer();
    IG_Back.box_name = "back";
    IG_Back.box_start = FFPOINT.new(0, 0, 0)
    IG_Back.box_size = FFPOINT.new(220, 80, 0)
    IG_Back.colour = ImColor.new(15, 13, 18, 255)
    IG_Back.string_value = ""
end

local function drawGUI()
    API.DrawSquareFilled(IG_Back)
    API.DrawTextAt(IG)
    API.DrawTextAt(IG2)
    API.DrawTextAt(IG3)
    API.DrawTextAt(IG4)
end

setupGUI()
-------------------------------------------------------------------------------------------------------------------



local oreIds = {
    clay = 434,
    copper = 436,
    tin = 438,
    iron = 440,
    gold = 444,
    mithril = 447,
    adamantite = 449,
    runite = 451,
    coal = 453,
    orichalcite = 44822,
    necrite = 44826
}
local oreBox = {
    bronzeBox = 44779,
    ironBox = 44781,
    steelBox = 44783,
    mithrilBox = 44785,
    adamantBox = 44787,
    runeBox = 44789,
    orikalkumBox = 44791,
    necroniumBox = 44793,
    baneBox = 44795,
    elderRuneBox = 44797
}
local oreTiles = {
    se_lumbridge_swamp = {
        clay = {113152,113154},
        tin = {113149,113150,113151},
        copper = {113146,113147,113148}
    },
    sw_lumbridge_swamp = {
        iron = {113099,113100},
        coal = {113101,113103}
    },
    se_varrock = {
        tin = {113031},
        copper = {113026,113027},
        mithril = {113050,113051,113052},
        adamantite = {113053,113055}
    },
    sw_varrock = {
        tin = {113029,113031},
        copper = {113026,113027,113028},
        iron = {113038,113039,113040},
        mithril = {113050,113051,113052}
    },
    ne_yanille = {

    },
    mining_guild = {
        coal = {113041,113042,113043},
        runite = {113065,113066,113067},
        orichalcite = {113069,113070}
    },
    uzer_mine = {

    },
    n_fremmenik = {

    },
    prifddinas = {

    }
}



local highlightedRockIds = {7164, 7165}
local selectedOreId = nil
local selectedOreTiles = {}
local player = API.GetLocalPlayerName()
local playerCoords = API.PlayerCoordfloat()


local Cselect = API.ScriptDialogWindow2("Area Selection", {
    "SE Lumbridge Swamp", "SW Lumbridge Swamp", "SE Varrock", "SW Varrock", "NE Yanille",
     "Mining Guild", "Uzer Mine", "N Fremmenik", "Prifddinas"}, "Select", "Close").Name;

local areaKey = Cselect:lower():gsub(" ", "_")
print(areaKey)
if oreTiles[areaKey] then
    local oreOptions = {}
    for oreType in pairs(oreTiles[areaKey]) do
        table.insert(oreOptions, oreType:sub(1, 1):upper() .. oreType:sub(2))
    end
     
    Cselect2 = API.ScriptDialogWindow2("Ore Selection", oreOptions, "Start", "Close").Name
    local oreKey = Cselect2:lower()
    print(oreKey)
    selectedOreId = oreIds[oreKey]
    if oreTiles[areaKey][oreKey] then
        selectedOreTiles = oreTiles[areaKey][oreKey]
    end
end


print("Starting offline's miner! :)")


local function isInventoryFull()
    if (API.GetLocalPlayerAddress() == 0) then
        API.Write_LoopyLoop(false)
    end
    if (API.Invfreecount_() == 0) then
        return true;
    else
        return false;
    end
end


local function getAmountInOrebox(itemId)
    local count
    if itemId == 436 then       -- Copper ore
        count = API.VB_FindPSett(8309).state
    elseif itemId == 438 then   -- Tin ore
        count = API.VB_FindPSett(8310).state
    elseif itemId == 440 then   -- Iron ore
        count = API.VB_FindPSett(8311).state
    elseif itemId == 442 then   -- Silver ore
        count = API.VB_FindPSett(8313).state
    elseif itemId == 444 then   -- Gold ore
        count = API.VB_FindPSett(8317).state
    elseif itemId == 447 then   -- Mithril ore
        count = API.VB_FindPSett(8314).state
    elseif itemId == 449 then   -- Adamantite ore
        count = API.VB_FindPSett(8315).state
    elseif itemId == 451 then   -- Runite ore
        count = API.VB_FindPSett(8318).state
    elseif itemId == 453 then   -- Coal
        count = API.VB_FindPSett(8312).state
    elseif itemId == 21778 then -- Banite ore
        count = API.VB_FindPSett(8323).state
    elseif itemId == 44820 then -- Luminite
        count = API.VB_FindPSett(8316).state
    elseif itemId == 44822 then -- Orichalcite ore
        count = API.VB_FindPSett(8319).state
    elseif itemId == 44824 then -- Drakolith
        count = API.VB_FindPSett(8320).state
    elseif itemId == 44826 then -- Necrite ore
        count = API.VB_FindPSett(8321).state
    elseif itemId == 44828 then -- Phasmatite
        count = API.VB_FindPSett(8322).state
    elseif itemId == 44830 then -- Light animica
        count = API.VB_FindPSett(8324).state
    elseif itemId == 44832 then -- Dark animica
        count = API.VB_FindPSett(8325).state
    else
        return -1
    end
    return count >> 0 & 0x3fff
end


local function invOreBoxId()
    for _, id in pairs(oreBox) do
        if (API.InvItemFound1(id)) then
            return id
        end
    end
    return 0
end


local function isOreBoxFilled()
    if (getAmountInOrebox(selectedOreId) > 0) then
        return true
    else
        return false
    end
end


local function isPlayerMining()
    if (API.GetLocalPlayerAddress() == 0) then
        API.Write_LoopyLoop(false)
    end
    if (API.GetPlayerAnimation_(player) == 32566) then
        return true;
    else
        return false;
    end
end


local function MineOre(closestOreTile)
    if (API.GetLocalPlayerAddress() == 0) then
        API.Write_LoopyLoop(false)
    end
    API.DoAction_Object2(0x3a, 0, { closestOreTile.Id }, 50, closestOreTile.Coords)
end

local currentItemcount, previousItemCount = API.InvItemcount_1(selectedOreId), API.InvItemcount_1(selectedOreId)


local function DoGuiThings()
    drawGUI()
    currentItemcount = API.InvItemcount_1(selectedOreId)
    if currentItemcount > previousItemCount then
        numOres = numOres + (currentItemcount - previousItemCount)
    end
    --update the previous count
    previousItemCount = currentItemcount
    printProgressReport()
end


local function BankOre()

    if (API.PInAreaW(OAREAS.areas.mining.mining_guild.GUILD,50)) then
        --go up ladder
        API.DoAction_Object2(0x34,0,{ 6226 },50,WPOINT.new(3020,9739,0))

        while(API.PInAreaW(OAREAS.areas.mining.mining_guild.GUILD,50)) do
            API.RandomSleep2(50, 50, 50)
        end

        API.RandomSleep2(2300, 2200, 2000)
    end

    if (API.PInAreaW(OAREAS.areas.mining.mining_guild.BANK,50)) then
        --open bank interface
        API.DoAction_Object2(0x5, 80, { 11758 }, 50, WPOINT.new(3013,3354,0))
        API.RandomSleep(600, 700, 1000)

        while (not API.BankOpen2()) do
            API.RandomSleep2(50, 50, 50)
        end
        API.RandomSleep2(200, 150, 150)
        --deposit rune ore from inventory
        API.DoAction_Interface(0xffffffff,selectedOreId,7,517,15,2,6112)
        API.RandomSleep2(300, 200, 250)
        if (invOreBoxId() > 0) then
            --deposit rune ore from ore box
            API.DoAction_Interface(0xffffffff,invOreBoxId(),8,517,15,0,6112)
            API.RandomSleep2(200, 100, 250)
            --deposit stone spirits from ore box
            API.DoAction_Interface(0xffffffff,invOreBoxId(),9,517,15,0,6112)
        end

        --go down ladder
        API.DoAction_Object2(0x35,0,{ 2113 },50,WPOINT.new(3020,3339,0))
        --wait for player to stop moving
        while (API.PInAreaW(OAREAS.areas.mining.mining_guild.BANK,50)) do
            API.RandomSleep(50, 50, 50)
        end

        API.RandomSleep2(2200, 2500, 2300)
    end

end


local function HandleInventory()
    if (isBanking) then
        print("Inventory is full! Banking ore")
        BankOre()
    else
        print("Inventory is full! Dropping inventory")
        OUTILS.DropInventory()
    end
end


--pre-main loop check
if (API.Invfreecount_() == 0) then
    if (API.GetLocalPlayerAddress() == 0) then
        print("Player not logged in! Ending script")
        API.Write_LoopyLoop(false)
    end
    if (getAmountInOrebox(selectedOreId) == 100 or getAmountInOrebox(selectedOreId) == 120 or getAmountInOrebox(selectedOreId) == 140) then
        HandleInventory()
    else
        API.DoAction_Interface(0x24,invOreBoxId(),1,1473,5,0,5392)
    end
end

if(API.PInAreaW(OAREAS.areas.mining.mining_guild.BANK,50)) then
    --go down ladder
    API.DoAction_Object2(0x35,0,{ 2113 },50,WPOINT.new(3020,3339,0))
    --wait for player to stop moving
    while (API.IsPlayerMoving_() or API.PInAreaW(OAREAS.areas.mining.mining_guild.BANK,50)) do
        API.RandomSleep2(50, 50, 100)
    end
    API.RandomSleep2(2000, 2500, 2250)
end

---main loop
while (API.Read_LoopyLoop() and API.GetLocalPlayerAddress() ~= 0)
do
    DoGuiThings()

    local tileToMine = OUTILS.GetClosestObject(selectedOreTiles)

    OUTILS.IdleCheck()

    ---if inventory is full, drop EVERYTHING
    if (isInventoryFull()) then
        --can assume box is full at 100, 120, or 140
        if (getAmountInOrebox(selectedOreId) == 100 or getAmountInOrebox(selectedOreId) == 120 or getAmountInOrebox(selectedOreId) == 140) then
            HandleInventory()
        else
            --fill ore box
            API.DoAction_Interface(0x24,invOreBoxId(),1,1473,5,0,5392)
            API.RandomSleep2(1300, 1500, 1200)
        end
    end

    if (not isPlayerMining() and not isInventoryFull()) then
        MineOre(tileToMine)
        API.RandomSleep2(3500, 400, 200)
    end

    while (isPlayerMining() and API.Read_LoopyLoop()) do
        print("Player is mining. Monitoring for highlighted rock and stamina")
        repeat
            local highlightedRock = OUTILS.GetHighlightedObject(highlightedRockIds, selectedOreTiles)
            DoGuiThings()

            if (highlightedRock ~= nil and highlightedRock.Id > 0) then
                MineOre(highlightedRock)

                DoGuiThings()

                API.RandomSleep2(2500, 300, 100)

                tileToMine = highlightedRock
            end

            --will randomly return 0 for no reason so this takes care of it wihtout clicking too often
            if (API.LocalPlayer_HoverProgress() < 100 and API.LocalPlayer_HoverProgress() > 0) then
                MineOre(tileToMine)
                DoGuiThings()
                API.RandomSleep2(800, 200, 200)
            end

        until not isPlayerMining()
    end
end

final = true
printProgressReport(final)
local API = require("api")
local OUTILS = require("offline_utils")


-------------------------------------------------------------------------------------------------------------------
local startTime = os.time()
local startXp = API.GetSkillXP("MINING")
local numOres, final = 0, 0


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

function drawGUI()
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
local ore_box = {
    bronze_box = 44779,
    iron_box = 44781,
    steel_box = 44783,
    mithril_box = 44785,
    adamant_box = 44787,
    rune_box = 44789,
    orikalkum_box = 44791,
    necronium_box = 44793,
    bane_box = 44795,
    elder_rune_box = 44797
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


function IsInventoryFull()
    if (API.GetLocalPlayerAddress() == 0) then
        API.Write_LoopyLoop(false)
    end
    if (API.Invfreecount_() == 0) then
        return true;
    else
        return false;
    end
end


function IsPlayerMining()
    if (API.GetLocalPlayerAddress() == 0) then
        API.Write_LoopyLoop(false)
    end
    if (API.GetPlayerAnimation_(player) == 32566) then
        return true;
    else
        return false;
    end
end


function MineOre(closestOreTile)
    if (API.GetLocalPlayerAddress() == 0) then
        API.Write_LoopyLoop(false)
    end
    API.DoAction_Object2(0x3a, 0, { closestOreTile.Id }, 50, closestOreTile.Coords)
end

local currentItemcount, previousItemCount = API.InvItemcount_1(selectedOreId), API.InvItemcount_1(selectedOreId)


function DoGuiThings()
    drawGUI()
    currentItemcount = API.InvItemcount_1(selectedOreId)
    if currentItemcount > previousItemCount then
        numOres = numOres + (currentItemcount - previousItemCount)
    end
    previousItemCount = currentItemcount  -- Update the previous count
    printProgressReport()
end





--pre-main loop check
if (API.Invfreecount_() < 4) then
    if (API.GetLocalPlayerAddress() == 0) then
        print("Player not logged in! Ending script")
        API.Write_LoopyLoop(false)
    end
    print("Inventory has very few free spaces. Dropping inventory")
    OUTILS.DropInventory()
end

---main loop
while (API.Read_LoopyLoop() and API.GetLocalPlayerAddress() ~= 0)
do
    DoGuiThings()

    local tileToMine = OUTILS.GetClosestObject(selectedOreTiles)

    OUTILS.IdleCheck()

    ---if inventory is full, drop EVERYTHING
    if (IsInventoryFull()) then
        print("Inventory full! Dropping inventory")
        OUTILS.DropInventory()
    end

    if (not IsPlayerMining() and not IsInventoryFull()) then
        MineOre(tileToMine)
        API.RandomSleep2(3500, 400, 200)
    end

    while (IsPlayerMining() and API.Read_LoopyLoop()) do
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

        until not IsPlayerMining()
    end
end

final = true
printProgressReport(final)
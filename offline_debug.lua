local API = require("api")
local OUTILS = require("offline_utils")
local OMENU = require("offline_menu")


print("Starting offline's debugger...")

local startTime = os.time()
local startXp = API.GetSkillXP("MINING")
local ores = 0
local previousItemCount = API.InvItemcount_1(436)


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
    local orePH = round((ores * 60) / elapsedMinutes);
    local time = formatElapsedTime(startTime)
    IG.string_value = "     Mining XP : " .. formatNumberWithCommas(diffXp) .. " (" .. formatNumberWithCommas(xpPH) .. ")"
    IG2.string_value = "        Ore : " .. formatNumberWithCommas(ores) .. " (" .. formatNumberWithCommas(orePH) .. ")"
    IG4.string_value = time
    if final then
        print(os.date("%H:%M:%S") .. " Script Finished\nRuntime : " .. time .. "\nMining XP : " .. formatNumberWithCommas(diffXp) .. " \nOre : " .. formatNumberWithCommas(ores))
    end
end

local function setupGUI()
    IG = API.CreateIG_answer()
    IG.box_start = FFPOINT.new(15, 40, 0)
    IG.box_name = "MINE"
    IG.colour = ImColor.new(255, 255, 255);
    IG.string_value = "     Mining XP : 0 (0)"

    IG2 = API.CreateIG_answer()
    IG2.box_start = FFPOINT.new(15, 55, 0)
    IG2.box_name = "STRING"
    IG2.colour = ImColor.new(255, 255, 255);
    IG2.string_value = "        Ore : 0 (0)"

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

---main loop
while(API.Read_LoopyLoop())
do
    drawGUI()
    local currentItemcount = API.InvItemcount_1(436)

    if currentItemcount > previousItemCount then
        ores = ores + (currentItemcount - previousItemCount)
    end
    previousItemCount = currentItemcount  -- Update the previous count

    ---print(API.print_GetABarInfo(1))
    --if (API.Invfreecount_() < 28) then
    --    GetInventoryItems()
    --    DropInventory(inventory_items)
    --end
    --print(API.LocalPlayer_HoverProgress())

    --print(OUTILS.GetClosestObject({113147,113146,113148}))
    --print(OUTILS.GetHighlightedObject({7164, 7165},{113147,113146,113148}))
    --print(API.LocalPlayer_HoverProgress())
    printProgressReport()
    API.RandomSleep2(250, 300, 500)
end
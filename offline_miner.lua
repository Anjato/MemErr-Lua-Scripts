local API = require("api")
local OUTILS = require("offline_utils")

--local ore_ids = {}
local copper_id = 436
local tin_id = 438

local ore_tiles = {}
local clay_tiles = {}
local copper_tiles = {113146,113147,113148}
local tin_tiles = {113149,113151,113150}
local player = API.GetLocalPlayerName()

local highlighted_rocks = {7164, 7165}


local Cselect = API.ScriptDialogWindow2("Ore Selection", {
    "Copper", "Tin", "All"},"Start", "Close").Name;

local function MergeTables(dest, ...)
    for key, src in ipairs({...}) do
        for key, value in ipairs(src) do
            table.insert(dest, value)
        end
    end
end

if Cselect == "Copper" then ore_tiles = copper_tiles
elseif Cselect == "Tin" then ore_tiles = tin_tiles
elseif Cselect == "Clay" then ore_tiles = clay_tiles
elseif Cselect == "All" then MergeTables(ore_tiles, clay_tiles, tin_tiles, copper_tiles)
end


print("Starting offline's lumbridge miner! :)")


function IsInventoryFull()
    if (API.GetLocalPlayerAddress() == 0) then
        API.Write_LoopyLoop(false)
    end
    if (API.Invfreecount_() <= 1) then
        return true;
    else
        return false;
    end
end


function IsPlayerMining()
    if (API.GetLocalPlayerAddress() == 0) then
        API.Write_LoopyLoop(false)
    end
    if (API.GetPlayerAnimation_(player) == 32540) then
        return true;
    else
        return false;
    end
end


function MineOre(closestOreTile)
    if (API.GetLocalPlayerAddress() == 0) then
        API.Write_LoopyLoop(false)
    end
    API.DoAction_Object1(0x3a,0,{ closestOreTile },50)
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
    local tileToMine = OUTILS.GetClosestObject(ore_tiles)

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

    while (IsPlayerMining()) do
        print("Player is mining. Monitoring for highlighted rock and stamina")
        repeat
            
            local highlighted_rock = OUTILS.GetHighlightedObject(highlighted_rocks, ore_tiles)

            if (highlighted_rock ~= nil and highlighted_rock > 0) then
                print("Clicking on rockertunity!")
                MineOre(highlighted_rock)
                API.RandomSleep2(2500, 300, 100)
                tileToMine = OUTILS.GetClosestObject(ore_tiles)
            end
            --will randomly return 0 for no reason so this takes care of it wihtout clicking too often
            if (API.LocalPlayer_HoverProgress() < 100 and API.LocalPlayer_HoverProgress() > 0) then
                MineOre(tileToMine)
                API.RandomSleep2(600, 200, 200)
            end
        until not IsPlayerMining()
    end
end
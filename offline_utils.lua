local OUTILS = {}

local API = require("api")

local afk = os.time()
local MAX_IDLE_TIME_MINUTES = 10


function OUTILS.IdleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if (timeDiff > randomTime) then
        API.PIdle2()
        afk = os.time()
    end
end


function OUTILS.IsInArray(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end


function OUTILS.GetHighlightedObject(target_highlight_ids, target_object_ids)
    local objects = API.ReadAllObjectsArray()
    local hlobjects = API.ReadAllObjectsArray(true, 4)

    local closestDistance = nil
    local closestHighlightedObject = nil
    local highlightedObject = nil

    for _, hlobject in pairs(hlobjects) do
        if OUTILS.IsInArray(target_highlight_ids, hlobject.Id) then
            for _, object in pairs(objects) do
                if OUTILS.IsInArray(target_object_ids, object.Id) then
                    local distance = API.Math_DistanceF(hlobject.Tile_XYZ, object.Tile_XYZ)
                    if (closestDistance == nil or distance < closestDistance) and distance < 1 then
                        closestDistance = distance
                        closestHighlightedObject = hlobject.Id
                        highlightedObject = object.Id
                    end
                end
            end
        end
    end
    if (highlightedObject) then
        return highlightedObject
    end
end


function OUTILS.GetClosestObject(target_ids)

    local all_objects = API.ReadAllObjectsArray()
    local minDistance = nil
    local closestObject = nil

    for _, object in pairs(all_objects) do
        if OUTILS.IsInArray(target_ids, object.Id) then
            local distance = API.Math_DistanceF(API.PlayerCoordfloat(), object.Tile_XYZ)
            if minDistance == nil or distance < minDistance then
                minDistance = distance
                closestObject = object.Id
            end
        end
    end
    return closestObject
end


function OUTILS.DropInventory()
    local i = 0
    for _, item in ipairs(API.ReadInvArrays33()) do
        if (item.itemid1 > 0) then
            API.DoAction_Interface(0x24,item.itemid1,8,1473,5,i,6112)
            i = i + 1
            API.RandomSleep2(10, 50, 80)
        end
    end
    API.RandomSleep2(600, 100, 50)
end

return OUTILS
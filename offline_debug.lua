local API = require("api")
local OUTILS = require("offline_utils")


print("Starting offline's debugger...")


---main loop
while(API.Read_LoopyLoop())
do
    
    API.RandomSleep2(250, 300, 500)
end
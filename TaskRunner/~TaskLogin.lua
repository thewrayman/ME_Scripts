local API = require("api")
local attempts = 0

TASK = {}

local function clickPlayNow()
    API.logDebug("Attempting to enter world")
    API.DoAction_Interface(0xffffffff,0xffffffff,1,906,76,-1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(6000,2000,4000)
    attempts = attempts + 1
end

--- This is getting called by the while loop of ~TaskRunner.lua, so you can treat this run function as your traditional while loop
function TASK.run()
    if attempts > 3 then
        TASK.COMPLETE = true
        API.logError("Failed to enter game after more than 3 attempts - giving up.")
        API.Write_LoopyLoop(false)
    end

    if API.GetGameState2() == 2 then
        clickPlayNow()
    elseif API.GetGameState2() == 3 then
        TASK.COMPLETE = true
        API.logInfo("Successfully entered game!")
        return true
    else
        API.logError("Not in lobby or in world - exiting")
        API.Write_LoopyLoop(false)
    end
end

return TASK
local API = require("api")
TASK = {}

function TASK.run()
    API.RandomSleep2(2000,200,200)
    if GrandExchange:IsAtGE() then
        TASK.COMPLETE = true
        API.logDebug("Already at GE - finished")
        return
    else
        API.logError("Not in GE")
        TASK.COMPLETE = true
        return
    end
    
end

return TASK
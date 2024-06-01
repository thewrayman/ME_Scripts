local API = require("api")
TASK = {}
TASK.LODESTONES = require("lodestones")

function TASK.setFocus(lode)
    TASK.FOCUS = lode
end


function TASK.run()
    if TASK.FOCUS ~= nil then
        API.logInfo("Found a focus teleport, attempting to lodestone..")
        TASK.FOCUS()
        TASK.COMPLETE = true
    else
        API.logError("No lodestone focus found, exiting")
        API.Write_LoopyLoop(false)
    end
end

return TASK
local API = require("api")
local CURRENT_TASK = nil
API.SetDrawTrackedSkills(true)
API.SetMaxIdleTime(5)
API.SetDrawLogs(true)

local function drawGUI()
    -- maybe throw some task status stuff here
end

TASKS = {
    {SCRIPT = "~TaskLogin", RUNTIME = 60}, -- this would be a file called "~TaskLogin.lua", which would auto-kill if it takes more than 60 seconds to finish
    {SCRIPT = "~TaskTest2", RUNTIME = 60}, -- this would be a file called "~Task2.lua"
}

local function getTaskToRun()
    return TASKS[1]
end

local function taskRunTime()
    return os.time() - CURRENT_TASK.START
end

local function setTask()
    API.logDebug("Loading task " .. getTaskToRun().SCRIPT)
    CURRENT_TASK = require(getTaskToRun().SCRIPT)
    CURRENT_TASK.START = os.time()
    CURRENT_TASK.COMPLETE = false
end

local function finishTask()
    API.logInfo("Finished Task " .. TASKS[1].SCRIPT)
    table.remove(TASKS, 1)
    if #TASKS > 0  then
        API.logInfo("Next Task: " .. TASKS[1].SCRIPT)
        setTask()
    else
        API.logInfo("All Tasks Complete!")
    end
end

setTask()

--- This while loop will take the place of the while loop in your scripts that this will use.
--- Instead of your scripts using while API.Read_LoopyLoop... etc, they will have that replaced with TASK.run()
while API.Read_LoopyLoop() and (#TASKS > 0) do
    API.DoRandomEvents()
    drawGUI()

    if CURRENT_TASK.COMPLETE or (taskRunTime() > getTaskToRun().RUNTIME)then
        finishTask()
    else
        CURRENT_TASK.run() -- this is basically the equivalent of the main loop
    end
end
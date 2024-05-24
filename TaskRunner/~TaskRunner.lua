local API = require("api")
local CURRENT_TASK = nil
API.SetDrawTrackedSkills(true)
API.SetMaxIdleTime(5)
API.SetDrawLogs(true)

local function drawGUI()
    -- maybe throw some task status stuff here
end

local exampleOverrideData = {
    {NAME = "Powder of burials", ID = 52805, VOL = 1, PRICE = 400000},
    {NAME = "Dinosaur bones", ID = 48075, VOL = 1, PRICE = 50000}
}

-- EXAMPLE TASKS
-- will use the BuyItems script twice, but with two different sets of data to focus on (one set stored in the BuyItems script itself, another dataset I'm passing in from above)
TASKS = {
    {SCRIPT = "~TaskLogin", RUNTIME = 60}, -- this would be a file called "~TaskLogin.lua", which would auto-kill if it takes more than 60 seconds to finish, if in lobby, logs in, exits when in-world
    {SCRIPT = "~TaskTest2", RUNTIME = 60}, -- dummy task which just checks if in GE
    {SCRIPT = "~Task_BuyItems", RUNTIME = 600, FOCUS = "prayer"}, -- runs ~BuyItems.lua file, will time out after 10 mins if not already ended, uses optional FOCUS param to let you choose specific features for that execution
    {SCRIPT = "~Task_BuyItems", RUNTIME = 600, FOCUS = exampleOverrideData} -- FOCUS can be overriden with a specified table if the target task script doesn't contain it already
}

local function taskRunTime()
    return os.time() - CURRENT_TASK.START
end

local function setTask()
    API.logDebug("Loading task " .. TASKS[1].SCRIPT)
    CURRENT_TASK = require(TASKS[1].SCRIPT)
    CURRENT_TASK.START = os.time()
    CURRENT_TASK.COMPLETE = false

    -- optional FOCUS param if wanting to parameterize data being used in that execution of that task
    if (TASKS[1].FOCUS ~= nil) then
        if  (type(TASKS[1].FOCUS) == "string") then
            CURRENT_TASK.setFocus(TASKS[1].FOCUS)
        elseif (type(TASKS[1].FOCUS) == "table") then
            CURRENT_TASK.FOCUS = TASKS[1].FOCUS
        end
    end
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

--initialise first task to run
setTask()

--- This while loop will take the place of the while loop in your scripts that this will use.
--- Instead of your scripts using while API.Read_LoopyLoop... etc, they will have that replaced with TASK.run()
while API.Read_LoopyLoop() and (#TASKS > 0) do
    API.DoRandomEvents()
    drawGUI()

    --has the task set itself as complete or has it reached max time?
    if CURRENT_TASK.COMPLETE or (taskRunTime() > TASKS[1].RUNTIME)then
        finishTask()
    else
        CURRENT_TASK.run() -- this is basically the equivalent of the main loop
    end
end
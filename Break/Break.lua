--[[
Author: Tinie
Inital Release Date: 18th June 2024
Last Update Date: 18th June 2024
Version 2.0.0
Credit to @dea.d for some of the GUI inspiration

--Release Notes
* 2.0.0
    Major changes
        Moving to dedicated break file
        Added GUI for info + ad-hoc break changes
        Exposed some more things to the BREAK object

]]

local API = require("api")
BREAK = {}

function BREAK.clickLobbyButton()
    API.DoAction_Interface(0xffffffff,0xffffffff,1,906,76,-1,API.OFF_ACT_GeneralInterface_route)
end

-- default settings, if you don't override these with your script, then it will use these
BREAK.BREAK_SETTINGS = {
    TOTAL_RUNTIME_MAX = 10800, -- this will get overriden by the hours dropdown, so this doesn't matter too much
    MIN_SESSION_TIME = 3200, -- minimum amount of time to make each session last before taking a break
    MAX_SESSION_TIME = 3600, -- maximum amount of time to make each session last before taking a break
    BUFFER_TIME = 120, --this will account for time different between the step you want to take a break at - e.g if you want to take a break after banking, and you bank every 20 seconds, the buffer should be > 20
    MIN_BREAK_TIME = 300, -- minimum amount of time the break should last
    MAX_BREAK_TIME = 600 -- maximum amount of time the break should last
}

BREAKS = {}

-- this just maintains various variables for monitoring status'
BREAK.BREAK_STATUS = {
    ON_BREAK = false,
    BREAK_START = 0,
    SESSION_START = 0,
    BREAK_ELAPSED = 0,
    SESSION_ELAPSED = 0
}

local maxSeconds = 0

-- define constants for GUI drawing. You can chang the location of the GUI by updating box_x and box_y
local box_x = 16
local box_y = 50
local column_offset = box_x + 2
local row_offset = box_y + 10
local row_height = 30
local column_width = 60

--definition for 4 columns in the GUI
COLUMNS = {
    column_offset,
    column_offset + column_width,
    column_offset + (2*column_width),
    column_offset + (3*column_width)
}

--definition for 4 rows in the GUI
ROWS = {
    row_offset,
    row_offset + row_height,
    row_offset + (2*row_height),
    row_offset + (3*row_height),
}


local imguiBackground = API.CreateIG_answer()
imguiBackground.box_name = "imguiBackground"
imguiBackground.box_start = FFPOINT.new(box_x, box_y, 0)
imguiBackground.box_size = FFPOINT.new(300, 250, 0)
imguiBackground.colour = ImColor.new(10, 13, 29)

---- ROW 1 ----
local imguiStart = API.CreateIG_answer()
imguiStart.box_name = "Start"
imguiStart.box_start = FFPOINT.new(COLUMNS[1], ROWS[1], 0)
imguiStart.box_size = FFPOINT.new(column_width, row_height, 0)
imguiStart.tooltip_text = "Start Script"

local imguiTerminate = API.CreateIG_answer()
imguiTerminate.box_name = "Stop"
imguiTerminate.box_start = FFPOINT.new(COLUMNS[2], ROWS[1], 0)
imguiTerminate.box_size = FFPOINT.new(column_width, row_height, 0)
imguiTerminate.tooltip_text = "Exit the script"

local updateMaxRuntime = API.CreateIG_answer()
updateMaxRuntime.box_name = "Update"
updateMaxRuntime.box_start = FFPOINT.new(COLUMNS[3], ROWS[1], 0)
updateMaxRuntime.box_size = FFPOINT.new(column_width, row_height, 0)
updateMaxRuntime.tooltip_text = "Update the max runtime"

local dropdownLabel = API.CreateIG_answer()
dropdownLabel.box_name = "Hours"
dropdownLabel.box_start = FFPOINT.new(COLUMNS[4], ROWS[1], 0)
dropdownLabel.box_size = FFPOINT.new(column_width, row_height, 0)
dropdownLabel.tooltip_text = "Hours to run script for"

---- ROW 2 ----
local tteLabel = API.CreateIG_answer()
tteLabel.box_name = "TTE"
tteLabel.box_start = FFPOINT.new(COLUMNS[1], ROWS[2], 0)
tteLabel.box_size = FFPOINT.new(column_width, row_height, 0)
tteLabel.tooltip_text = "Time until completion"

local imguiTimeTillScriptEnd = API.CreateIG_answer()
imguiTimeTillScriptEnd.box_name = "TTE:"
imguiTimeTillScriptEnd.box_start = FFPOINT.new(COLUMNS[2], ROWS[2] + 10, 0)
imguiTimeTillScriptEnd.box_size = FFPOINT.new(2*column_width, row_height, 0)

local hourdata = API.CreateIG_answer()
hourdata.box_name = " "
hourdata.box_start = FFPOINT.new(COLUMNS[4],ROWS[2],0)
hourdata.box_size = FFPOINT.new(2*column_width,row_height,0)
hourdata.stringsArr = {1, 2, 3, 4, 5, 6, 7, 8}

---- ROW 3 ----
local breaksLabel = API.CreateIG_answer()
breaksLabel.box_name = "Breaks Left"
breaksLabel.box_start = FFPOINT.new(COLUMNS[1], ROWS[3], 0)
breaksLabel.box_size = FFPOINT.new(column_width, row_height, 0)
breaksLabel.tooltip_text = "Num of breaks left"

local imguiBreaksLeft = API.CreateIG_answer()
imguiBreaksLeft.box_name = "Breaks"
imguiBreaksLeft.box_start = FFPOINT.new(COLUMNS[2], ROWS[3]+10, 0)
imguiBreaksLeft.box_size = FFPOINT.new(column_width, row_height, 0)

local ttbLabel = API.CreateIG_answer()
ttbLabel.box_name = "TTB"
ttbLabel.box_start = FFPOINT.new(COLUMNS[3], ROWS[3], 0)
ttbLabel.box_size = FFPOINT.new(column_width, row_height, 0)
ttbLabel.tooltip_text = "Time until next break"

local imguiTimeTillNextBreak = API.CreateIG_answer()
imguiTimeTillNextBreak.box_name = "Time To Break"
imguiTimeTillNextBreak.box_start = FFPOINT.new(COLUMNS[4], ROWS[3]+10, 0)
imguiTimeTillNextBreak.box_size = FFPOINT.new(column_width, row_height, 0)

---- ROW 4 ----
local ttbeLabel = API.CreateIG_answer()
ttbeLabel.box_name = "TTBE"
ttbeLabel.box_start = FFPOINT.new(COLUMNS[3], ROWS[4], 0)
ttbeLabel.box_size = FFPOINT.new(column_width, row_height, 0)
ttbeLabel.tooltip_text = "Time till break ends"

local imguiTimeTillBreakEnd = API.CreateIG_answer()
imguiTimeTillBreakEnd.box_name = "Time till break ends"
imguiTimeTillBreakEnd.box_start = FFPOINT.new(COLUMNS[4], ROWS[4]+10, 0)
imguiTimeTillBreakEnd.box_size = FFPOINT.new(column_width, row_height, 0)

local function calculateMaxRuntime(newSeconds)
    API.logInfo("Updating max runtime")
    API.logInfo("Existing max runtime: " .. BREAK.BREAK_SETTINGS.TOTAL_RUNTIME_MAX)
    math.randomseed(os.time())
    BREAK.BREAK_SETTINGS.TOTAL_RUNTIME_MAX = newSeconds * math.random(90, 110)/100
    API.logInfo("New Max Runtime: " .. BREAK.BREAK_SETTINGS.TOTAL_RUNTIME_MAX)
    maxSeconds = BREAK.BREAK_SETTINGS.TOTAL_RUNTIME_MAX
end

BREAK.LOOP = false

local function startScript()
    API.logInfo("Starting Script")
    BREAK.LOOP = true
    imguiStart.box_name = "Pause"

    if maxSeconds == 0 then
        API.logInfo("Initialising max runtime")
        calculateMaxRuntime(tonumber(hourdata.string_value) * 3600)
        BREAK.generateBreaks()
    end
end

local function pauseScript()
    API.logInfo("Pausing Script")
    BREAK.LOOP = false
    imguiStart.box_name = "Start"
end

local function formatTime(t)
    local hours = math.floor(t / 3600)
    local minutes = math.floor((t % 3600) / 60)
    local seconds = t % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function getTotalTimeRemaining()
    local remainingTime = math.floor(BREAK.BREAK_SETTINGS.TOTAL_RUNTIME_MAX - API.ScriptRuntime())
    return formatTime(remainingTime)
end

local function drawGUI()
    imguiBreaksLeft.string_value = tostring(#BREAKS)
    imguiTimeTillScriptEnd.string_value = getTotalTimeRemaining()
    if #BREAKS > 0 then
        imguiTimeTillNextBreak.string_value = formatTime(BREAKS[1].SESSION_TIME - BREAK.BREAK_STATUS.SESSION_ELAPSED)
    else
        imguiTimeTillNextBreak.string_value = "0"
    end
    
    if BREAK.BREAK_STATUS.ON_BREAK then
        imguiTimeTillBreakEnd.string_value = formatTime(BREAKS[1].BREAK_TIME - BREAK.BREAK_STATUS.BREAK_ELAPSED)
    else
        imguiTimeTillBreakEnd.string_value = "0"
    end

    if imguiTerminate.return_click then
        API.logInfo("Terminating Script")
        API.Write_LoopyLoop(false)
    end

    if BREAK.BREAK_STATUS.ON_BREAK then
        -- make green
    else
        -- make red
    end
    if imguiStart.return_click then
        if not BREAK.LOOP then
            startScript()
        end
    else
        if BREAK.LOOP then
            pauseScript()
        end
    end

    if updateMaxRuntime.return_click then
        BREAKS = {}
        calculateMaxRuntime(tonumber(hourdata.string_value) * 3600)
        BREAK.generateBreaks()
        updateMaxRuntime.return_click = false
    end

    API.DrawSquareFilled(imguiBackground)
    API.DrawBox(imguiStart)
    API.DrawBox(imguiTerminate)
    API.DrawBox(updateMaxRuntime)
    API.DrawComboBox(hourdata, false)
    API.DrawTextAt(imguiInBreak)
    API.DrawTextAt(imguiBreaksLeft)
    API.DrawTextAt(imguiTimeTillNextBreak)
    API.DrawTextAt(imguiTimeTillScriptEnd)
    API.DrawTextAt(imguiTimeTillBreakEnd)
    API.DrawBox(dropdownLabel)
    API.DrawBox(tteLabel)
    API.DrawBox(breaksLabel)
    API.DrawBox(ttbLabel)
    API.DrawBox(ttbeLabel)
end

-- this will take  the settings provided (either default or overriden) and generate a list of breaks (how long until next break, how long should that break be)
function BREAK.generateBreaks(breakTable)
    API.logInfo("Generating breaks")
    BREAK.BREAK_SETTINGS = breakTable or BREAK.BREAK_SETTINGS
    local maxBreaks = math.floor(BREAK.BREAK_SETTINGS.TOTAL_RUNTIME_MAX/BREAK.BREAK_SETTINGS.MIN_SESSION_TIME)
    API.logDebug("Max breaks: " .. maxBreaks)
    math.randomseed(os.time())
  
    for i=1, maxBreaks do
        BREAKS[i] = {SESSION_TIME = math.random(BREAK.BREAK_SETTINGS.MIN_SESSION_TIME, BREAK.BREAK_SETTINGS.MAX_SESSION_TIME), BREAK_TIME = math.random(BREAK.BREAK_SETTINGS.MIN_BREAK_TIME, BREAK.BREAK_SETTINGS.MAX_BREAK_TIME)}
        API.logInfo("Generated break config " .. i .. ": " .. "Session duration=" .. BREAKS[i].SESSION_TIME .. ", Break time=" .. BREAKS[i].BREAK_TIME)
    end

    BREAK.BREAK_STATUS.SESSION_START = os.time()
    BREAK.BREAK_STATUS.BREAK_START = os.time()
end

-- to be called in main loop - updates GUI and updates timers for tracking TTB and TTBE
function BREAK.updateBreakTimers()
    drawGUI()

    if not BREAK.BREAK_STATUS.ON_BREAK then
        BREAK.BREAK_STATUS.SESSION_ELAPSED = os.time() - BREAK.BREAK_STATUS.SESSION_START
        --API.logDebug("Updating break status" .. "[" .. tostring(BREAK_STATUS.ON_BREAK) .. "]" .. ": SessionElapsed=".. BREAK_STATUS.SESSION_ELAPSED .. ", Break Elapsed=" .. (BREAK_STATUS.BREAK_ELAPSED or 0))
    else
        BREAK.BREAK_STATUS.BREAK_ELAPSED = os.time() - BREAK.BREAK_STATUS.BREAK_START
        --API.logDebug("Updating break status" .. "[" .. tostring(BREAK_STATUS.ON_BREAK) .. "]" .. ": SessionElapsed=".. (BREAK_STATUS.SESSION_START or 0) .. ", Break Elapsed=" .. (BREAK_STATUS.BREAK_ELAPSED or 0))
    end

end

function BREAK.startBreak()
    if API.GetGameState2() == 3 then
        API.DoAction_Logout_mini()
        API.RandomSleep2(5000,1000,2000)
        API.Compare2874Status(1, true)
        API.DoAction_then_lobby()
        API.RandomSleep2(5000,1000,2000)
        if not API.GetGameState2() ==2 then
            return false
        end
    end
    BREAK.BREAK_STATUS.ON_BREAK = true
    BREAK.BREAK_STATUS.BREAK_ELAPSED = 0
    BREAK.BREAK_STATUS.SESSION_ELAPSED = 0
    BREAK.BREAK_STATUS.BREAK_START = os.time()
    BREAK.BREAK_STATUS.SESSION_START = 0
    return true
end

function BREAK.finishBreak()
    -- login
    --verift logged in
    BREAK.clickLobbyButton()
    API.RandomSleep2(5000,2000,5000)
    if API.GetGameState2() == 3 then
        API.logInfo("Successfully logged back into the game")
        table.remove(BREAKS, 1)
        BREAK.BREAK_STATUS.ON_BREAK = false
        BREAK.BREAK_STATUS.BREAK_ELAPSED = 0
        BREAK.BREAK_STATUS.SESSION_ELAPSED = 0
        BREAK.BREAK_STATUS.BREAK_START = 0
        BREAK.BREAK_STATUS.SESSION_START = os.time()
        return true
    end
end

-- throw this into mainloop checker to validate it's only in lobby when it's in a break
function BREAK.inValidLoop()
    return ((API.GetGameState2() == 3) or ((API.GetGameState2() == 2 or API.GetGameState2() == 4) and BREAK.BREAK_STATUS.ON_BREAK))
end

-- put this check in where you're happy for the script to stop for a break. This will return true if on break, so you can use that logic to skip your script functionality where needed.
function BREAK.checkForBreak()
    if API.ScriptRuntime() > BREAK.BREAK_SETTINGS.TOTAL_RUNTIME_MAX then
        API.Write_LoopyLoop(false)
        API.logInfo("Reached max session time, stopping script")
    end

    if not BREAK.BREAK_STATUS.ON_BREAK then
        if BREAK.BREAK_STATUS.SESSION_ELAPSED >= (BREAKS[1].SESSION_TIME - BREAK.BREAK_SETTINGS.BUFFER_TIME) then
            API.logInfo("Starting break")
            BREAK.startBreak()
            return true
        end
    else
        if BREAK.BREAK_STATUS.BREAK_ELAPSED >= (BREAKS[1].BREAK_TIME) then
            API.logInfo("Ending break, resuming session")
            BREAK.finishBreak()
        else
            return true
        end
    end
    return false
end

function BREAK.pickbreak(breakTable)
    return breakTable[math.random(#breakTable)]
end

return BREAK
### Break Handler

#### What does it do?
* Will take breaks from the current script for a random amount of time (between defined time boundaries)
* Currently goes to lobby when taking a break (will add just an "AFK" option soon)
* Takes a configurable set of parameters to generate randomised runtimes and break times

#### How does it work?
* `BREAK.BREAK_SETTINGS` table can be statically defined in `Break.lua` as a default set of parameters to be used for all scripts
* `BREAK.BREAK_SETTINGS` table can be statically defined in your script file to overwrite what's in `Break.lua` if you want different parameters for different scripts
* `BREAK.updateBreakTimers()` - put this in your main loop, this will keep the timer tracking and GUI up to date
* `BREAK.checkForBreak()` - this checks if in a break or not - this should be used where in your script you're happy for a break to happen (e.g. if banking, check this function, if this function is true, then skip loop)
* The `hours` drop-down in the GUI will let you set the TOTAL runtime of your script (this will have a +/- 10% modifier applied)
* Clicking `Update` will automatically calculate x number of breaks to take during the hours selected **click this before clicking start**
* Click `Start` will kick off the script once you've configured your desired total runtime
* Once running, you can also pause/stop the script

**Example**

![image](https://github.com/thewrayman/ME_Scripts/assets/9122631/112be8c0-d330-4835-bf3e-ebc4e9ad53d1)
* `Hours` dropdown - total hours the script should run for
* `TTE` = Time Till End (this will line up with the hours selected)
* `TTB` = Time till next Break (if not in a break)
* `TTBE` = Time til the current Break ends (if in a break)
* `Breaks` = Number of breaks remaining
* `Type` = What type of break to take - Lobby/AFK/Both - Both will randomly assign either Lobby or AFK to each break it plans out
* `BT` = Break type (Lobby/AFK) - will have N/A in front if not in break yet, but will tell you type of break coming up next
* So this will run for 3 hours (+/- 10%) with 3 total breaks, the next break happening in 24 mins from now, and 2hr 25mins until the 3hr runtime has been reached

**Usage in a script**
```
local API = require("api")
local BREAK = require("Break")
API.SetDrawTrackedSkills(true)
API.SetDrawLogs(true)

-- defining override settings parameters. e.g 3hrs total runtime, take a break every ~1hr for ~5mins
BREAK.BREAK_SETTINGS = {
    TOTAL_RUNTIME_MAX = 10800, -- this will get overriden by the hours dropdown, so this doesn't matter too much
    MIN_SESSION_TIME = 3000, -- minimum amount of time to make each session last before taking a break
    MAX_SESSION_TIME = 4000, -- maximum amount of time to make each session last before taking a break
    BUFFER_TIME = 30, -- this will account for time different between the step you want to take a break at - e.g if you want to take a break after banking, and you bank every 20 seconds, the buffer should be > 20
    MIN_BREAK_TIME = 240, -- minimum amount of time the break should last
    MAX_BREAK_TIME = 480, -- maximum amount of time the break should last
    BREAK_TYPE = "Lobby" -- Lobby/AFK/Both - this will get overriden by the GUI
}

 local function bank()
    -- do your banking stuff
 end

 local function doStuff()
    -- do your main script logic
 end

while (API.Read_LoopyLoop() and BREAK.inValidLoop()) do
    BREAK.updateBreakTimers()
    
    if BREAK.checkForBreak() then
        -- is on break, just skip loop
        API.RandomSleep2(1000,400,800)
    else
        -- not on break, do stuff
        doStuff()
        bank()
    end
    
end
```

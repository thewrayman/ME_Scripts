local API = require("api")
local LODESTONES = require("lodestones")

MAX_IDLE_TIME_MINUTES = 5
startTime, afk, questStart = os.time(), os.time(), os.time()

ID = {
    AERECK = 456,
    CHURCHDOOR = 36999,
    URHNEY = 458,
    DOOR1 = 45539,
    AMULET = 552,
    COFFIN = 89481,
    GHOST = 457,
    SKULL = 553,
    ROCKS = 47714,
    OPENCOFFIN = 89484
}

local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
    end
end

function run_to_tile(x, y, z)
    local tile = WPOINT.new(x, y, z)

    API.DoAction_Tile(tile)

    while API.Read_LoopyLoop() and API.Math_DistanceW(API.PlayerCoord(), tile) > 5 do
        API.RandomSleep2(100, 200, 200)

        idleCheck()
    end
end

local function isInLumbridge()
    return API.PInArea(3235, 40, 3214, 40, 0)
end

CURRENT_STEP = 1
TOTAL_STEPS = 12

local function questFunction()
    if API.Check_continue_Open() then
            API.KeyboardPress(" ")
            API.RandomSleep2(100,100,200)
    end
    -- make sure player is in Lumbridge to start
    if CURRENT_STEP == 1 then
        if not isInLumbridge() then
            LODESTONES.Lumbridge()
            API.RandomSleep2(2000,200,200)
        else
            CURRENT_STEP = 2
            goto continue
        end
    end
    
    if CURRENT_STEP == 2 then
        -- run to the church and start the quest
        run_to_tile(3239, 3210, 0)
        API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ ID.CHURCHDOOR },50)
        API.RandomSleep2(1200,200,200)
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, { ID.AERECK }, 50)
        CURRENT_STEP = 3
        goto continue
    end

    if CURRENT_STEP == 3 then
        if tonumber(API.Dialog_Option("I'm looking for a quest!")) then
            API.Select_Option("I'm looking for a quest!")
            API.RandomSleep2(500,100,200)
            API.KeyboardPress(" ")
            API.RandomSleep2(3000,100,200) -- should probably be replaced with a check for the quest interface popping up but CBA
            API.DoAction_Interface(0x24,0xffffffff,1,1500,409,-1,API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(1100,100,200)
            CURRENT_STEP = 4
            goto continue
        end
    end

    if CURRENT_STEP == 4 then
        if API.Check_continue_Open() then
            API.KeyboardPress(" ")
            API.RandomSleep2(300,200,200)
        else
            API.RandomSleep2(600,200,200)
            CURRENT_STEP = 5
            goto continue
        end
    end

    if CURRENT_STEP == 5 then
        -- travel to father urhney
        run_to_tile(3244,3191,0)
        run_to_tile(3228,3161,0)
        run_to_tile(3208,3152,0)
        CURRENT_STEP = 6
        goto continue
    end

    if CURRENT_STEP ==  6 then
        if not (API.Compare2874Status(12, false)) then
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ ID.DOOR1 },50)
            API.RandomSleep2(2000,100,200)
            API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{ ID.URHNEY },50)
            API.RandomSleep2(500,100,100)
        elseif tonumber(API.Dialog_Option("Father Aereck sent me to talk to you.")) then
            API.KeyboardPress("2")
        elseif tonumber(API.Dialog_Option("A ghost is haunting his graveyard.")) then
            API.KeyboardPress("1")
        elseif API.InvItemcount_String("Ghostspeak amulet") > 0 then
            CURRENT_STEP = 7
            goto continue
        end
    end

    if CURRENT_STEP == 7 then
        run_to_tile(3228,3161,0)
        run_to_tile(3244,3191,0)
        API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ ID.COFFIN },50)
        API.RandomSleep2(7000,200,200)
        CURRENT_STEP = 8
        goto continue
    end

    if CURRENT_STEP == 8 then
        -- equip ghostspeak and talk to the ghost once it appears
        if not API.DoAction_Inventory1(552, 0, 2, API.OFF_ACT_GeneralInterface_route) then
            API.DoAction_Interface(0x33,0x228,2,1473,5,0,API.OFF_ACT_GeneralInterface_route) -- if inv action fails, it will try to click first inv spot for the amulet
        end
        API.RandomSleep2(4000,100,100)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{ ID.GHOST },50)
        API.RandomSleep2(1100,100,200)
        CURRENT_STEP = 9
        goto continue
    end

    if CURRENT_STEP == 9 then
        -- ghost dialog
        API.RandomSleep2(200,100,100)
        if tonumber(API.Dialog_Option("Yep. Now, tell me what the problem is.")) then
            API.KeyboardPress("1")
            API.RandomSleep2(300,100,200)
        elseif not API.Compare2874Status(12, false) then
            CURRENT_STEP = 10
            goto continue
        end
    end

    if CURRENT_STEP == 10 then
        -- run to get skull
        if isInLumbridge() then
            run_to_tile(3228,3161,0)
            run_to_tile(3234,3145,0)
        elseif API.InvItemcount_String("Muddy skull") > 0 then
            CURRENT_STEP = 11
            goto continue
        elseif API.PInArea(3234, 5, 3145, 5, 0) then
            API.DoAction_Object1(0x38,API.OFF_ACT_GeneralObject_route0,{ ID.ROCKS },50)
            API.RandomSleep2(2000,200,200)
            API.KeyboardPress(" ")
        end
    end

    if CURRENT_STEP == 11 then
        -- run back to the coffin
        if not isInLumbridge() then
            API.RandomSleep2(500,100,200)
            run_to_tile(3228,3161,0)
            run_to_tile(3249,3193,0)
        end
        
        -- if coffin is closed then open it
        if #API.GetAllObjArrayInteract({ ID.OPENCOFFIN }, 20, {0}) == 0 then
            API.RandomSleep2(2000,400,800)
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{ ID.COFFIN },50)
            API.RandomSleep2(3000,200,400)
        else
            -- wait for coffin to close again - quest ending seems bugged if re-using the already opended coffin?
            API.RandomSleep2(600,400,600)
            goto continue
        end

        --use skull on open coffin
        API.DoAction_Inventory1(ID.SKULL, 0, 2, API.OFF_ACT_Bladed_interface_route)
        API.RandomSleep2(1200,300,500) --maybe longer? potato vm struggled with timing
        API.DoAction_Object1(0x24,-80,{ ID.OPENCOFFIN },50)
        API.RandomSleep2(5000,200,500)
        CURRENT_STEP = 12
        goto continue
    end

    if CURRENT_STEP == 12 then
        if not isInLumbridge() then
            API.RandomSleep2(500,100,100)
        elseif API.Compare2874Status(12, false) then
            goto continue
        else
            API.RandomSleep2(3000,200,600)
            API.DoAction_Interface(0xffffffff,0xffffffff,1,1244,21,-1,API.OFF_ACT_GeneralInterface_route)
            print(os.difftime(os.time(), questStart))
            API.Write_LoopyLoop(false)
        end
        
    end

    ::continue::
end

while (API.Read_LoopyLoop()) do
    idleCheck()
    questFunction()
    API.RandomSleep2(200, 400, 400)
end
local API = require("api")

TASK = {}

local items = {
    {GROUP = "kili", DATA= {
        {NAME = "Spider silk hood", ID = 25835, VOL = 28, PRICE = 50000},
        {NAME = "Thread", ID = 1734, VOL = 10, PRICE = 1000},
        {NAME = "Spirit rune", ID = 55337, VOL = 300, PRICE = 1000},
        {NAME = "Mystic hat", ID = 4089, VOL = 7, PRICE = 300000},
        {NAME = "Springsheared wool", ID = 43977, VOL = 5, PRICE = 100000},
        {NAME = "Bronze bar", ID = 2349, VOL = 14, PRICE = 10000},
        {NAME = "Iron bar", ID = 2351, VOL = 14, PRICE = 10000},
        {NAME = "Steel bar", ID = 2353, VOL = 14, PRICE = 10000},
        {NAME = "Adamant bar", ID = 2361, VOL = 7, PRICE = 10000},
        {NAME = "Rune bar", ID = 2363, VOL = 7, PRICE = 10000},
        {NAME = "Orikalkum bar", ID = 44838, VOL = 7, PRICE = 15000},
        {NAME = "Bone rune", ID = 55338, VOL = 100, PRICE = 1000},
        {NAME = "Meat pie", ID = 2327, VOL = 1, PRICE = 50000},
        {NAME = "Garden pie", ID = 7178, VOL = 1, PRICE = 50000},
        {NAME = "Apple pie", ID = 2323, VOL = 1, PRICE = 50000},
        {NAME = "Bucket of water", ID = 1929, VOL = 1, PRICE = 10000},
        {NAME = "Chocolate dust", ID = 1975, VOL = 1, PRICE = 10000},
        {NAME = "Bucket of milk", ID = 1927, VOL = 1, PRICE = 10000},
        {NAME = "Snape grass", ID = 231, VOL = 1, PRICE = 10000},
        {NAME = "Bowl of water", ID = 1921, VOL = 5, PRICE = 10000},
        {NAME = "Leather gloves", ID = 1059, VOL = 1, PRICE = 10000}
    }
    },
    {GROUP = "prayer", DATA= {
        {NAME = "Powder of burials", ID = 52805, VOL = 1, PRICE = 400000},
        {NAME = "Dinosaur bones", ID = 48075, VOL = 500, PRICE = 50000},
        }
    },

    {GROUP = "dxpStarter", DATA= {
        {NAME = "Eye of newt", ID = 221, VOL = 2000, PRICE = 1000},
        {NAME = "Guam potion", ID = 91, VOL = 2000, PRICE = 5000},
        {NAME = "Snape grass", ID = 231, VOL = 3000, PRICE = 5000},
        {NAME = "Ranarr potion", ID = 99, VOL = 3000, PRICE = 10000},
        {NAME = "Snapdragon potion", ID = 3004, VOL = 1000, PRICE = 10000},
        {NAME = "Red spider's eggs", ID = 223, VOL = 1000, PRICE = 2000},
        {NAME = "Dwarf weed potion", ID = 109, VOL = 5000, PRICE = 10000},
        {NAME = "Wine of Zamorak", ID = 245, VOL = 5000, PRICE = 5000},
        {NAME = "Super energy", ID = 3018, VOL = 2000, PRICE = 5000},
        {NAME = "Papaya", ID = 5972, VOL = 2000, PRICE = 5000},
        {NAME = "Overload", ID = 55193, VOL = 1000, PRICE = 105000},
        {NAME = "Uncut opal", ID = 1625, VOL = 1000, PRICE = 2000},
        {NAME = "Uncut sapphire", ID = 1623, VOL = 2000, PRICE = 2000},
        {NAME = "Uncut dragonstone", ID = 1631, VOL = 4000, PRICE = 7000}
        }
    },

    {GROUP = "dxpSummoning", DATA= {
        {NAME = "Pouch", ID = 12155, VOL = 10000, PRICE = 100},
        {NAME = "Honeycomb", ID = 12156, VOL = 700, PRICE = 5000},
        {NAME = "Steel bar", ID = 2353, VOL = 500, PRICE = 10000},
        {NAME = "Mithril bar", ID = 2359, VOL = 1500, PRICE = 5000},
        {NAME = "Fire talisman", ID = 2359, VOL = 2000, PRICE = 5000},
        {NAME = "Water talisman", ID = 1444, VOL = 5000, PRICE = 5000}
        }
    }
}

GrandExchange:DelayOffset(600)

function TASK.setFocus(focusString)
    for _,v in pairs(items) do
        if v.GROUP == focusString then
            TASK.FOCUS = v.DATA
        end
    end
    if TASK.FOCUS == nil then
        API.Write_LoopyLoop(false)
        API.logError("No valid item group provided, exiting")
    end
end

API.logInfo("Running BuyItems Task")

function TASK.run()
    if #TASK.FOCUS == 0 then
        TASK.COMPLETE = true
        return
    end
    if GrandExchange:IsAtGE() then
        if GrandExchange:IsGEWindowOpen() then
            local k = TASK.FOCUS[1]
            API.logDebug("Buying " .. k.NAME)
            GrandExchange:PlaceOrder(OrderType.BUY, k.ID, k.NAME, k.PRICE, k.VOL)
            API.RandomSleep2(1200, 600, 600)
            GrandExchange:CollectToInventory()
            table.remove(TASK.FOCUS, 1)
        else
            GrandExchange:Open()
            API.RandomSleep2(2000,400,800)
        end
    end
end

return TASK

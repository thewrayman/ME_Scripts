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
        {NAME = "Red spider", ID = 223, VOL = 1000, PRICE = 2000},
        {NAME = "Dwarf weed potion", ID = 109, VOL = 25000, PRICE = 10000},
        {NAME = "Wine of Zamorak", ID = 245, VOL = 25000, PRICE = 5000},
        {NAME = "Super energy", ID = 3018, VOL = 1000, PRICE = 5000},
        {NAME = "Papaya", ID = 5972, VOL = 1000, PRICE = 5000},
        {NAME = "Overload", ID = 55193, VOL = 1000, PRICE = 105000},
        {NAME = "Uncut opal", ID = 1625, VOL = 1000, PRICE = 2000},
        {NAME = "Uncut sapphire", ID = 1623, VOL = 2000, PRICE = 2000},
        {NAME = "Uncut dragonstone", ID = 1631, VOL = 5000, PRICE = 7000}
        }
    },

    {GROUP = "dxpSummoning", DATA= {
        {NAME = "Bucket of sand", ID = 1783, VOL = 300/2, PRICE = 1000},
        {NAME = "Pouch", ID = 12155, VOL = 15000/2, PRICE = 100},
        {NAME = "Honeycomb", ID = 12156, VOL = 370/2, PRICE = 5000},
        {NAME = "Tinderbox", ID = 590, VOL = 118/2, PRICE = 2000},
        {NAME = "Raw beef", ID = 2132, VOL = 1000/2, PRICE = 10000},
        {NAME = "Goat horn dust", ID = 9736, VOL = 2950/2, PRICE = 10000},
        {NAME = "Granite", ID = 6979, VOL = 2500/2, PRICE = 5000},
        {NAME = "Mithril bar", ID = 2359, VOL = 100/2, PRICE = 5000},
        {NAME = "Rune bar", ID = 2363, VOL = 1650/2, PRICE = 10000},
        {NAME = "Fire talisman", ID = 1442, VOL = 2520/2, PRICE = 1000},
        {NAME = "Water talisman", ID = 1444, VOL = 3005/2, PRICE = 5000}
        }
    },

    {GROUP = "Summoning", DATA= {
        {NAME = "Bucket of sand", ID = 1783, VOL = 300, PRICE = 1000},
        {NAME = "Pouch", ID = 12155, VOL = 15000, PRICE = 100},
        {NAME = "Honeycomb", ID = 12156, VOL = 370, PRICE = 5000},
        {NAME = "Tinderbox", ID = 590, VOL = 118, PRICE = 2000},
        {NAME = "Raw beef", ID = 2132, VOL = 1000, PRICE = 10000},
        {NAME = "Goat horn dust", ID = 9736, VOL = 2950, PRICE = 10000},
        {NAME = "Granite", ID = 6979, VOL = 2500, PRICE = 5000},
        {NAME = "Mithril bar", ID = 2359, VOL = 100, PRICE = 5000},
        {NAME = "Rune bar", ID = 2363, VOL = 1650, PRICE = 10000},
        {NAME = "Fire talisman", ID = 1442, VOL = 2520, PRICE = 1000},
        {NAME = "Water talisman", ID = 1444, VOL = 3005, PRICE = 5000}
        }
    },

    {GROUP = "zamCollection1", DATA = {
        {NAME = "Leather scraps", ID = 49452, VOL = 22, PRICE = 10000},
        {NAME = "Goldrune", ID = 49450, VOL = 58, PRICE = 10000},
        {NAME = "Ruby", ID = 1603, VOL = 1, PRICE = 10000},
        {NAME = "Third Age iron", ID = 49460, VOL = 30, PRICE = 10000},
        {NAME = "Hellfire metal", ID = 49504, VOL = 24, PRICE = 30000},
        {NAME = "Demonhide", ID = 49500, VOL = 36, PRICE = 10000},
        {NAME = "Vellum", ID = 49462, VOL = 6, PRICE = 10000},
        {NAME = "Orthenglass", ID = 49454, VOL = 26, PRICE = 10000},
        {NAME = "Chaotic brimstone", ID = 49498, VOL = 26, PRICE = 10000},
        {NAME = "Eye of Dagon", ID = 49502, VOL = 14, PRICE = 10000},
        {NAME = "Samite silk", ID = 49456, VOL = 22, PRICE = 10000},
        {NAME = "Cadmium red", ID = 49496, VOL = 30, PRICE = 20000},
        {NAME = "White oak", ID = 49464, VOL = 6, PRICE = 10000},
        {NAME = "Archaeology teleport", ID = 49935, VOL = 1, PRICE = 200000},
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

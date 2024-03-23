--[[
Author: Tinie
Inital Release Date: 9th March 2024
Last Update Data: 23rd March 2024
Version 2.0

--Release Notes
* 2.0.0
    Major changes
        Reading the Slot data from memory
        Checking max slot availability based on membership rather than UI
        Added some delays into some of the status checks to hopefully make it more consistent

* 1.0.0
    Initial release for GE Buying functionality with sample script
]]

local API = require("api")
local GE = {}

local IDS = {
    CLERK = 24854
}

local VBS = {
    SELECTED_ITEM = 135,
    VOLUME = 136,
    PRICE = 137
}

local VB_VALUES = {
    CHAT_BOX_OPEN = 11,
    GEWINDOW = 82,
}

local BASE_INTERFACE = {
    { 105,1,-1,-1,0 },
    { 105,3,-1,1,0 },
    { 105,6,-1,3,0 }
}

-- GE slot 1-8 interface component ID
MAX_SLOTS = API.IsMember() and 8 or 3
SLOT_IDS = {table.unpack({7, 28, 49, 70, 94, 118, 142, 166}, 1, MAX_SLOTS)}
API.logDebug("max slots: " .. MAX_SLOTS)

BASE_OFFSETS = {0x38, 0x918, 0x10, 0x10, 0x48, 0xA0}

SLOT_OFFSETS = {
    STATUS = 0x10,  --comp=5,open=2, no order = 0
    OFFER_TYPE = 0x14, -- buy (0) /sell (1)
    ITEM_ID = 0x18,
    PRICE = 0x20,
    VOLUME = 0x28,
    COMPLETED_VOLUME = 0x2C,
    COMPLETED_VALUE = 0x30
}

---@class GESlot
---@field STATUS number
---@field OFFER_TYPE number
---@field ITEM_ID number
---@field PRICE number
---@field VOLUME number
---@field COMPLETED_VOLUME number
---@field COMPLETED_VALUE number

GE_PTR = 0x00D56958
MEMLOC = nil

function GE.IsInGE()
    return API.PInArea(3164, 15, 3477, 15, 0)
end

function GE.GEWindowOpen()
    return API.Compare2874Status(VB_VALUES.GEWINDOW, false)
end

function GE.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--- Used to grab the starting memory location for the GE data we care about
---@return number
function GE.GrabMemoryLocation()
    API.logDebug("Trying to grab GE memory location")
    local temploc = API.Mem_Read_uint64(API.Get_RSExeStart() + GE_PTR)
    for _,offset in pairs(BASE_OFFSETS) do
        temploc = API.Mem_Read_uint64(temploc + offset)
    end
    MEMLOC = temploc
    return MEMLOC
end

---Given a slot (1-8) it will fetch the key values from memory about that slot
---@param slot number
---@return GESlot -- will return a table with the structure of SLOT_OFFSETS for the specified slot
function GE.GetSlotInfoFromMemory(slot)
    local slotBaseLocation = MEMLOC + ((slot-1) * 40)
    local memObject = {}

    for _, offset in pairs(SLOT_OFFSETS) do
        memObject[_] = API.Mem_Read_int(slotBaseLocation + offset)
    end

    return memObject

end

---Will go through all slots and return a table of the details for each slot
---@return table -- each object in the table will have the structure seen in SLOT_OFFSETS vector<GESlot>
function GE.GetAllSlotInfoFromMemory()
    local allSlotInfo = {}

    for slot = 1,#SLOT_IDS do
        table.insert(allSlotInfo, GE.GetSlotInfoFromMemory(slot))
    end

    return allSlotInfo
end

---Checks which GE slots aren't in use and returns a table of the slot numbers (1-8) that are currently available
---@return table --table of component IDs for available GE Slots 
function GE.GetAvailableSlots()
    local available = {}
    local allSlots = GE.GetAllSlotInfoFromMemory()

    for _,slot in pairs(allSlots) do
        if (slot.STATUS == 0) then
            table.insert(available, _)
            API.logDebug("Slot " .. _ .. " is available")
        end
    end
    API.logDebug("Found " .. #available .. " GE slots")
    return available
end

---Checks the GE search results for the item, and returns the interface component ID to be used for selecting
---@param itemName -- string of the item name being searched for
---@return number -- interface component ID to select
function GE.SearchForItemInUI(itemName)
    local resultInterface = {
        { 105,1,-1,-1,0 },
        { 105,3,-1,1,0 },
        { 105,322,-1,3,0 },
        { 105,326,-1,322,0 },
        { 105,340,-1,326,0 },
        { 105,342,-1,340,0 }
    }

    local id = 0

    local interfaceOpen = API.ScanForInterfaceTest2Get(true, resultInterface)
    if #interfaceOpen > 0 then
        for _,v in pairs(interfaceOpen) do
            if v.textids == itemName then
                id = v.id3 - 1
                API.logDebug("Found ".. itemName .. " in GE search results")
                return id
            end
        end
    end
    API.logError(itemName .. " not found in the GE search results list")
    return 0
end

---Will find the item in the GE search results and select that item from the results list
---@param itemName string -- name of item to select
---@param itemId number -- id number of item to select
---@return boolean -- item selection successful?
function GE.SelectItem(itemName, itemId)
    local itemFound = GE.SearchForItemInUI(itemName)

    if itemFound ~= nil then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,105,342,itemFound,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1200,300,600)
        if API.VB_FindPSettinOrder(VBS.SELECTED_ITEM, 0).state == itemId then
            API.logDebug("Successfully selected " .. itemName)
            return true
        else
            API.logError("Tried to select item but looks like the selection failed")
            return false
        end
    else
        return false
    end
end

function GE.TypeInput(input, baseDelay)
    for i in input:gmatch"." do
        API.KeyboardPress(i)
        API.RandomSleep2(baseDelay,150,200)
    end
end

---Function to input item name in GE search bar - if Bar isn't open, it will return false
---@param itemName string -- name of item to select
---@param itemId number -- id number of item to select
---@return boolean -- successfully searched and found the item?
function GE.SearchForItem(itemName, itemId)
    if API.Compare2874Status(VB_VALUES.CHAT_BOX_OPEN, true) then
        GE.TypeInput(itemName, 100)
        API.RandomSleep2(600,300,600)
        if GE.SelectItem(itemName, itemId) then
            return true
        else
            return false
        end
    else
        API.logError("GE Search Text Bar not opened")
        return false
    end
end

---Click on the Buy button for the targeted GE slot
---@param slot number -- the interface component ID corresponding to the GE slot to target
---@return boolean -- successfully opened the Buy window?
function GE.OpenBuy(slot)
    if GE.GEWindowOpen() then
        API.DoAction_Interface(0x24,0xffffffff,1,105,SLOT_IDS[slot]+8,-1,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1000,600,1200)
        if API.Compare2874Status(VB_VALUES.CHAT_BOX_OPEN, true) then
            return true
        end
    end
    return false
end

---Sets the buy price for the item in the UI
---@param price number -- price to set for the item
---@return boolean -- return if the price is successfully inputted
function GE.SetPrice(price)
    API.DoAction_Interface(0xffffffff,0xffffffff,1,105,278,-1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(1000,600,1200)
    GE.TypeInput(tostring(price), 100)
    API.RandomSleep2(1200,600,1200)
    API.KeyboardPress2(0x0D)
    API.RandomSleep2(1200,600,1200)
    if API.VB_FindPSettinOrder(VBS.PRICE, 0).state == price then
        return true
    end
    return false
end

---Sets the quantity for the item in the UI
---@param volume number
---@return boolean
function GE.SetVolume(volume)
    API.DoAction_Interface(0xffffffff,0xffffffff,1,105,237,-1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(1000,600,1200)
    GE.TypeInput(tostring(volume), 100)
    API.RandomSleep2(1200,600,1200)
    API.KeyboardPress2(0x0D)
    API.RandomSleep2(1200,600,1200)
    if API.VB_FindPSettinOrder(VBS.VOLUME, 0).state == volume then
        return true
    end
    return false
end

---Top level function to call once the item has been seleced - inserts the price and volume/quantity
function GE.PlaceOrder(volume, price)
    if GE.SetVolume(volume) then
        if GE.SetPrice(price) then
            return true
        end
        API.logError("Failed to set the Price")
    else
        API.logError("Failed to set the Volume")
    end

     return false

end

---Hits the confirm order button
function GE.ConfirmOrder()
    API.DoAction_Interface(0x24,0xffffffff,1,105,325,-1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(600,600,1200)
    API.logDebug("Trying to confirm offer")
end

---Given a specified slot (number 1-8), it will return true if it has a completed order
function GE.IsOrderComplete(slot)
    local slotInfo = GE.GetSlotInfoFromMemory(slot)
    
    if slotInfo.STATUS == 5 then
        return true
    elseif slotInfo.COMPLETED_VOLUME > 0 then
        API.logDebug("Slot " .. slot .. " order is partially filled")
    else
        API.logDebug("Slot " .. slot .. " order is not filled at all")
    end
    return false

end

---Presses the back button seen in the GE interface
function GE.PressBack()
    API.DoAction_Interface(0xffffffff,0xffffffff,1,105,201,-1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(600,600,1200)
end

---Hits the "Collect to Inventory" button the main GE window
function GE.CollectToInventory()
    API.DoAction_Interface(0x24,0xffffffff,1,651,6,-1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(600,600,1200)
end

---Overall function which will find an available buy slot, search and select the item for purchase
---Can use this as an example of how to leverage the different functions
---@param itemName string -- name of item to select
---@param itemId number -- id number of item to select
---@param volume number -- quantity of the item to buy
---@param price number -- price to set for the item
---@return boolean -- successfully searched and found the item?
function GE.Buy(itemName, itemId, volume, price)
    local slots = GE.GetAvailableSlots()
    if #slots == 0 then
        API.logError("No GE slots available to carry out a buy offer")
        return false
    else
        if GE.OpenBuy(slots[1]) then    -- try and open the first available slot
            if GE.SearchForItem(itemName, itemId) then  -- try and search for the item you want to buy
                if GE.PlaceOrder(volume, price) then  -- try and place the order
                    GE.ConfirmOrder()
                    API.RandomSleep2(600,600,1200)
                    GE.CollectToInventory()
                    return true
                else
                    API.logError("Failed to place order, see error stack")
                end
            end
        end
        return false
    end
end

function GE.OpenGE()
    if GE.IsInGE() and not GE.GEWindowOpen() then
        API.DoAction_NPC(0x5, API.OFF_ACT_InteractNPC_route, { IDS.CLERK }, 50)
        API.RandomSleep2(600,300,600)
        return false
    elseif GE.GEWindowOpen() then
        return true
    end
end

--- Exmaple simple script which will take a list of items - itemsToBuy
--- And will check if you're in GE, if you're in GE it will try to open the exchange window and buy the items

-- local API = require("api")
-- local GE = require("GrandExchange")
-- API.SetDrawTrackedSkills(true)
-- API.SetDrawLogs(true)

-- local itemsToBuy = {
--     {NAME = "Rock climbing boots", ID = 3105, VOL = 1, PRICE = 100000},
--     {NAME = "Bucket", ID = 1925, VOL = 3, PRICE = 500},
--     {NAME = "Vial", ID = 229, VOL = 10, PRICE = 100}
-- }

-- while API.Read_LoopyLoop() do
--     if GE.IsInGE() then
--         if GE.OpenGE() then
--             for _,i in pairs(itemsToBuy) do
--                 API.logDebug("Trying to buy ".. i.NAME )
--                 GE.Buy(i.NAME, i.ID, i.VOL, i.PRICE)
--             end
--             API.Write_LoopyLoop(false)
--         end
--         API.RandomSleep2(600,600,1200)
--     else
--         API.logError("Not in GE - exiting.")
--         API.Write_LoopyLoop(false)
--     end

-- end

GE.GrabMemoryLocation()


return GE


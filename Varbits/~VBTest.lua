local API = require("api")
local json = require("dkjson")
API.SetDrawLogs(true)

local filename = "<dir>\\vbs.json" --UPDATE THIS FILEPATH TO WHEREVER YOU WANT TO STORE THE JSON
local data = io.open(filename, "r")
local jsonString = data:read("*all")
data:close()

--local x = API.JsonDecode(jsonString) would ideally use this but seems to not like the json file
local x = json.decode(jsonString)

function createBitmask(numBits)
    return (1 << numBits) - 1
end

function getVarpFromVB(vb)
    for _, v in pairs(x) do
        if vb == v.varbit then
            return v.varpid, v.lsb, createBitmask((v.msb - v.lsb) + 1)
        end
    end
end

local varp, bit, mask = getVarpFromVB(16745) -- e.g protect from magic varbit
print("API.VB_FindPSettinOrder(" .. varp .. ", 0).state >> " .. bit .. " & " .. mask)
print(API.VB_FindPSettinOrder(varp, 0).state >> bit & mask)
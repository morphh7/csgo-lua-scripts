local ffi = require("ffi")

local IClientEntityList = ffi.cast(ffi.typeof("void***"), utils.create_interface("client.dll", "VClientEntityList003"))
local GetHighestEntityIndex = ffi.cast(ffi.typeof("int(__thiscall*)(void*)"), IClientEntityList[0][6])
local GetClientEntity = ffi.cast(ffi.typeof("unsigned long(__thiscall*)(void*, int)"), IClientEntityList[0][3])


local entlist = {}

entlist.find_by_class = function(class) -- Example: "CBasePlayer"
    for i=64, GetHighestEntityIndex(IClientEntityList) do
        local ent = entitylist.get_player_by_index(i)
        
        if ent ~= nil then
            if ent:get_class_name() == class then
                return ent
            end
        end
    end
end

menu.add_combo_box("Chicken outfit", {
    "Default Chicken",
    "Party Chicken",
    "Ghost Chicken",
    "Festive Chicken",
    "Easter Chicken",
    "Jack-o'-Chicken"
})

client.add_callback("on_paint", function()
    local chickens = entlist.find_by_class(CChicken)
    
    if chickens == nil then return end
    
    for i = 1, #chickens do
        local chicken = chickens[i]

        local outfit = menu.get_int("Chicken outfit")
        chickens:set_prop_int("CChicken", "m_flModelScale", 1)
        
        if outfit == 0 then
            chickens:set_prop_int("CChicken", "m_nBody", 0)
    
        elseif outfit == 1 then
            chickens:set_prop_int("CChicken", "m_nBody", 1)
    
        elseif outfit == 2 then
            chickens:set_prop_int("CChicken", "m_nBody", 2)
    
        elseif outfit == 3 then
            chickens:set_prop_int("CChicken", "m_nBody", 3)
    
        elseif outfit == 4 then
            chickens:set_prop_int("CChicken", "m_nBody", 4)
    
        elseif outfit == 5 then
            chickens:set_prop_int("CChicken", "m_nBody", 5)
        end
    end
end)

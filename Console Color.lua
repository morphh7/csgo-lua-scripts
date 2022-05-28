--- @region: script information
    -- @ name: console color changer
    -- @ author: NetKing#8467
    -- @ version: 0.1.0 [release]
        -- @ hehe: https://youtu.be/8sRUbxDkDHo
--- @endregion

--- @region: require
local ffi = require("ffi")

--- @region: tables
local helper_mt = {}
local interface_mt = {}
--- @endregion

--- @region: hook things
local iface_ptr = ffi.typeof('void***')
local char_ptr = ffi.typeof('char*')
local nullptr = ffi.new('void*')
--- @endregion

--- @reigon: iface_cast
local function iface_cast(raw)
    return ffi.cast(iface_ptr, raw)
end
--- @endregion

--- @reigon: is_valid_ptr
local function is_valid_ptr(p)
    return p ~= nullptr and p or nil
end
--- @endregion

--- @reigon: function_cast
local function function_cast(thisptr, index, typedef, tdef)
    local vtblptr = thisptr[0]

    if is_valid_ptr(vtblptr) then
        local fnptr = vtblptr[index]

        if is_valid_ptr(fnptr) then
            local ret = ffi.cast(typedef, fnptr)

            if is_valid_ptr(ret) then
                return ret
            end

            error('function_cast: couldn\'t cast function typedef: ' ..tdef)
        end
        error('function_cast: function pointer is invalid, index might be wrong typedef: ' .. tdef)
    end
    error("function_cast: virtual table pointer is invalid, thisptr might be invalid typedef: " .. tdef)
end
--- @endregion

--- @region: check_or_create_typedef
local seen = {}
local function check_or_create_typedef(tdef)
    if seen[tdef] then
        return seen[tdef]
    end

    local success, typedef = pcall(ffi.typeof, tdef)
    if not success then
        error("error while creating typedef for " ..  tdef .. "\n\t\t\terror: " .. typedef)
    end
    seen[tdef] = typedef
    return typedef
end
--- @endregion

--- @region: get_vfunc
function interface_mt.get_vfunc(self, index, tdef)
    local thisptr = self[1]

    if is_valid_ptr(thisptr) then
        local typedef = check_or_create_typedef(tdef)
        local fn = function_cast(thisptr, index, typedef, tdef)

        if not is_valid_ptr(fn) then
            error("get_vfunc: couldnt cast function (" .. index .. ")")
        end

        return function(...)
            return fn(thisptr, ...)
        end
    end

    error('get_vfunc: thisptr is invalid')
end
--- @endregion

--- @region: find_interface
function helper_mt.find_interface(module, interface)
    local iface = utils.create_interface(module, interface)
    if is_valid_ptr(iface) then
        return setmetatable({iface_cast(iface), module}, {__index = interface_mt})
    else
        error("find_interface: interface pointer is invalid (" .. module .. " | " .. interface .. ")")
    end
end
--- @endregion

--- @region: get_class
function helper_mt.get_class(raw, module)
    if is_valid_ptr(raw) then 
        local ptr = iface_cast(raw)
        if is_valid_ptr(ptr) then 
            return setmetatable({ptr, module}, {__index = interface_mt})
        else
            error("get_class: class pointer is invalid")
        end
    end
    error("get_class: argument is nullptr")
end
--- @endregion

--- @region: console hooking
local matsys = helper_mt.find_interface('materialsystem.dll', 'VMaterialSystem080')
local engine = helper_mt.find_interface('engine.dll', 'VEngineClient014')
local first_material = matsys:get_vfunc(86, "int(__thiscall*)(void*)")
local next_material = matsys:get_vfunc(87, "int(__thiscall*)(void*, int)")
local invalid_material = matsys:get_vfunc(88, "int(__thiscall*)(void*)")
local find_material = matsys:get_vfunc(89, "void*(__thiscall*)(void*, int)")
local is_console_visible = engine:get_vfunc(11, "bool(__thiscall*)(void*)")
local materials = {'vgui_white','vgui/hud/800corner1', 'vgui/hud/800corner2', 'vgui/hud/800corner3', 'vgui/hud/800corner4'}
--- @endregion

--- @region: menu_elements
menu.add_color_picker("Console Color")

--- @region: color handler
local was_updated = false
local old_color = color.new(255, 255, 255, 255)

function color_was_updated(color1, color2)
    return color1.r ~= color2.r or color1.g ~= color2.g or color1.b ~= color2.b or color1.a ~= color2.a
end
--- @endregion

--- @region: main_function
function on_paint()
    local color = menu.get_color("Console Color")
    local i = first_material()

    local need_update = is_console_visible()

    if need_update and not was_updated then
        while i ~= invalid_material() do
            local mat = helper_mt.get_class(find_material(i))
            local get_name = mat:get_vfunc(0, 'const char*(__thiscall*)(void*)')

            local name = get_name()

            for k, mats in ipairs(materials) do
                if ffi.string(name) == mats then
                    local alpha_modulate = mat:get_vfunc(27, "void(__thiscall*)(void*, float)")
                    local color_modulate = mat:get_vfunc(28, "void(__thiscall*)(void*, float, float, float)")


                    alpha_modulate(color:a() / 255)
                    color_modulate(color:r() / 255, color:g() / 255, color:b() / 255)
                end
            end
            i = next_material(i)
        end

        was_updated = true
    end

    if not need_update or color_was_updated(color, old_color) then
        was_updated = false
    end

    old_color = color
end
--- @endregion

--- @region: callbacks
client.add_callback('on_paint', on_paint)
--- @endregion

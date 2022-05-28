--- @region: script information
    -- @ name: midgte_mode
    -- @ author: NetKing#8467
    -- @ version: 0.1.0 [release]
        -- @ Credits: Ruz#0223 / Helper
--- @endregion

--- @region: if player is alive
function player:is_alive()
    if not self then return false end
    return self:get_health() > 0
end

--- @region: tips
-- @ Amongus Mode: 
    -- local_player:set_prop_float("CCSPlayer", "m_flModelScale", 2)
    -- local_player:set_prop_int("CCSPlayer", "m_ScaleType", 1)

-- @ Default/Ducarii Mode:
    -- local_player:set_prop_float("CCSPlayer", "m_flModelScale", 0.2)
    -- local_player:set_prop_int("CCSPlayer", "m_ScaleType", 1)
-- @ Midget Mode: 
    -- local_player:set_prop_float("CCSPlayer", "m_flModelScale", 0.2)
    -- local_player:set_prop_int("CCSPlayer", "m_ScaleType", 0)

-- @ Real Midget Mode: 
    -- local_player:set_prop_float("CBaseAnimating", "m_flModelScale", 0.6)
--- @endregion

--- @region: main function
local function on_setup_command()
    -- @ Return if the local player isn't alive
    local local_player = entitylist.get_local_player()
    if not local_player or not local_player:is_alive() then
        return
    end

    -- @ Paste Here
    local_player:set_prop_float("CBaseAnimating", "m_flModelScale", 0.6)
end
--- @endregion

--- @region: unload function
local function on_shutdown()
    -- Return if the local player isn't alive
    local local_player = entitylist.get_local_player()
    if not local_player or not local_player:is_alive() then
        return
    end

    -- @ Set to default scale
    local_player:set_prop_float("CCSPlayer", "m_flModelScale", 1)
    local_player:set_prop_int("CCSPlayer", "m_ScaleType", 0)
end
--- @endergion

--- @region: callbacks
client.add_callback('create_move', on_setup_command)
client.add_callback('unload', on_shutdown)
--- @endregion

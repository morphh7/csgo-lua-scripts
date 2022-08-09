--- @region: script information
    -- @ name: Skeet Damage Marker
    -- @ author: mrekk#8467 / NetKing
    -- @ version: 0.1.0 [release]
--- @endregion

--- @region: menu elements
menu.add_check_box("Skeet Damage Marker")
menu.add_color_picker("Damage Marker Color")
--- @endregion

--- @region: fonts
local font = render.create_font("Verdana", 12, 10, true, true)

--- @region: tables
local d_marker = {}

--- @region: main function
local function on_render()
    local realtime = globals.get_realtime()

    if menu.get_bool("Skeet Damage Marker") then
        for i = 1, #d_marker do
            if d_marker[i] == nil then return end
            local marker = d_marker[i]

            local vec = render.world_to_screen(
                vector.new(marker.position.x, marker.position.y, marker.position.z)
            )

            local x = vec.x
            local y = vec.y

            local alpha = math.floor(255 * (realtime - marker.start_time))

            if realtime - marker.start_time >= 3 then
                alpha = 0
            end

            local clr = menu.get_color("Damage Marker Color")

            if x ~= nil and y ~= nil then
                local dmg = tostring(marker.damage)
                render.draw_text(font, x - 5, y - 6, color.new(clr:r(), clr:g(), clr:b(), math.floor(alpha * 255)), dmg)
            end

            marker.position.z = marker.position.z + (realtime - marker.frame_time) * 100
            marker.frame_time = realtime

            if realtime - marker.start_time >= 1 then
                table.remove(d_marker, i)
            end
        end
    end
end
--- @endregion

--- @region: onshot handler
local function on_shot(shot_info)
    if shot_info.result == "Hit" then
        local time = globals.get_realtime()
        local aim_ppoint = shot_info.aim_point

        table.insert(d_marker, {
            position = { x = aim_ppoint.x, y = aim_ppoint.y, z = aim_ppoint.z },
            damage = shot_info.server_damage,
            start_time = time,
            frame_time = time
        })
    end
end
--- @endregion

--- @region: callbacks
client.add_callback("on_paint", on_render)
client.add_callback("on_shot", on_shot)
--- @endregion

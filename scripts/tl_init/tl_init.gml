/// tl_init()

loaded = false
type = ""
type_name = ""
name = ""
display_name = ""
temp = null
text = text_get("timelineeditortextsample")
color = make_color_hsv(random(255), 255, 128)
lock = false
hide = false
depth = 0

bodypart = null
part_of = null
part_amount = 0
part[0] = null

for (var v = 0; v < values; v++)
{
    value_default[v] = tl_value_default(v)
    value_inherit[v] = 0
    value[v] = value_default[v]
}
for (var t = 0; t < value_types; t++)
{
    value_type[t] = false
    value_type_show[t] = true
}

select = false

keyframe_amount = 0
keyframe[0] = null
keyframe_current = null
keyframe_next = null
keyframe_select = null
keyframe_select_amount = 0

pos = point3D(0, 0, 0)
pos_rotate = point3D(0, 0, 0)
pos_2d = point2D(0, 0)
pos_2d_error = false

parent = null
parent_pos = null
parent_pos_read = null
parent_is_select = false
lock_bend = true
tree_amount = 0
tree[0] = null
tree_extend = false
tree_pos = 0
inherit_position = true
inherit_rotation = true
inherit_scale = true
inherit_alpha = false
inherit_color = false
inherit_texture = false
inherit_visibility = true
scale_resize = true
rot_point_custom = false
rot_point = point3D(0, 0, 0)
backfaces = false
texture_blur = false
texture_filtering = false
round_bending = app.setting_bend_round_default
shadows = true
ssao = true
fog = true
wind = false
wind_amount = 1
wind_terrain = true

particles = null

cam_surf_required = false
cam_surf = null
cam_surf_tmp = null
cam_goalzoom = null

update_matrix = true
bend_vbuffer = null
bend_lastbend = 0
bend_lastchar = 0
bend_lastbodypart = 0

text_vbuffer = null
text_texture = null
text_string = ""
text_res = null
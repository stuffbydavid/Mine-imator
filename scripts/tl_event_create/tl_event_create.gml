/// tl_event_create()
/// @desc Create event of a timeline.

save_id = ""
save_id = save_id_create()
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

model_part = null
model_part_name = ""
part_of = null
part_list = null

for (var v = 0; v < e_value.amount; v++)
{
	value_default[v] = app.value_default[v]
	value_inherit[v] = 0
	value[v] = value_default[v]
}

for (var t = 0; t < e_value_type.amount; t++)
{
	value_type[t] = false
	value_type_show[t] = true
}

selected = false

keyframe_list = ds_list_create()
keyframe_current = null
keyframe_next = null
keyframe_select = null
keyframe_select_amount = 0

world_pos = point3D(0, 0, 0)
world_pos_rotate = point3D(0, 0, 0)
world_pos_2d = point2D(0, 0)
world_pos_2d_error = false

level = 0
parent = null
parent_is_selected = false
lock_bend = true
tree_array = 0
tree_list = ds_list_create()
tree_extend = false

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
wind_terrain = true

particle_list = null

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

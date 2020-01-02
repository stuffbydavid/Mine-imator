/// tl_event_create()
/// @desc Create event of a timeline.

save_id = ""
save_id = save_id_create()
loaded = false

type = null
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
model_shape_vbuffer_map = null
model_shape_alpha_map = null
part_of = null
part_list = null
part_root = null
scenery_animate = false

for (var v = 0; v < e_value.amount; v++)
{
	value_default[v] = app.value_default[v]
	value_inherit[v] = value_default[v]
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
colors_ext = false
part_mixing_shapes = false

level = 0
parent = null
parent_is_selected = false
lock_bend = true
tree_array = 0
tree_list = ds_list_create()
tree_extend = false

inherit_position = true
inherit_rotation = true
inherit_rot_point = false
inherit_scale = true
inherit_alpha = false
inherit_color = false
inherit_visibility = true
inherit_bend = false
inherit_texture = false
inherit_glow_color = true
inherit_select = false
scale_resize = true
rot_point_custom = false
rot_point = point3D(0, 0, 0)
rot_point_render = point3D(0, 0, 0)
backfaces = false
texture_blur = false
texture_filtering = false
shadows = true
ssao = true
glow = false
glow_texture = true
only_render_glow = false
fog = true
wind = false
wind_terrain = true
hq_hiding = false
lq_hiding = false
foliage_tint = false
bleed_light = false
blend_mode = "normal"

particle_list = null

cam_surf_required = false
cam_surf = null
cam_surf_tmp = null
cam_goalzoom = null

matrix = 0
update_matrix = true
bend_rot_last = vec3(0)
bend_model_part_last = null

// Only used if the timeline is a banner special block in a schematic
is_banner = false
banner_base_color = null
banner_pattern_list = null
banner_color_list = null

banner_skin = null

text_vbuffer = null
text_texture = null
text_string = ""
text_res = null
text_3d = false

item_vbuffer = null
item_slot = 0
item_res = null
item_3d = true
item_custom_slot = false

render_res = null
model_tex = null

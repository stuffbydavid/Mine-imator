/// temp_event_create()
/// @desc Create event of templates.

function temp_event_create()
{
	save_id = ""
	save_id = save_id_create()
	loaded = false
	creator = temp_creator
	
	type = null
	name = ""
	display_name = ""
	count = 0
	rot_point = point3D(0, 0, 0)
	
	model = null
	model_name = default_model
	model_tex = null
	model_tex_material = null
	model_tex_normal = null
	
	model_texture_name_map = null
	model_texture_material_name_map = null
	model_tex_normal_name_map = null
	
	model_shape_texture_name_map = null
	model_shape_texture_material_name_map = null
	model_shape_tex_normal_name_map = null
	
	model_color_name_map = null
	model_color_map = null
	model_shape_vbuffer_map = null
	model_shape_alpha_map = null
	model_hide_list = null
	model_shape_hide_list = null
	model_file = null
	model_state = array()
	model_part_name = ""
	model_part = null
	
	model_use_blend_color = false
	model_blend_color = c_white
	model_blend_color_default = model_blend_color
	
	load_update_tree = false
	
	pattern_type = ""
	pattern_base_color = minecraft_get_color("dye:white")
	pattern_pattern_list = array()
	pattern_color_list = array()
	pattern_skin = null
	
	armor_array = []
	array_add(armor_array, ["none", minecraft_get_color("other:leather"), "none", minecraft_armor_trim_material_list[|0]])
	array_add(armor_array, ["none", minecraft_get_color("other:leather"), "none", minecraft_armor_trim_material_list[|0]])
	array_add(armor_array, ["none", minecraft_get_color("other:leather"), "none", minecraft_armor_trim_material_list[|0]])
	array_add(armor_array, ["none", minecraft_get_color("other:leather"), "none", minecraft_armor_trim_material_list[|0]])
	armor_skin_array = [null, null, null, null]
	
	item_tex = null
	item_tex_material = null
	item_tex_normal = null
	item_slot = ds_list_find_index(mc_assets.item_texture_list, default_item)
	item_vbuffer = null
	item_3d = true
	item_face_camera = false
	item_bounce = false
	item_spin = false
	legacy_item_sheet = true
	
	block_name = default_block
	block_state = array()
	
	block_tex = null
	block_tex_material = null
	block_tex_normal = null
	
	block_vbuffer = null
	block_repeat_enable = false
	block_repeat = vec3(1)
	block_randomize = true
	
	scenery = null
	
	shape_vbuffer = null
	shape_tex = null
	shape_tex_material = null
	shape_tex_normal = null
	shape_tex_mapped = false
	shape_tex_hoffset = 0
	shape_tex_voffset = 0
	shape_tex_hrepeat = 1
	shape_tex_vrepeat = 1
	shape_tex_hmirror = 0
	shape_tex_vmirror = 0
	shape_closed = true
	shape_invert = false
	shape_smooth = true
	shape_detail = 32
	shape_face_camera = false
	
	text_font = null
	text_3d = false
	text_face_camera = false
}

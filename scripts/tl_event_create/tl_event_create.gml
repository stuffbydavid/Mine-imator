/// tl_event_create()
/// @desc Create event of a timeline.

function tl_event_create()
{
	save_id = ""
	save_id = save_id_create()
	loaded = false
	
	type = null
	type_name = ""
	name = ""
	display_name = ""
	temp = null
	text = text_get("timelineeditortextsample")
	color_tag = null
	lock = false
	hide = false
	ghost = false
	delete_ready = false
	depth = 0
	
	model_part = null
	model_part_name = ""
	model_shape_vbuffer_map = null
	model_shape_alpha_map = null
	model_shape_cache_list = null
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
	
	show_tool_position = true
	
	selected = false
	
	keyframe_list = ds_list_create()
	keyframe_prev = null
	keyframe_current = null
	keyframe_next = null
	keyframe_select = null
	keyframe_select_amount = 0
	keyframe_progress = 0
	keyframe_animate = false
	keyframe_index = 0
	keyframe_current_values = null
	keyframe_next_values = null
	
	world_pos = point3D(0, 0, 0)
	world_pos_rotate = point3D(0, 0, 0)
	world_pos_2d = point2D(0, 0)
	world_pos_2d_error = false
	colors_ext = false
	part_mixing_shapes = false
	
	level = 0
	level_display = []
	parent = null
	parent_filter = null
	parent_is_selected = false
	lock_bend = true
	tree_array = 0
	tree_list = ds_list_create()
	tree_list_filter = ds_list_create()
	tree_extend = false
	tree_contents = array_create(e_tl_type.AMOUNT - 1)
	list_mouseon = false
	
	inherit_position = true
	inherit_rotation = true
	inherit_rot_point = false
	inherit_scale = true
	inherit_alpha = false
	inherit_color = false
	inherit_visibility = true
	inherit_bend = false
	inherit_texture = false
	inherit_surface = true
	inherit_subsurface = true
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
	blend_mode = "normal"
	
	particle_list = null
	
	cam_surf_required = false
	cam_surf = null
	cam_surf_tmp = null
	cam_goalzoom = null
	
	matrix = 0
	matrix_render = MAT_IDENTITY
	update_matrix = true
	bend_rot_last = vec3(0)
	bend_model_part_last = null
	model_clear_bend_cache = false
	
	// Only used if the timeline is a banner special block in scenery
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
	text_halign_prev = "center"
	text_valign_prev = "center"
	text_aa_prev = true
	
	item_vbuffer = null
	item_slot = 0
	item_res = null
	item_material_res = null
	item_normal_res = null
	item_3d = true
	item_custom_slot = false
	
	render_res_diffuse = null
	render_res_material = null
	render_res_normal = null
	
	tex_obj = null
	tex_obj_prev = -5
	
	model_tex = null
	model_tex_material = null
	model_tex_normal = null
	
	// Bounding box info
	bounding_box = new bbox()
	bounding_box_matrix = new bbox()
	bounding_box_children = new bbox()
	bounding_box_children_list = 0
	
	scenery_repeat_bounding_box = null
	bounding_box_update = true
	render_visible = true
	model_timeline_list = null
	
	// Path
	path_update = false
	path_points_list = ds_list_create()
	path_smooth = true
	path_closed = false
	path_detail = 6
	
	path_table = []
	path_table_matrix = []
	path_length = 1
	
	path_shape_generate = false
	path_shape_radius = 8
	path_shape_tex_length = 16
	path_shape_invert = false
	path_shape_tube = false
	path_shape_detail = 6
	path_shape_smooth_segments = true
	path_shape_smooth_ring = false
	
	path_vbuffer = null
	path_select_vbuffer = null
	
	tl_update_path()
}

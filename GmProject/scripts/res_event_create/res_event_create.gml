/// res_event_create()
/// @desc Create event of a resource.

function res_event_create()
{
	save_id = ""
	save_id = save_id_create()
	loaded = false
	creator = res_creator
	
	replaced = false
	ready = true
	
	type = null
	filename = ""
	display_name = ""
	count = 0
	copied = false
	pattern_type = ""
	
	model_file = null
	model_format = null
	model_texture = null
	
	model_texture_map = null
	model_texture_material_map = null
	model_tex_normal_map = null
	
	model_block_map = null
	
	model_texture_name_map = null
	model_texture_material_name_map = null
	model_tex_normal_name_map = null
	
	model_shape_texture_name_map = null
	model_shape_texture_material_name_map = null
	model_shape_tex_normal_name_map = null
	
	model_color_name_map = null
	model_color_map = null
	model_shape_hide_list = null
	model_shape_vbuffer_map = null
	model_shape_alpha_map = null
	player_skin = false
	pack_format = e_minecraft_pack.LATEST
	
	block_sheet_texture = null
	block_sheet_texture_material = null
	block_sheet_tex_normal = null
	
	block_sheet_ani_texture = null
	block_sheet_ani_texture_material = null
	block_sheet_ani_tex_normal = null
	
	block_sheet_depth_list = null
	block_sheet_ani_depth_list = null
	block_preview_texture = null
	
	colormap_grass_texture = null
	colormap_foliage_texture = null
	colormap_dry_foliage_texture = null
	
	color_grass = null
	color_foliage = null
	color_dry_foliage = null
	color_water = null
	color_leaves_oak = null
	color_leaves_spruce = null
	color_leaves_birch = null
	color_leaves_jungle = null
	color_leaves_acacia = null
	color_leaves_dark_oak = null
	color_leaves_mangrove = null
	
	sun_texture = null
	moon_textures = [null, null, null, null, null, null, null, null]
	//moonphases_texture = null
	//moon_texture[0] = null
	clouds_texture = null
	glint_armor_texture = null
	glint_item_texture = null
	
	item_sheet_texture = null
	item_sheet_texture_material = null
	item_sheet_tex_normal = null
	item_sheet_size = vec2(32, 32)
	
	particles_texture[0] = null
	particles_texture[1] = null
	
	particle_texture_atlas_map = null
	particle_texture_uvs_map = null
	particle_texture_pixeluvs_map = null
	
	block_vbuffer = null
	
	scenery_tl_add = null
	scenery_tl_list = null
	scenery_size = vec3(0)
	world_regions_dir = ""
	world_box_start = null
	world_box_end = null
	world_filter_mode = 0
	world_filter_array = array()
	scenery_download_skins = true
	scenery_structure = false
	scenery_integrity = 1
	scenery_integrity_invert = false
	scenery_palette = 0
	scenery_palette_size = 0
	scenery_randomize = true
	
	texture = null
	
	font = null
	font_preview = null
	font_no_aa = null
	font_minecraft = false
	
	sound_buffer = null
	sound_index = null
	sound_samples = 0
	sound_max_sample = array()
	sound_min_sample = array()
	
	load_stage = ""
	load_audio_sample = 0
	
	material_format = e_material.FORMAT_LABPBR
}

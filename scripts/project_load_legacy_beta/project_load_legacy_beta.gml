/// project_load_legacy_beta(loadbackground)
/// @arg loadbackground
/// @desc Load a project made in Mine-imator BETA 0.5, 0.6 or 0.7 DEMO

var load = new(obj_data);

with (load)
{
	lib_amount = buffer_read_short()
	for (var a = 0; a < lib_amount; a++)
	{
		lib_type[a] = buffer_read_string_int()
		lib_name[a] = buffer_read_string_int()
		
		lib_char_skin[a] = buffer_read_short() - 1
		var modelid = buffer_read_byte();
		lib_char_model_legacy_name[a] = project_load_legacy_model_name(modelid)
			
		if (is_string(lib_char_model_legacy_name[a]))
		{
			var modelmap = legacy_model_name_map[?lib_char_model_legacy_name[a]];
			if (!is_undefined(modelmap))
			{
				lib_char_model_name[a] = modelmap[?"name"]
				if (!is_undefined(modelmap[?"state"]))
					lib_char_model_state[a] = string_get_state_vars(modelmap[?"state"])
				else
					lib_char_model_state[a] = array()
			}
			else
			{
				lib_char_model_name[a] = ""
				lib_char_model_state[a] = array()
				log("Could not convert model name", lib_char_model_legacy_name[a])
			}
		}
		else
			log("Could not convert model ID", modelid)
		
		lib_item_type[a] = 0
		lib_item_bounce[a] = true
		lib_item_face[a] = true
		
		switch (buffer_read_byte())
		{
			case 1:
				lib_item_bounce[a] = true
				lib_item_type[a] = true
				break
			
			case 2:
				lib_item_bounce[a] = false
				lib_item_face[a] = true
				break
			
			case 3: 
				lib_item_bounce[a] = true
				lib_item_face[a] = false
				break
			
			case 4:
				lib_item_bounce[a] = false
				lib_item_face[a] = false
				break
		}
		
		if (lib_item_type[a])
		{
			lib_item_bounce[a] = 0
			lib_item_face[a] = 0
		}
		
		lib_item_tex[a] = buffer_read_short() - 1
		lib_item_x[a] = buffer_read_short()
		lib_item_y[a] = buffer_read_short()
		
		lib_block_id[a] = buffer_read_short()
		lib_block_data[a] = buffer_read_byte()
		lib_block_tex[a] = buffer_read_short() - 1
		
		lib_scenery_source[a] = filename_name(string_replace_all(buffer_read_string_int(), "/", "\\"))
		lib_scenery_tex[a] = buffer_read_short() - 1
		
		for (var b = 0; b < 3; b++)
		{
			lib_rotx[a, b] = buffer_read_double()
			lib_roty[a, b] = buffer_read_double()
			lib_rotz[a, b] = buffer_read_double()
		}
		
		lib_rotpoint[a] = point3D(0, 0, 0)
	}
	
	tl_amount = buffer_read_short()
	for (a = 0; a < tl_amount; a++)
	{
		tl_type[a] = buffer_read_string_int()
		tl_lib[a] = buffer_read_short()
		tl_visible[a] = buffer_read_byte()
		tl_show[a] = buffer_read_byte()
		
		tl_lock[a] = buffer_read_byte()
		tl_lock_parent[a] = buffer_read_short()
		tl_lock_part[a] = buffer_read_byte()
		if (load_format > e_project.FORMAT_05)
			tl_lock_part_bend[a] = buffer_read_byte()
		else
			tl_lock_part_bend[a] = false
			
		tl_color[a] = buffer_read_int()
		
		tl_parts[a] = 1
		if (tl_type[a] = "char" || tl_type[a] = "spblock")
		{
			var modelname = lib_char_model_name[tl_lib[a]]
			if (modelname = "spider" || modelname = "cave_spider")
				tl_parts[a] = 7
			else if (modelname = "ghast")
				tl_parts[a] = 8
			else if (modelname = "squid")
				tl_parts[a] = 6
			else if (modelname = "wither")
				tl_parts[a] = 6
			else
			{
				var modelpartlist = legacy_model_part_map[?modelname];
				if (!is_undefined(modelpartlist))
					tl_parts[a] = ds_list_size(modelpartlist) + 1
				else
					log("Could get number of parts for ", lib_char_model_legacy_name[tl_lib[a]])
			}
		}
	
		if (load_format = e_project.FORMAT_05)
		{
			tl_values[a] = buffer_read_byte() div tl_parts[a]
			tl_acts[a] = buffer_read_byte() div tl_parts[a]
		}
		else
		{
			tl_values[a] = 13
			tl_acts[a] = 6
		}
	
		tl_keyframes[a] = buffer_read_short()
		for (var b = 0; b < tl_keyframes[a]; b++)
		{
			with (new(obj_data))
			{
				pos = buffer_read_int()
				
				for (var c = 0; c < load.tl_values[a] * load.tl_parts[a]; c++)
					value[c] = buffer_read_double()
				
				for (var c = 0; c < load.tl_acts[a] * load.tl_parts[a]; c++)
					buffer_read_byte()
				
				for (var c = 0; c < 3; c++)
					set[c] = buffer_read_byte()
					
				load.tl_keyframe[a, b] = id
			}
		}
		
		tl_tl[a] = null
	}
		
	skin_amount = buffer_read_short() - 1
	for (var a = 0; a < skin_amount; a++)
		skin_name[a] = filename_name(buffer_read_string_int())
		
	item_amount = buffer_read_short() - 1
	for (var a = 0; a < item_amount; a++)
		item_name[a] = filename_name(buffer_read_string_int())
		
	ter_amount = buffer_read_short() - 1
	for (var a = 0; a < ter_amount; a++)
		ter_name[a] = filename_name(buffer_read_string_int())
		
	bg_select = buffer_read_short() - 1
	bg_amount = buffer_read_short() - 1
	for (var a = 0; a < bg_amount; a++)
		bg_name[a] = filename_name(buffer_read_string_int())
	debug_indent--
		
	bg_show = buffer_read_byte()
	bg_stretch = buffer_read_byte()
	bg_box = buffer_read_byte()
	bg_ground_show = buffer_read_byte()
	bg_ground_tex = buffer_read_short() - 1
	bg_ground_x = buffer_read_short()
	bg_ground_y = buffer_read_short()
	
	sky_color = buffer_read_int()
	sky_time = buffer_read_double()
	sky_light = buffer_read_byte()
	
	lights_enable = buffer_read_byte()
	lights_amount = buffer_read_short()
	for (var a = 0; a < lights_amount; a++)
	{
		light_x[a] = buffer_read_int()
		light_y[a] = buffer_read_int()
		light_z[a] = buffer_read_short()
		light_r[a] = buffer_read_short()
		light_c[a] = buffer_read_int()
	}
	
	camfrom[X] = buffer_read_double()
	camfrom[Y] = buffer_read_double()
	camfrom[Z] = buffer_read_double()
	camto[X] = buffer_read_double()
	camto[Y] = buffer_read_double()
	camto[Z] = buffer_read_double()
	camanglexy = buffer_read_double()
	camanglez = buffer_read_double()
	camzoom = buffer_read_double()
	tempo = buffer_read_byte()
	loop = buffer_read_byte()
	timelinepos = buffer_read_int()
	timelinescrollh = buffer_read_int()
	timelinezoom = buffer_read_byte()
}

var loadid = 0;

// Parse skins
for (var a = 0; a < load.skin_amount; a++)
{
	with (new(obj_resource))
	{
		loaded = true
		load_id = loadid++
		save_id_map[?load_id] = load_id
		
		type = e_res_type.SKIN
		filename = load.skin_name[a]
		
		// Used as skin?
		player_skin = false
		for (var b = 0; b < load.lib_amount; b++)
		{
			if (load.lib_char_skin[b] = a)
			{
				player_skin = true
				break
			}
		}
		
		load.skin_res[a] = id
		sortlist_add(app.res_list, id)
	}
}

// Parse item sheet
for (var a = 0; a < load.item_amount; a++)
{
	with (new(obj_resource))
	{
		loaded = true
		load_id = loadid++
		save_id_map[?load_id] = load_id
		
		type = e_res_type.ITEM_SHEET
		filename = load.item_name[a]
		item_sheet_size = vec2(16, 16)
		
		load.item_res[a] = id
		sortlist_add(app.res_list, id)
	}
}

// Parse terrain sheets
for (var a = 0; a < load.ter_amount; a++)
{
	with (new(obj_resource))
	{
		loaded = true
		load_id = loadid++
		save_id_map[?load_id] = load_id
		
		type = e_res_type.LEGACY_BLOCK_SHEET
		filename = load.ter_name[a]
		
		load.ter_res[a] = id
		sortlist_add(app.res_list, id)
	}
}

// Parse background image
for (var a = 0; a < load.bg_amount; a++)
{
	with (new(obj_resource))
	{
		loaded = true
		load_id = loadid++
		save_id_map[?load_id] = load_id
		
		type = e_res_type.TEXTURE
		filename = load.bg_name[a]
		
		load.bg_res[a] = id
		sortlist_add(app.res_list, id)
	}
}

// Parse library
for (var a = 0; a < load.lib_amount; a++)
{
	if (load.lib_type[a] = "light")
		continue
		
	with (new(obj_template))
	{
		loaded = true
		load_id = loadid++
		save_id_map[?load_id] = load_id
		
		type = ds_list_find_index(temp_type_name_list, load.lib_type[a])
		name = load.lib_name[a]
		
		// Characters
		switch (type)
		{
			case e_temp_type.CHARACTER:
			case e_temp_type.SPECIAL_BLOCK:
			{
				model_name = load.lib_char_model_name[a]
				model_state = array_copy_1d(load.lib_char_model_state[a])
				temp_update_model()
				
				if (load.lib_char_skin[a] > -1)
					model_tex = load.skin_res[load.lib_char_skin[a]].load_id
				else
					model_tex = save_id_get(mc_res)
					
				break
			}
			
			case e_temp_type.ITEM:
			{
				item_3d = load.lib_item_type[a]
				item_face_camera = load.lib_item_face[a]
				item_bounce = load.lib_item_bounce[a]
				item_slot = load.lib_item_y[a] * 16 + load.lib_item_x[a]
				
				if (load.lib_item_tex[a] > -1)
					item_tex = load.item_res[load.lib_item_tex[a]].load_id
				else
					item_tex = save_id_get(mc_res)
				
				load.lib_rotpoint[a] = point3D(load.lib_rotx[a, 0], load.lib_roty[a, 0], load.lib_rotz[a, 0])
				break
			}
			
			case e_temp_type.BLOCK:
			{
				var block = mc_assets.block_legacy_id_map[?load.lib_block_id[a]];
				if (!is_undefined(block))
				{
					block_name = block.name
					block_state = array_copy_1d(block.legacy_data_state[load.lib_block_data[a]])
				}
				
				if (load.lib_block_tex[a] > -1)
					block_tex = load.ter_res[load.lib_block_tex[a]].load_id
				else
					block_tex = save_id_get(mc_res)
					
				load.lib_rotpoint[a] = point3D(load.lib_rotx[a, 1], load.lib_roty[a, 1], load.lib_rotz[a, 1])
				break
			}
			
			case e_temp_type.SCENERY:
			{
				if (load.lib_scenery_source[a] != "")
				{
					with (new(obj_resource))
					{
						loaded = true
						load_id = loadid++
						save_id_map[?load_id] = load_id
		
						type = e_res_type.SCHEMATIC
						filename = filename_name(load.lib_scenery_source[a])
		
						other.scenery = load_id
						sortlist_add(app.res_list, id)
					}
				}
				
				if (load.lib_scenery_tex[a] > -1)
					block_tex = load.ter_res[load.lib_scenery_tex[a]].load_id
				else
					block_tex = save_id_get(mc_res)
				
				load.lib_rotpoint[a] = point3D(load.lib_rotx[a, 2], load.lib_roty[a, 2], load.lib_rotz[a, 2])
				break
			}
		}
		
		load.lib_temp[a] = id
		sortlist_add(app.lib_list, id)
	}
}

// Parse timelines
for (var a = 0; a < load.tl_amount; a++)
{
	var tl, lib, modelpartlist;
	if (a = 0)
	{
		if (load.tl_keyframes[a] = 0)
			continue
		
		tl = new(obj_timeline)
		tl.type = e_tl_type.CAMERA
	}
	else if (load.tl_type[a] = "light")
	{
		tl = new(obj_timeline)
		tl.type = e_tl_type.POINT_LIGHT
	}
	else
	{
		tl = new(obj_timeline)
		lib = load.tl_lib[a]
		tl.temp = load.lib_temp[lib]
		tl.type = ds_list_find_index(tl_type_name_list, load.tl_type[a])
	}
	
	with (tl)
	{
		loaded = true
		load_id = loadid++
		save_id_map[?load_id] = load_id
		
		hide = !load.tl_visible[a]
		color = load.tl_color[a]
		inherit_visibility = false
		inherit_rot_point = false
		parent = "root"
		parent_tree_index = null
		
		// Create parts
		if (type = e_tl_type.CHARACTER || type = e_tl_type.SPECIAL_BLOCK)
		{
			part_list = ds_list_create()
			if (temp.model_file != null)
				for (var p = 0; p < ds_list_size(temp.model_file.file_part_list); p++)
					if (ds_list_find_index(temp.model_hide_list, temp.model_file.file_part_list[|p].name) = -1)
						ds_list_add(part_list, tl_new_part(temp.model_file.file_part_list[|p]))
		
			ds_list_clear(tree_list)
		}
		
		// Set rotation point
		else if (type = e_tl_type.ITEM || type = e_tl_type.BLOCK || type = e_tl_type.SCENERY) 
		{
			rot_point_custom = true
			rot_point = point3D_copy(load.lib_rotpoint[lib])
		}
		
		// Go through parts
		for (var b = 0; b < load.tl_parts[a]; b++)
		{
			var tl = id;
			
			// Choose target timeline
			if (b > 0)
			{
				var modelpartlist = legacy_model_part_map[?temp.model_name];
				if (ds_list_valid(modelpartlist) && b - 1 < ds_list_size(modelpartlist))
					tl = tl_part_find(modelpartlist[|b - 1])
				
				if (tl = null) // Part not found
					tl = id
			}
				
			// Keyframes
			for (var c = 0; c < load.tl_keyframes[a]; c++)
			{
				var readkf = load.tl_keyframe[a, c];
					
				with (new(obj_keyframe))
				{
					loaded = true
					position = readkf.pos
					timeline = tl
					selected = false
					sound_play_index = null
			
					for (var v = 0; v < e_value.amount; v++)
						value[v] = app.value_default[v]
			
					for (var v = 0; v < load.tl_values[a]; v++)
					{
						var vid = project_load_legacy_beta_value_id(tl.type, v);
						if (vid > -1)
							value[vid] = project_load_legacy_beta_value(vid, readkf.value[b * load.tl_values[a] + v])
					}
					
					value[e_value.TRANSITION] = project_load_legacy_beta_value(e_value.TRANSITION, readkf.set[0])
					
					if (other.type = e_tl_type.CAMERA)
					{
						value[e_value.CAM_ROTATE] = true
						value[e_value.ROT_X] = value[e_value.CAM_ROTATE_ANGLE_Z]
						value[e_value.ROT_Z] = value[e_value.CAM_ROTATE_ANGLE_XY]
					}
					else
						value[e_value.VISIBLE] = readkf.set[1]
					
					ds_list_add(tl.keyframe_list, id)
				}
			}
		}
		
		// Free dummy keyframes
		for (var c = 0; c < load.tl_keyframes[a]; c++)
			with (load.tl_keyframe[a, c])
				instance_destroy()
		
		// Set IDs
		if (part_list != null)
		{
			for (var p = 0; p < ds_list_size(part_list); p++)
			{
				with (part_list[|p])
				{
					loaded = true
					load_id = loadid++
					save_id_map[?load_id] = load_id
					
					part_of = part_of.load_id
					parent = parent.load_id
					parent_tree_index = null
				}
			}
		}
		
		load.tl_tl[a] = id
	}
}

// Hierarchy
for (var a = 0; a < load.tl_amount; a++)
{
	if (load.tl_lock_parent[a] < 0 || !load.tl_lock[a])
		continue
	
	// Find parent
	var par = load.tl_tl[load.tl_lock_parent[a]];
	
	// Find bodypart from ID
	var partid = load.tl_lock_part[a] - 1;
	if (par.part_list != null && partid > -1)
	{
		var modelpartlist, newpar;
		modelpartlist = legacy_model_part_map[?par.temp.model_name];
		if (ds_list_valid(modelpartlist) && partid < ds_list_size(modelpartlist))
			with (par)
				newpar = tl_part_find(modelpartlist[|partid])
				
		if (newpar != null)
			par = newpar
	}
	
	with (load.tl_tl[a])
	{
		lock_bend = load.tl_lock_part_bend[a]
		parent = par.load_id
		parent_tree_index = null
	}
}

with (obj_timeline)
	if (loaded && temp != null)
		temp = temp.load_id

// Background and camera
if (argument0)
{
	// Image
	if (load.bg_select > -1)
		background_image = load.bg_res[load.bg_select].load_id
	
	background_image_show = load.bg_show
	background_image_stretch = load.bg_stretch
	background_image_box = load.bg_box
	
	// Ground
	background_ground_show = load.bg_ground_show
	if (load.bg_ground_tex > -1)
	{
		background_ground_tex.count--
		background_ground_tex = load.ter_res[load.bg_ground_tex].load_id
	}
	else
		background_ground_tex = "default"
	
	var oldslot, legacyname, newslot;
	oldslot = load.bg_ground_y * 16 + load.bg_ground_x
	if (load_format = e_project.FORMAT_07_DEMO)
		legacyname = legacy_block_07_demo_texture_list[|oldslot]
	else
		legacyname = legacy_block_05_texture_list[|oldslot]
		
	newslot = ds_list_find_index(mc_assets.block_texture_list, legacyname)
	if (newslot >= 0)
		background_ground_slot = newslot
	else // Animated?
	{
		newslot = ds_list_find_index(mc_assets.block_texture_ani_list, legacyname)
		if (newslot >= 0)
			background_ground_slot = ds_list_size(mc_assets.block_texture_list) + newslot
	}
	
	// Sky
	background_sky_color = load.sky_color
	background_sky_time = load.sky_time
	
	// Lights
	view_main.lights = load.sky_light
	
	// Work camera
	cam_work_focus[X] = load.camto[X]
	cam_work_focus[Y] = load.camto[Y]
	cam_work_focus[Z] = load.camto[Z]
	cam_work_angle_xy = load.camanglexy
	cam_work_angle_z = load.camanglez
	cam_work_zoom = load.camzoom
	cam_work_zoom_goal = cam_work_zoom
	cam_work_angle_look_xy = cam_work_angle_xy
	cam_work_angle_look_z = -cam_work_angle_z
	camera_work_set_from()
	
	// Playback
	project_tempo = load.tempo
	timeline_repeat = load.loop
	
	background_loaded = true
}

// Clean up
with (load)
	instance_destroy()


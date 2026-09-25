/// project_load_find_save_ids()
/// @desc Updates the references to objects within the project.

function project_load_find_save_ids(isproject = false)
{
	// Look for legacy (numeric) or duplicate save IDs and create new if necessary
	var key = ds_map_find_first(save_id_map);
	while (!is_undefined(key))
	{
		if (save_id_map[?key] != "root" && save_id_map[?key] != "default") // Skip removed objects
		{
			// Avoid duplicates in existing objects or previously generated save ids
			if (save_id_map[?key] != project_pack_res && (is_real(save_id_map[?key]) || save_id_find(save_id_map[?key]) != null))
			{
				var sid;
				do
					sid = save_id_create()
				until (is_undefined(ds_map_find_value(save_id_map, sid)))
				save_id_map[?key] = sid
			}
		}
		key = ds_map_find_next(save_id_map, key)
	}
	
	save_id_map[? null] = null
	save_id_map[?"root"] = "root"
	save_id_map[?"default"] = project_pack_res
	save_id_map[?"minecraft"] = "minecraft"
	save_id_map[?project_pack_res] = project_pack_res
	
	// Set resource IDs
	with (obj_resource)
		if (loaded && !is_undefined(save_id_map[?load_id]))
			save_id = save_id_map[?load_id]
	
	// Set project pack
	if (is_string(project_pack))
	{
		var pack = save_id_find(save_id_map[?project_pack])
		project_pack = pack != null ? pack : mc_res
	}

	// Set background references
	if (background_loaded)
	{
		background_image = save_id_find(save_id_map[?background_image])
		
		background_ground_tex = save_id_find(save_id_map[?background_ground_tex])
		
		background_ground_tex_material = save_id_find(save_id_map[?background_ground_tex_material])
		
		background_ground_tex_normal = save_id_find(save_id_map[?background_ground_tex_normal])
		
		if (load_format >= e_project.FORMAT_100_DEMO_4)
		{
			background_sky_sun_tex = save_id_find(save_id_map[?background_sky_sun_tex])
			background_sky_moon_tex = save_id_find(save_id_map[?background_sky_moon_tex])
			background_sky_clouds_tex = save_id_find(save_id_map[?background_sky_clouds_tex])
		}
	}
	
	// Set timeline IDs
	with (obj_timeline)
		if (loaded && !is_undefined(save_id_map[?load_id]))
			save_id = save_id_map[?load_id]
	
	// Set template IDs and references
	with (obj_template)
	{
		if (!loaded)
			continue
		
		if (!is_undefined(save_id_map[?load_id]))
			save_id = save_id_map[?load_id]
		
		model = save_id_find(save_id_map[?model])
		model_tex = save_id_find(save_id_map[?model_tex])
		model_tex_material = save_id_find(save_id_map[?model_tex_material])
		model_tex_normal = save_id_find(save_id_map[?model_tex_normal])
		item_tex = save_id_find(save_id_map[?item_tex])
		item_tex_material = save_id_find(save_id_map[?item_tex_material])
		item_tex_normal = save_id_find(save_id_map[?item_tex_normal])
		block_tex = save_id_find(save_id_map[?block_tex])
		block_tex_material = save_id_find(save_id_map[?block_tex_material])
		block_tex_normal = save_id_find(save_id_map[?block_tex_normal])
		scenery = save_id_find(save_id_map[?scenery])
		shape_tex = save_id_find(save_id_map[?shape_tex])
		shape_tex_material = save_id_find(save_id_map[?shape_tex_material])
		shape_tex_normal = save_id_find(save_id_map[?shape_tex_normal])
		text_font = save_id_find(save_id_map[?text_font])
		
		// Fix broken references
		if (type = e_temp_type.ITEM && (!instance_exists(item_tex) || item_tex.object_index != obj_resource))
			item_tex = project_pack_res
		
		if (type = e_temp_type.ITEM && (!instance_exists(item_tex_material) || item_tex_material.object_index != obj_resource))
			item_tex_material = project_pack_res
		
		if (type = e_temp_type.ITEM && (!instance_exists(item_tex_normal) || item_tex_normal.object_index != obj_resource))
			item_tex_normal = project_pack_res
		
		if (type = e_temp_type.SCENERY && instance_exists(scenery) && scenery.object_index != obj_resource)
			scenery = null
		
		// Legacy "use a sheet" option conversion
		if (load_format < e_project.FORMAT_110_PRE_1 && type = e_temp_type.ITEM && item_tex != project_pack_res && !legacy_item_sheet)
			item_tex.type = e_res_type.TEXTURE
		
		// Find paths for particle regions
		if (type = e_temp_type.PARTICLE_SPAWNER)
			pc_spawn_region_path = save_id_find(pc_spawn_region_path)
	}
	
	// Set timeline references
	with (obj_timeline)
	{
		if (!loaded)
			continue
		
		temp = save_id_find(save_id_map[?temp])

		// Equipment was formerly saved as a special block
		if (type = e_tl_type.SPECIAL_BLOCK && temp != null && temp.type = e_temp_type.EQUIPMENT)
			type = e_tl_type.EQUIPMENT
		
		// Model part
		part_of = save_id_find(save_id_map[?part_of])
		if (type = e_tl_type.BLOCK && part_of = null && !has_temp)
		{
			block_tex = save_id_find(save_id_map[?block_tex])
			block_tex_material = save_id_find(save_id_map[?block_tex_material])
			block_tex_normal = save_id_find(save_id_map[?block_tex_normal])
		}
		else if (type = e_tl_type.SPECIAL_BLOCK && part_of = null && !has_temp)
		{
			model_tex = save_id_find(save_id_map[?model_tex])
			model_tex_material = save_id_find(save_id_map[?model_tex_material])
			model_tex_normal = save_id_find(save_id_map[?model_tex_normal])
		}
		else if (type = e_tl_type.TEXT && part_of = null && !has_temp)
			text_font = save_id_find(save_id_map[?text_font])
		
		// Part root(Update special blocks in old projects)
		if (load_format < e_project.FORMAT_122)
		{
			if (part_root = null && part_of != null && part_of.type = e_tl_type.SCENERY && type = e_tl_type.SPECIAL_BLOCK)
			{
				part_root = part_of
				project_load_set_part_root(part_of)
			}
		}
		else
			part_root = save_id_find(save_id_map[?part_root])
		
		// Text AA setting
		if (type = e_tl_type.TEXT && has_temp && temp != null && text_aa)
		{
			temp.text_aa = true
			text_aa = false
		}
		
		// Default textures
		if (value_default[e_value.TEXTURE_OBJ] = "none")
			value_default[e_value.TEXTURE_OBJ] = 0
		else if (value_default[e_value.TEXTURE_OBJ] != null)
			value_default[e_value.TEXTURE_OBJ] = save_id_find(save_id_map[?value_default[e_value.TEXTURE_OBJ]])
		
		if (value_default[e_value.TEXTURE_MATERIAL_OBJ] = "none")
			value_default[e_value.TEXTURE_MATERIAL_OBJ] = 0
		else if (value_default[e_value.TEXTURE_MATERIAL_OBJ] != null)
			value_default[e_value.TEXTURE_MATERIAL_OBJ] = save_id_find(save_id_map[?value_default[e_value.TEXTURE_MATERIAL_OBJ]])
		
		if (value_default[e_value.TEXTURE_NORMAL_OBJ] = "none")
			value_default[e_value.TEXTURE_NORMAL_OBJ] = 0
		else if (value_default[e_value.TEXTURE_NORMAL_OBJ] != null)
			value_default[e_value.TEXTURE_NORMAL_OBJ] = save_id_find(save_id_map[?value_default[e_value.TEXTURE_NORMAL_OBJ]])

		if (!animated)
		{
			var references = [e_value.PATH_OBJ, e_value.ATTRACTOR, e_value.IK_TARGET, e_value.IK_TARGET_ANGLE, e_value.SOUND_OBJ, e_value.TEXT_FONT];
			for (var v = 0; v < array_length(references); v++)
			{
				var index = references[v];
				if (value_default[index] != null)
					value_default[index] = save_id_find(save_id_map[?value_default[index]])
			}
			value = array_copy_1d(value_default)
		}
		
		// Glint
		glint_tex = save_id_find(save_id_map[?glint_tex])
		
		// Set part list
		if (part_list != null)
			for (var i = 0; i < ds_list_size(part_list); i++)
				part_list[|i] = save_id_find(save_id_map[?part_list[|i]])
		
		// Set parent
		parent = save_id_find(save_id_map[?parent])
		if (parent = null)
			parent = app
		
		if (!is_array(parent.tree_array)) // Initialize array
			parent.tree_array = array();
		
		if (parent_tree_index < 0)
			parent.tree_array[array_length(parent.tree_array)] = id
		else
			parent.tree_array[parent_tree_index] = id
	}
	
	// Set keyframe references
	with (obj_keyframe)
	{
		if (!loaded)
			continue
		
		value[e_value.PATH_OBJ] = save_id_find(save_id_map[?value[e_value.PATH_OBJ]])
		value[e_value.ATTRACTOR] = save_id_find(save_id_map[?value[e_value.ATTRACTOR]])
		
		// IK targets
		value[e_value.IK_TARGET] = save_id_find(save_id_map[?value[e_value.IK_TARGET]])
		value[e_value.IK_TARGET_ANGLE] = save_id_find(save_id_map[?value[e_value.IK_TARGET_ANGLE]])
		
		if (value[e_value.TEXTURE_OBJ] = "none")
			value[e_value.TEXTURE_OBJ] = 0
		else
			value[e_value.TEXTURE_OBJ] = save_id_find(save_id_map[?value[e_value.TEXTURE_OBJ]])
		
		if (value[e_value.TEXTURE_MATERIAL_OBJ] = "none")
			value[e_value.TEXTURE_MATERIAL_OBJ] = 0
		else
			value[e_value.TEXTURE_MATERIAL_OBJ] = save_id_find(save_id_map[?value[e_value.TEXTURE_MATERIAL_OBJ]])
		
		if (value[e_value.TEXTURE_NORMAL_OBJ] = "none")
			value[e_value.TEXTURE_NORMAL_OBJ] = 0
		else
			value[e_value.TEXTURE_NORMAL_OBJ] = save_id_find(save_id_map[?value[e_value.TEXTURE_NORMAL_OBJ]])
		
		value[e_value.SOUND_OBJ] = save_id_find(save_id_map[?value[e_value.SOUND_OBJ]])
		value[e_value.TEXT_FONT] = save_id_find(save_id_map[?value[e_value.TEXT_FONT]])
	}
	
	// Set particle type IDs and references
	with (obj_particle_type)
	{
		if (!loaded)
			continue
		
		if (!is_undefined(save_id_map[?load_id]))
			save_id = save_id_map[?load_id]
		
		if (temp != particle_sheet && temp != particle_template)
			temp = save_id_find(save_id_map[?temp])
		
		sprite_tex = save_id_find(save_id_map[?sprite_tex])
		sprite_template_tex = save_id_find(save_id_map[?sprite_template_tex])
		
	}
	
	// Set marker IDs
	var markersort = false;
	with (obj_marker)
	{
		if (!loaded || !isproject)
			continue
		
		markersort = true
		if (!is_undefined(save_id_map[?load_id]))
			save_id = save_id_map[?load_id]
		
		ds_list_add(app.timeline_marker_list, id)
	}
	if (markersort)
		marker_list_sort()
	
	// Add to root tree
	for (var i = 0; i < array_length(tree_array); i++)
		if (tree_array[i] > 0)
			ds_list_add(tree_list, tree_array[i])
	
	// Add to timeline trees
	with (obj_timeline)
		for (var i = 0; i < array_length(tree_array); i++)
			if (tree_array[i] > 0)
				ds_list_add(tree_list, tree_array[i])
	
	// Set pre-1.0.0 hide value
	if (load_format < e_project.FORMAT_100_DEBUG)
		for (var t = 0; t < ds_list_size(tree_list); t++)
			with (tree_list[|t])
				tl_update_hide()
	
	// Viewport cameras
	if (view_main.camera != -4 && view_main.camera != -5 && !instance_exists(view_main.camera))
		view_main.camera = save_id_find(view_main.camera)
	
	if (view_second.camera != -4 && view_second.camera != -5 && !instance_exists(view_second.camera))
		view_second.camera = save_id_find(view_second.camera)
}

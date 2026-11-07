function action_tl_create_scenery_temp()
{
	var hobj, roottl;
	if (history_undo || history_redo)
	{
		hobj = history_data
		roottl = save_id_find(hobj.tl_save_id)
	}
	else
	{
		hobj = null
		roottl = tl_edit
	}

	if (roottl = null || !type_is_structure(roottl.type))
		return false

	if (history_undo)
	{
		var building, custom;
		building = (build_structure = roottl)
		custom = build_structure_custom
		
		with (roottl)
			tl_remove_clean()

		with (obj_timeline)
			if (delete_ready)
				instance_destroy()

		with (save_id_find(hobj.temp_save_id))
			instance_destroy()
		
		with (save_id_find(hobj.res_save_id))
			instance_destroy()

		file_delete_lib(project_folder + "/" + hobj.filename)
		file_delete_lib(project_folder + "/" + hobj.filename + ".meshcache")

		with (hobj)
		{
			roottl = history_restore_tl(old_tl)
			history_restore_tl_select()
		}

		// Restore custom structure selection
		if (building)
			action_build_structure(roottl, custom)

		temp_edit = save_id_find(hobj.save_temp_edit)
		res_edit = save_id_find(hobj.save_res_edit)
	}
	else
	{
		var fn, exporting;
		
		if (history_redo)
			fn = project_folder + "/" + hobj.filename
		else
			fn = project_folder + "/" + res_get_world_filename(roottl.display_name, ".schem")

		// Save the default transforms
		var tree, values;
		tree = [ roottl ]
		values = []
		for (var t = 0; t < array_length(tree); t++)
		{
			with (tree[t])
			{
				for (var c = 0; c < ds_list_size(tree_list); c++)
					array_add(tree, tree_list[|c])

				if (t = 0)
					continue

				array_add(values, array_copy_1d(value), false)
				value = array_copy_1d(value_default)
				update_matrix = true
			}
		}

		with (roottl)
		{
			tl_update_matrix()
			exporting = tl_export_schematic(fn)
		}

		// Restore the current frame before handling export errors or saving history
		for (var t = 1; t < array_length(tree); t++)
		{
			tree[t].value = values[t - 1]
			tree[t].update_matrix = true
		}
		
		with (roottl)
			tl_update_matrix()

		if (array_length(exporting) != 3 || !file_exists_lib(fn))
			return false

		if (!history_redo)
		{
			hobj = history_set(action_tl_create_scenery_temp)
			hobj.tl_save_id = roottl.save_id
			hobj.filename = filename_name(fn)
			hobj.origin = exporting[0]
			hobj.saved_tls = exporting[1]
			hobj.hidden_blocks = exporting[2]
			hobj.temp_name = filename_new_ext(hobj.filename, "")
			
			with (hobj)
			{
				old_tl = history_save_tl(roottl)
				history_save_tl_select()
			}
		}

		// Create a separate resource and template for the baked blocks
		res_creator = app
		
		var res = new_obj(obj_resource);
		with (res)
		{
			type = e_res_type.SCHEMATIC
			filename = hobj.filename
			ready = false
			scenery_tl_set = true
			res_add_lists()
		}

		// Enable only timeline types represented by the exported parts
		for (var i = 0; i < array_length(hobj.saved_tls); i++)
		{
			with (save_id_find(hobj.saved_tls[i]))
			{
				var data, tltype;
				data = tl_get_build_block()
				tltype = ""
				
				if (data != null)
					tltype = block_objs[data[0]].tl_type
				else if (type = e_tl_type.SPECIAL_BLOCK)
				{
					var model = mc_assets.model_name_map[?temp.model_name];
					if (!is_undefined(model))
						tltype = model.entity_tl_type
				}

				if (tltype != "" && !array_contains(res.scenery_tl_types, tltype))
					array_add(res.scenery_tl_types, tltype)
			}
		}

		temp_creator = app
		
		var newtemp = new_obj(obj_template);
		with (newtemp)
		{
			type = e_temp_type.SCENERY
			name = hobj.temp_name
			scenery = res

			var textures = (roottl.has_block_tex ? roottl : roottl.temp);
			if (textures != null)
			{
				block_tex = textures.block_tex
				block_tex_material = textures.block_tex_material
				block_tex_normal = textures.block_tex_normal
			}

			temp_update_display_name()
			temp_add_lists()
		}

		if (history_redo)
		{
			res.save_id = hobj.res_save_id
			newtemp.save_id = hobj.temp_save_id
		}
		else
		{
			hobj.res_save_id = res.save_id
			hobj.temp_save_id = newtemp.save_id
		}

		with (roottl)
		{
			for (var s = 0; s < array_length(block_meshes_edit); s++)
				if (block_meshes_edit[s] != null)
					with (block_meshes_edit[s])
						instance_destroy()

			block_meshes = []
			block_meshes_edit = []
			block_meshes_active = []
			blocks_added = []
			for (var i = 0; i < array_length(hobj.hidden_blocks); i++)
				array_add(blocks_added, [ array_copy_1d(hobj.hidden_blocks[i][0]), hobj.hidden_blocks[i][1] ], false)
			
			blocks_added_palette = [ [ 0, 0, false ], [ 0, 0, true ] ]

			// Keep the existing transforms as the exported grid moves to its new origin
			rot_point = vec3_sub(rot_point_render, hobj.origin)
			rot_point_custom = true
			type = e_tl_type.SCENERY
			temp = newtemp
			has_temp = true
			scenery_animate = true
			scenery_animate_create = true
			scenery_part_history = null

			for (var t = 0; t < ds_list_size(tree_list); t++)
			{
				with (tree_list[|t])
				{
					if (!inherit_rot_point || !inherit_position)
						continue

					tl_value_set_vec3(e_value.POS_X, vec3_sub(tl_value_get_vec3(e_value.POS_X), hobj.origin))
					tl_value_set_vec3(e_value.POS_X, vec3_sub(tl_value_get_vec3(e_value.POS_X, true), hobj.origin), true)
					
					with (obj_keyframe)
						if (timeline = other.id)
							tl_value_set_vec3(e_value.POS_X, vec3_sub(tl_value_get_vec3(e_value.POS_X), hobj.origin))
					
					tl_update_values()
				}
			}

			tl_update()
		}

		// Retain the original parts and their keyframes instead of recreating them
		if (roottl.part_list = null)
			roottl.part_list = ds_list_create()

		// Keep parts absent from the export as independent timelines
		with (roottl)
		{
			for (var p = ds_list_size(part_list) - 1; p >= 0; p--)
			{
				var part = part_list[|p];
				if (array_contains(hobj.saved_tls, part.save_id))
					continue

				with (part)
				{
					part_of = null
					part_root = null
					block_timeline = false

					if (part_list != null)
						for (var c = 0; c < ds_list_size(part_list); c++)
							with (part_list[|c])
								if (part_root = roottl)
									part_root = other.id
				}

				ds_list_delete(part_list, p)
			}
		}
		
		for (var i = 0; i < array_length(hobj.saved_tls); i++)
		{
			with (save_id_find(hobj.saved_tls[i]))
			{
				if (part_of != null && part_of != roottl)
					continue

				var data = tl_get_build_block();
				if (data != null && !block_objs[data[0]].timeline)
					continue

				part_of = roottl
				part_root = roottl
				block_timeline = true
				
				if (ds_list_find_index(roottl.part_list, id) < 0)
					ds_list_add(roottl.part_list, id)

				if (part_list != null)
					for (var p = 0; p < ds_list_size(part_list); p++)
						with (part_list[|p])
							if (part_root = other.id)
								part_root = roottl
			}
		}

		load_folder = project_folder
		save_folder = project_folder
		
		if (history_redo)
			save_id_seed = hobj.load_seed
		else
			hobj.load_seed = save_id_seed

		with (res)
			res_load()

		// Cached resources skip the normal timeline and mesh updates after loading
		with (roottl)
		{
			if (res.ready && scenery_animate)
				tl_animate_scenery()

			if (res.ready && array_length(blocks_added) > 0)
				tl_update_block_meshes()
		}

		with (newtemp)
		{
			temp_update_rot_point()
			temp_select_edit(false)
		}
	}

	place_target_tl = null
	place_block_pos = null
	place_pos = null
	
	build_box_render = null

	tl_update_length()
	tl_update_list()
	tl_update_matrix()
	
	app_update_tl_edit()
	
	project_update_counts()
	
	lib_preview.update = true

	return true
}

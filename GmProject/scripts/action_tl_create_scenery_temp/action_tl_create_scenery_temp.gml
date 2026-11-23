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
		
		// Remove the converted hierarchy
		with (roottl)
			tl_remove_clean()

		with (obj_timeline)
			if (delete_ready)
				instance_destroy()

		// Remove the generated template and resource
		with (save_id_find(hobj.temp_save_id))
			instance_destroy()
		
		with (save_id_find(hobj.res_save_id))
			instance_destroy()

		// Delete the generated schematic and its mesh cache
		file_delete_lib(project_folder + "/" + hobj.filename)
		file_delete_lib(project_folder + "/" + hobj.filename + ".meshcache")

		// Restore original hierarchy and timeline selection
		with (hobj)
		{
			roottl = history_restore_tl(old_tl)
			history_restore_tl_select()
		}

		// Restore custom structure selection
		if (building)
			action_build_structure(roottl, custom)

		// Restore the library and resource selections
		temp_edit = save_id_find(hobj.save_temp_edit)
		res_edit = save_id_find(hobj.save_res_edit)
	}
	else
	{
		var fn, exporting;
		
		// Reuse the filename on redo or reserve a unique project filename
		if (history_redo)
			fn = project_folder + "/" + hobj.filename
		else
			fn = project_folder + "/" + res_get_world_filename(roottl.display_name, ".schem")

		// Temporarily use default transforms for the export
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

		// Export the structure in its default state
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

		// Check for export failure
		if (array_length(exporting) != 3 || !file_exists_lib(fn))
			return false

		// Collect the new origin and parts to retain as scenery timelines
		var origin, parts, tltypes;
		origin = exporting[0]
		parts = []
		tltypes = []

		// Enable only timeline types represented by the exported parts
		for (var i = 0; i < array_length(exporting[1]); i++)
		{
			with (save_id_find(exporting[1][i]))
			{
				// Read the block or entity timeline type
				var data, tltype;
				data = tl_get_block_build()
				tltype = ""
				
				if (data != null)
					tltype = block_objs[data[0]].tl_type
				else if (type = e_tl_type.SPECIAL_BLOCK)
				{
					var model = mc_assets.model_name_map[?temp.model_name];
					if (!is_undefined(model))
						tltype = model.entity_tl_type
				}

				if (tltype != "" && !array_contains(tltypes, tltype))
					array_add(tltypes, tltype)

				// Leave parts owned by other timelines with their current owner
				if (part_of != null && part_of != roottl)
					continue

				// Blocks without scenery timelines use hidden mesh cells instead
				if (data = null || block_objs[data[0]].timeline)
					array_add(parts, id)
			}
		}

		res_creator = app

		// Load new resource from export
		var res = new_obj(obj_resource);
		with (res)
		{
			type = e_res_type.SCHEMATIC
			filename = filename_name(fn)
			load_folder = app.project_folder
			save_folder = app.project_folder
			scenery_tl_set = true
			scenery_tl_types = tltypes
			scenery_instant = true
			ready = false
			load_stage = "open"

			if (history_redo)
				save_id = hobj.res_save_id

			while (!ready && load_stage != "")
				res_load_scenery()

			// Remove incomplete assets without changing the original hierarchy
			if (!ready || scenery_size[X] <= 0 || scenery_size[Y] <= 0 || scenery_size[Z] <= 0)
			{
				instance_destroy()
				file_delete_lib(fn)
				file_delete_lib(fn + ".meshcache")
				return false
			}

			res_update_display_name()
			res_add_lists()
		}

		temp_creator = app
		
		// Create a scenery template named after the new resource
		var newtemp = new_obj(obj_template);
		with (newtemp)
		{
			type = e_temp_type.SCENERY
			name = filename_new_ext(filename_name(fn), "")
			scenery = res

			// Keep the template ID stable across undo and redo
			if (history_redo)
				save_id = hobj.temp_save_id

			// Preserve the original block textures
			var textures = (roottl.has_block_tex ? roottl : roottl.temp);
			if (textures != null)
			{
				block_tex = textures.block_tex
				block_tex_material = textures.block_tex_material
				block_tex_normal = textures.block_tex_normal
			}

			// Register the template with its default rotation point
			temp_update_display_name()
			temp_update_rot_point()
			temp_add_lists()
		}

		// Save the original hierarchy once for undo
		if (!history_redo)
		{
			hobj = history_set(action_tl_create_scenery_temp)
			hobj.tl_save_id = roottl.save_id
			hobj.filename = filename_name(fn)
			hobj.res_save_id = res.save_id
			hobj.temp_save_id = newtemp.save_id

			with (hobj)
			{
				old_tl = history_save_tl(roottl)
				history_save_tl_select()
			}
		}

		with (roottl)
		{
			// Clear the old edited meshes
			for (var s = 0; s < array_length(block_meshes_edit); s++)
				if (block_meshes_edit[s] != null)
					with (block_meshes_edit[s])
						instance_destroy()

			// Hide baked mesh cells represented by retained timelines
			block_meshes = []
			block_meshes_edit = []
			block_meshes_active = []
			blocks_added = []
			for (var i = 0; i < array_length(exporting[2]); i++)
				array_add(blocks_added, [ array_copy_1d(exporting[2][i][0]), exporting[2][i][1] ], false)
			
			blocks_added_palette = [ [ 0, 0, false ], [ 0, 0, true ] ]

			// Keep the existing transforms as the exported grid moves to its new origin
			rot_point = vec3_sub(rot_point_render, origin)
			rot_point_custom = true
			type = e_tl_type.SCENERY
			temp = newtemp
			has_temp = true

			// Offset child positions and keyframes to preserve their world placement
			for (var t = 0; t < ds_list_size(tree_list); t++)
			{
				with (tree_list[|t])
				{
					if (!inherit_rot_point || !inherit_position)
						continue

					tl_value_set_vec3(e_value.POS_X, vec3_sub(tl_value_get_vec3(e_value.POS_X), origin))
					tl_value_set_vec3(e_value.POS_X, vec3_sub(tl_value_get_vec3(e_value.POS_X, true), origin), true)
					
					with (obj_keyframe)
						if (timeline = other.id)
							tl_value_set_vec3(e_value.POS_X, vec3_sub(tl_value_get_vec3(e_value.POS_X), origin))
					
					tl_update_values()
				}
			}

			tl_update()

			// Retain the original parts and their keyframes instead of recreating them
			if (part_list = null)
				part_list = ds_list_create()

			// Keep unsupported parts through future resource reloads
			for (var p = ds_list_size(part_list) - 1; p >= 0; p--)
			{
				var part = part_list[|p];
				if (array_contains(parts, part))
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

			// Attach supported block timelines to the new scenery resource
			for (var i = 0; i < array_length(parts); i++)
			{
				with (parts[i])
				{
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

			// Keep IDs stable for any missing timelines created during conversion
			if (history_redo)
				save_id_seed = hobj.part_seed
			else
				hobj.part_seed = save_id_seed

			// Create missing source timelines without removing any retained parts
			scenery_animate_create = true
			scenery_part_history = null
			tl_scenery_animate(false)
		}

		// Select the new template in the library
		with (newtemp)
			temp_select_edit(false)
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

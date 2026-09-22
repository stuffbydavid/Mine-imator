/// action_build_place()

function action_build_place()
{
	var hobj, tl, placetarget, placeparent;
	placetarget = null
	placeparent = null

	// Suspend the active parent highlight during undo and redo
	if (place_build && (history_undo || history_redo))
	{
		placetarget = place_target_tl
		placeparent = place_target_tl_part_of
		if (placeparent != null && instance_exists(placeparent))
			with (placeparent)
				tl_mark_place_target(false)
		place_target_tl = null
		place_target_tl_part_of = null
	}

	if (history_undo)
	{
		tl = save_id_find(history_data.spawn_save_id)
		if (tl != null)
			with (tl)
				tl_remove_clean()

		if (history_data.structure_save_id != "")
		{
			var structure = save_id_find(history_data.structure_save_id);
			if (structure != null)
			{
				if (build_structure = structure)
					action_build_structure(null)
				with (structure)
					tl_remove_clean()
			}
		}

		with (obj_timeline)
			if (delete_ready)
				instance_destroy()
	}
	else
	{
		if (history_redo)
		{
			// Recreate the placed block from its saved build settings
			hobj = history_data
			if (hobj.structure_save_id != "")
			{
				var structure = new_tl(e_tl_type.STRUCTURE);
				structure.animated = false
				structure.save_id = hobj.structure_save_id
				structure.name = hobj.structure_name
				with (structure)
				{
					tl_value_set_vec3(e_value.POS_X, hobj.structure_pos)
					tl_value_set_vec3(e_value.POS_X, hobj.structure_pos, true)
					tl_update_display_name()
				}
					
				if (place_build)
					action_build_structure(structure)
			}
			
			tl = tl_new_block(hobj.build_type, hobj.build_save_obj, true)
			with (tl)
			{
				var parent = save_id_find(hobj.parent_save_id);
				if (parent = null)
					parent = app
				tl_set_parent(parent)
				tl_value_copy_vec3(e_value.POS_X, value_default, hobj.value_default)
				tl_value_copy_vec3(e_value.ROT_X, value_default, hobj.value_default)
				tl_value_copy_vec3(e_value.SCA_X, value_default, hobj.value_default)
				tl_value_copy_vec3(e_value.POS_X, value, value_default)
				tl_value_copy_vec3(e_value.ROT_X, value, value_default)
				tl_value_copy_vec3(e_value.SCA_X, value, value_default)
			}
		}
		else
		{
			if (!place_build || place_pos = null)
				return 0

			// Save the build selection independently of the workbench
			hobj = history_set(action_build_place)
			hobj.build_type = build_type
			hobj.build_save_obj = history_save_bench(build_settings)
			hobj.build_save_obj.hobj = hobj
			hobj.value_default = array()
			hobj.structure_save_id = ""

			var targetparent, action;
			targetparent = app
			action = null
			if (place_target_tl != null && instance_exists(place_target_tl))
				with (build_settings)
					action = tl_get_place_parent_action(app.place_target_tl)
			
			if (is_array(action) && array_length(action) > e_parent_action.TARGET)
				targetparent = action[e_parent_action.TARGET]
			
			if (targetparent = null)
				targetparent = app

			if (targetparent != app && type_is_structure(targetparent.type))
				action_build_structure(targetparent)
			else if (targetparent = app)
			{
				if (build_structure != null && !instance_exists(build_structure))
					action_build_structure(null)
				if (build_structure != null)
					targetparent = build_structure
				else
				{
					// Name the new structure
					var basename, foldername, suffix, found;
					basename = text_get("buildtoolstructure")
					foldername = basename
					suffix = 2
					found = true
					while (found)
					{
						found = false
						with (obj_timeline)
							if (name = foldername)
								found = true
						if (found)
						{
							foldername = basename + " " + string(suffix)
							suffix++
						}
					}

					// Create structure
					var structure = new_tl(e_tl_type.STRUCTURE);
					structure.animated = false
					structure.name = foldername
					hobj.structure_pos = array_copy_1d(place_pos)
					with (structure)
					{
						tl_value_set_vec3(e_value.POS_X, hobj.structure_pos)
						tl_value_set_vec3(e_value.POS_X, hobj.structure_pos, true)
						tl_update_display_name()
					}
					
					hobj.structure_save_id = structure.save_id
					hobj.structure_name = foldername
					action_build_structure(structure)
					
					targetparent = structure
				}
			}

			tl = tl_new_block(build_type, build_settings)

			with (tl)
			{
				// Apply the same parent action as a dragged placement
				tl_value_set_matrix(id, matrix_create(app.place_pos, app.place_rot, app.place_sca), true)
				update_matrix = true
				tl_set_parent(targetparent, -1, true)
				if (hobj.structure_save_id != "")
				{
					tl_value_set_vec3(e_value.POS_X, vec3(0))
					tl_value_set_vec3(e_value.POS_X, vec3(0), true)
				}
			}

			hobj.spawn_save_id = tl.save_id
			hobj.parent_save_id = save_id_get(tl.parent)
			with (hobj)
			{
				tl_value_copy_vec3(e_value.POS_X, value_default, tl.value_default)
				tl_value_copy_vec3(e_value.ROT_X, value_default, tl.value_default)
				tl_value_copy_vec3(e_value.SCA_X, value_default, tl.value_default)
			}
			tl_focus = tl
		}
		with (tl)
		{
			tl_update_parent_is_selected()
			if (self.parent != app && type_is_structure(self.parent.type) && (self.parent.place_target || self.parent.parent_is_place_target))
				tl_mark_place_target(true)
		}
		log("Created", tl_type_name_list[|tl.type])
	}

	tl_update_list()
	tl_update_matrix()
	if (history_undo)
		app_update_tl_edit()
	project_update_counts()
	lib_preview.update = true

	if (place_build)
	{
		// Restore the hover target and refresh placement surfaces
		if (placetarget != null && placeparent != null && instance_exists(placetarget) && instance_exists(placeparent))
		{
			place_target_tl = placetarget
			place_target_tl_part_of = placeparent
			with (placeparent)
				tl_mark_place_target(true)
		}
		else if (place_target_tl_part_of = null && build_structure != null && instance_exists(build_structure))
			action_build_structure(build_structure)
		place_pos = null
		place_view_pos = null
		view_main.update_place_surfaces = true
		view_second.update_place_surfaces = true
	}
}

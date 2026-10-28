/// @arg [airblock]

function action_build_place(airblock = false)
{
	var hobj, target, blockpos, blockdata;
	hobj = null
	target = null

	if (history_undo || history_redo)
	{
		hobj = history_data
		if (hobj.scenery_block)
		{
			target = save_id_find(hobj.target_save_id)
			if (target = null)
				return false

			blockpos = hobj.block_pos
			blockdata = history_undo ? hobj.previous_block : [ hobj.block_id, hobj.state_id ]
		}
	}
	else
	{
		if (!airblock && (!place_build || place_pos = null))
			return false

		// Select target
		if (place_target_tl != null && instance_exists(place_target_tl))
			target = place_target_tl

		// Scenery editing
		if (target != null && target.type = e_tl_type.SCENERY)
		{
			if (place_block_pos = null || !is_cpp())
				return false

			blockpos = array_copy_1d(place_block_pos)
			blockdata = [ 0, 0 ]
			
			if (!airblock)
			{
				// Shift block position by target normal
				blockpos = vec3_add(blockpos, place_view_normal)

				// New block
				if (build_type = e_tl_type.BLOCK)
				{
					var block = mc_assets.block_name_map[?build_settings.block_name];
					if (is_undefined(block) || block = null)
						return false

					blockdata = [ block.block_id, block_get_state_id(block, build_settings.block_state) ]
				}
				else
					blockdata = block_get_from_timeline(build_settings.model_name, build_settings.model_state)

				if (blockdata = null)
					return false
			}
		}
	}

	// Scenery edits replace one block without creating or deleting timelines
	if (target != null && target.type = e_tl_type.SCENERY)
	{
		var prevblock;
		with (target)
			prevblock = tl_add_block(blockpos[X], blockpos[Y], blockpos[Z], blockdata[0], blockdata[1])
		
		if (prevblock = null)
			return false

		if (hobj = null)
		{
			hobj = history_set(action_build_place)
			hobj.scenery_block = true
			hobj.target_save_id = target.save_id
			hobj.block_pos = blockpos
			hobj.previous_block = prevblock
			hobj.block_id = blockdata[0]
			hobj.state_id = blockdata[1]
		}

		place_pos = null
		place_view_pos = null
		build_box_render = null
		place_block_pos = null
		
		render_world_changed()
		
		return true
	}
	
	if (airblock)
		return false

	var tl, placetarget, placeparent;
	placetarget = null
	placeparent = null

	// Suspend the active parent highlight during undo and redo
	if (place_build && hobj != null)
	{
		placetarget = place_target_tl
		placeparent = place_target_tl_root
		
		if (placeparent != null && instance_exists(placeparent))
			with (placeparent)
				tl_mark_place_target(false)
		
		place_target_tl = null
		place_target_tl_root = null
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
					action_build_structure(null, false)
				
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
					action_build_structure(structure, false)
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
			// Save the build selection independently of the workbench
			hobj = history_set(action_build_place)
			hobj.scenery_block = false
			hobj.build_type = build_type
			hobj.build_save_obj = history_save_bench(build_settings)
			hobj.build_save_obj.hobj = hobj
			hobj.value_default = []
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
			if (targetparent != app && type_is_structure(targetparent.type) && build_structure_custom)
				targetparent = app

			if (targetparent != app && type_is_structure(targetparent.type))
				action_build_structure(targetparent, false)
			
			else if (targetparent = app)
			{
				if (build_structure != null && !instance_exists(build_structure))
					action_build_structure(null)
				
				if (build_structure != null)
					targetparent = build_structure
				else
				{
					hobj.structure_pos = array_copy_1d(place_pos)
					hobj.structure_pos = vec3_snap(hobj.structure_pos, transform_snap)
					
					var structure = tl_new_structure(hobj.structure_pos)
					hobj.structure_save_id = structure.save_id
					hobj.structure_name = structure.name
					action_build_structure(structure)
					
					targetparent = structure
				}
			}

			tl = tl_new_block(build_type, build_settings)

			with (tl)
			{
				// Apply the same parent action as a dragged placement
				var pos, rot, sca;
				pos = vec3_snap(app.place_pos, transform_snap)
				rot = vec3_snap(app.place_rot, transform_snap)
				sca = vec3_snap(app.place_sca, transform_snap)
				
				tl_value_set_matrix(id, matrix_create(pos, rot, sca), true)
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
			place_target_tl_root = placeparent
			
			with (placeparent)
				tl_mark_place_target(true)
		}
		else if (place_target_tl_root = null && build_structure != null && instance_exists(build_structure))
			action_build_structure(build_structure)
		
		place_pos = null
		place_view_pos = null
		
		view_changed()
	}
	
	return true
}

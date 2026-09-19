/// tl_set_parent(parent, [index, [preserve, [historyobject]]])
/// @desc Sets the parent of the timeline and optionally preserves the current world transform.
/// @arg parent
/// @arg [index
/// @arg [preserve
/// @arg [historyobject]]]

function tl_set_parent(newparent, index = -1, preserve = false, hobj = null)
{
	var action, actiontarget, actionbend, actiontransform, actionlock, relink, parentindex, oldmatrix;
	action = tl_get_parent_action(newparent)
	actiontarget = (is_array(action) && array_length(action) > e_parent_action.TARGET)
	actionbend = (is_array(action) && array_length(action) > e_parent_action.BEND)
	actiontransform = (is_array(action) && array_length(action) > e_parent_action.SCA)
	actionlock = (is_array(action) && array_length(action) > e_parent_action.LOCK)
	relink = true
	parentindex = -1
		
	// Action overwrites parent
	if (actiontarget)
	{
		if (newparent != action[e_parent_action.TARGET])
			index = -1
		newparent = action[e_parent_action.TARGET]
	}
	
	// Parent to bent half
	if (actionbend)
		lock_bend = action[e_parent_action.BEND]

	// Lock in timeline
	if (actionlock)
		action_tl_lock_tree(id, action[e_parent_action.LOCK], hobj)
		
	// Avoid relinking to the same explicit position
	if (parent = newparent && index >= 0)
	{
		parentindex = ds_list_find_index(parent.tree_list, id)
		relink = parentindex != index
	}

	if (preserve && !actiontransform && relink)
	{
		if (parent = app.timeline_move_obj)
			oldmatrix = array_copy_1d(matrix)

		else if (ds_list_find_index(app.project_timeline_list, id) = -1)
		{
			oldmatrix = matrix_create(
				point3D(value[e_value.POS_X], value[e_value.POS_Y], value[e_value.POS_Z]),
				vec3(value[e_value.ROT_X], value[e_value.ROT_Y], value[e_value.ROT_Z]),
				vec3(value[e_value.SCA_X], value[e_value.SCA_Y], value[e_value.SCA_Z]))
		}
		else
		{
			update_matrix = true
			tl_update_matrix()
			oldmatrix = array_copy_1d(matrix)
		}
	}

	if (relink)
	{
		if (parent != null)
			ds_list_delete_value(parent.tree_list, id)

		parent = newparent
		if (index < 0)
			index = ds_list_size(newparent.tree_list)

		ds_list_insert(newparent.tree_list, index, id)
	}

	// Keep unanimated transforms unchanged in world space
	if (preserve && !actiontransform && relink && ds_list_size(keyframe_list) = 0)
		tl_value_set_matrix(id, oldmatrix)

	// Apply custom local transform
	if (actiontransform)
	{
		tl_value_set_vec3(e_value.POS_X, action[e_parent_action.POS])
		tl_value_set_vec3(e_value.ROT_X, action[e_parent_action.ROT])
		tl_value_set_vec3(e_value.SCA_X, action[e_parent_action.SCA])
		tl_value_set_vec3(e_value.POS_X, action[e_parent_action.POS], true)
		tl_value_set_vec3(e_value.ROT_X, action[e_parent_action.ROT], true)
		tl_value_set_vec3(e_value.SCA_X, action[e_parent_action.SCA], true)
	}

	update_matrix = true
}

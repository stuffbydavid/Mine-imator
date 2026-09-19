/// tl_parent_set(parent, [index, [preserve]])
/// @desc Sets the parent of the timeline and optionally preserves the current world transform.
/// @arg parent
/// @arg [index
/// @arg [preserve]]

function tl_set_parent(newparent, index = -1, preserve = false)
{
	var oldmatrix;
	if (preserve)
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

	if (parent != null)
		ds_list_delete_value(parent.tree_list, id)
	
	parent = newparent
	if (index < 0)
		index = ds_list_size(newparent.tree_list)
	
	ds_list_insert(newparent.tree_list, index, id)
	
	// Keep unanimated transforms unchanged in world space
	if (preserve && ds_list_size(keyframe_list) = 0)
		tl_value_set_matrix(id, oldmatrix)

	update_matrix = true
}

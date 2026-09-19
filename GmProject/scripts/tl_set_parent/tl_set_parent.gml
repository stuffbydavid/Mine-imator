/// tl_parent_set(parent, [index], [preserve])
/// @desc Sets the parent
/// @arg parent
/// @arg [index]
/// @arg [preserve]

function tl_set_parent()
{
	var oldmatrix, preserve;
	preserve = argument_count > 2 && argument[2]
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
	
	parent = argument[0]
	var index;
	if (argument_count > 1 && argument[1] >= 0)
		index = argument[1]
	else
		index = ds_list_size(parent.tree_list)
	
	ds_list_insert(parent.tree_list, index, id)
	
	// Keep unanimated transforms unchanged in world space
	if (preserve && ds_list_size(keyframe_list) = 0)
		tl_value_set_matrix(id, oldmatrix)

	update_matrix = true
}

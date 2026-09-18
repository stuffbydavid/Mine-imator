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
	{
		var parentmatrix, localmatrix, localposition, localscale, localangle, localrotation;
		if (parent = app)
			parentmatrix = MAT_IDENTITY
		else if (inherit_rot_point)
			parentmatrix = parent.matrix_render
		else
			parentmatrix = parent.matrix

		localmatrix = matrix_multiply(oldmatrix, matrix_inverse_ext(parentmatrix))
		localposition = matrix_position(localmatrix)
		localscale = vec3(
			sqrt(sqr(localmatrix[0]) + sqr(localmatrix[1]) + sqr(localmatrix[2])),
			sqrt(sqr(localmatrix[4]) + sqr(localmatrix[5]) + sqr(localmatrix[6])),
			sqrt(sqr(localmatrix[8]) + sqr(localmatrix[9]) + sqr(localmatrix[10])))
		matrix_remove_scale(localmatrix)
		localangle = matrix_angle(localmatrix)
		localrotation = vec3(radtodeg(localangle[X]), radtodeg(localangle[Y]), radtodeg(localangle[Z]))

		tl_value_set_vec3(e_value.POS_X, localposition)
		tl_value_set_vec3(e_value.ROT_X, localrotation)
		tl_value_set_vec3(e_value.SCA_X, localscale)
		tl_value_set_vec3(e_value.POS_X, localposition, true)
		tl_value_set_vec3(e_value.ROT_X, localrotation, true)
		tl_value_set_vec3(e_value.SCA_X, localscale, true)
	}

	update_matrix = true
}

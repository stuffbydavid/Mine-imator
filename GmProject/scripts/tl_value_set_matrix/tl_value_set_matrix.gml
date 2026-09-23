/// tl_value_set_matrix(timeline, worldmatrix, [default])
/// @arg timeline
/// @arg worldmatrix
/// @arg [default]
/// @desc Sets transform values from a world-space matrix

function tl_value_set_matrix(tl, worldmatrix, def = true)
{
	var parentmatrix, localmatrix, pos, sca, angle, rot;
	if (tl.parent = app)
		parentmatrix = MAT_IDENTITY
	else if (tl.inherit_rot_point)
		parentmatrix = tl.parent.matrix_render
	else
		parentmatrix = tl.parent.matrix

	localmatrix = matrix_multiply(worldmatrix, matrix_inverse_ext(parentmatrix))
	pos = matrix_position(localmatrix)
	sca = vec3(
		sqrt(sqr(localmatrix[0]) + sqr(localmatrix[1]) + sqr(localmatrix[2])),
		sqrt(sqr(localmatrix[4]) + sqr(localmatrix[5]) + sqr(localmatrix[6])),
		sqrt(sqr(localmatrix[8]) + sqr(localmatrix[9]) + sqr(localmatrix[10])))
	matrix_remove_scale(localmatrix)
	angle = matrix_angle(localmatrix)
	rot = vec3(radtodeg(angle[X]), radtodeg(angle[Y]), radtodeg(angle[Z]))

	pos = vec3_snap(pos, transform_snap)
	rot = vec3_snap(rot, transform_snap)
	sca = vec3_snap(sca, transform_snap)
	
	with (tl)
	{
		tl_value_set_vec3(e_value.POS_X, pos)
		tl_value_set_vec3(e_value.ROT_X, rot)
		tl_value_set_vec3(e_value.SCA_X, sca)
		
		if (def)
		{
			tl_value_set_vec3(e_value.POS_X, pos, true)
			tl_value_set_vec3(e_value.ROT_X, rot, true)
			tl_value_set_vec3(e_value.SCA_X, sca, true)
		}
	}
}

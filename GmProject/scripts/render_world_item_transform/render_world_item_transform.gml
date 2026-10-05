/// @desc Applies item animation and camera-facing transforms
/// @arg matrix
/// @arg facecamera
/// @arg bounce
/// @arg rotate
/// @arg isitem
/// @arg is3d
/// @arg realtime

function render_world_item_transform(mat, facecamera, bounce, rotate, isitem, is3d, realtime)
{
	var rotx, rotz, rotmat, d, t, offz;
	if (isitem && (facecamera || rotate))
	{
		if (facecamera)
			rotz = 90 + point_direction(mat[MAT_X], mat[MAT_Y], proj_from[X], proj_from[Y])
		else
		{
			d = 60 * 6
			t = (realtime ? current_step : app.env_time) mod d * 360
			rotz = t / 360
		}

		rotmat = matrix_build(-8, -0.5 * is3d, 0, 0, 0, 0, 1, 1, 1)
		rotmat = matrix_multiply(rotmat, matrix_build(8, 0.5 * is3d, 0, 0, 0, rotz, 1, 1, 1))
		mat = matrix_multiply(rotmat, mat)
	}

	if (bounce)
	{
		d = 60 * 3
		t = (realtime ? current_step : app.env_time) mod d * 2
		if (t < d)
			offz = ease("easeinoutquad", t / d) * 2 - 1
		else
			offz = 1 - ease("easeinoutquad", (t - d) / d) * 2

		if (isitem)
			offz = (realtime ? 0 : 2) + offz * 1.5
		mat = matrix_multiply(mat, matrix_build(0, 0, offz, 0, 0, 0, 1, 1, 1))
	}

	if (!isitem && facecamera)
	{
		matrix_remove_rotation(mat)
		rotx = -point_zdirection(mat[MAT_X], mat[MAT_Y], mat[MAT_Z], proj_from[X], proj_from[Y], proj_from[Z])
		rotz = 90 + point_direction(mat[MAT_X], mat[MAT_Y], proj_from[X], proj_from[Y])
		rotmat = matrix_build(0, 0, 0, rotx, 0, rotz, 1, 1, 1)
		mat = matrix_multiply(rotmat, mat)
	}

	return mat
}

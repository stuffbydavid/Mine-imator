function tl_get_area_light_sample(tl, sampleindex, jitter = false)
{
	var mat, u, v;
	mat = array_copy_1d(tl.matrix)
	matrix_remove_scale(mat)
	u = ((sampleindex mod 2) + (jitter ? random(1) : 0.5)) * 0.5 - 0.5
	v = (floor(sampleindex / 2) + (jitter ? random(1) : 0.5)) * 0.5 - 0.5
	return point3D_mul_matrix(point3D(u * max(0, tl.value[e_value.LIGHT_AREA_WIDTH]), 0, v * max(0, tl.value[e_value.LIGHT_AREA_HEIGHT])), mat)
}

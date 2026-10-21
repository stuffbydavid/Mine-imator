function view_shape_area_light(tl)
{
	var mat, w, h, points;
	mat = array_copy_1d(tl.matrix)
	matrix_remove_scale(mat)
	w = max(0, tl.value[e_value.LIGHT_AREA_WIDTH]) * 0.5
	h = max(0, tl.value[e_value.LIGHT_AREA_HEIGHT]) * 0.5
	points = [
		point3D_mul_matrix(point3D(-w, 0, -h), mat),
		point3D_mul_matrix(point3D(w, 0, -h), mat),
		point3D_mul_matrix(point3D(w, 0, h), mat),
		point3D_mul_matrix(point3D(-w, 0, h), mat)
	]
	for (var p = 0; p < 4; p++)
		view_shape_line(points[p], points[(p + 1) mod 4])

	view_shape_line(tl.world_pos, point3D_mul_matrix(point3D(0, 8, 0), mat))
	view_shape_circle(tl.world_pos, 2)
}

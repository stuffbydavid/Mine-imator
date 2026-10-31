/// @arg matrix
/// @arg position
/// @arg size

function view_shape_cube_draw(mat, position, size)
{
	var top1, top2, top3, top4;
	var top1mat, top2mat, top3mat, top4mat;
	var bottom1, bottom2, bottom3, bottom4;
	var bottom1mat, bottom2mat, bottom3mat, bottom4mat;
	
	// Top 3D points
	top1 = point3D_add(point3D(-size, size, size), position)
	top2 = point3D_add(point3D(size, size, size), position)
	top3 = point3D_add(point3D(-size, -size, size), position)
	top4 = point3D_add(point3D(size, -size, size), position)
	
	top1mat = point3D_mul_matrix(top1, mat)
	top2mat = point3D_mul_matrix(top2, mat)
	top3mat = point3D_mul_matrix(top3, mat)
	top4mat = point3D_mul_matrix(top4, mat)
	
	// Bottom 3D points
	bottom1 = point3D_add(point3D(-size, size, -size), position)
	bottom2 = point3D_add(point3D(size, size, -size), position)
	bottom3 = point3D_add(point3D(-size, -size, -size), position)
	bottom4 = point3D_add(point3D(size, -size, -size), position)
	
	bottom1mat = point3D_mul_matrix(bottom1, mat)
	bottom2mat = point3D_mul_matrix(bottom2, mat)
	bottom3mat = point3D_mul_matrix(bottom3, mat)
	bottom4mat = point3D_mul_matrix(bottom4, mat)
	
	// Project to 2d
	var top12d, top22d, top32d, top42d;
	var bottom12d, bottom22d, bottom32d, bottom42d;
	
	top12d = view_shape_project(top1mat)
	if (point3D_project_error)
		return 0
	
	top22d = view_shape_project(top2mat)
	if (point3D_project_error)
		return 0
	
	top32d = view_shape_project(top3mat)
	if (point3D_project_error)
		return 0
	
	top42d = view_shape_project(top4mat)
	if (point3D_project_error)
		return 0
	
	bottom12d = view_shape_project(bottom1mat)
	if (point3D_project_error)
		return 0
	
	bottom22d = view_shape_project(bottom2mat)
	if (point3D_project_error)
		return 0
	
	bottom32d = view_shape_project(bottom3mat)
	if (point3D_project_error)
		return 0
	
	bottom42d = view_shape_project(bottom4mat)
	if (point3D_project_error)
		return 0
	
	// Draw cube
	render_set_culling(false)
	draw_primitive_begin(pr_trianglelist)
	
	// Top
	view_shape_triangle_draw(top12d, top22d, top32d)
	view_shape_triangle_draw(top22d, top32d, top42d)
	
	// Bottom
	view_shape_triangle_draw(bottom12d, bottom22d, bottom32d)
	view_shape_triangle_draw(bottom22d, bottom32d, bottom42d)
	
	// Front
	view_shape_triangle_draw(top12d, top22d, bottom12d)
	view_shape_triangle_draw(top22d, bottom12d, bottom22d)
	
	// Back
	view_shape_triangle_draw(top32d, top42d, bottom32d)
	view_shape_triangle_draw(top42d, bottom32d, bottom42d)
	
	// Left(Right not need if fully opaque)
	view_shape_triangle_draw(top12d, top32d, bottom12d)
	view_shape_triangle_draw(top32d, bottom12d, bottom32d)
	
	draw_primitive_end()
	render_set_culling(true)
}

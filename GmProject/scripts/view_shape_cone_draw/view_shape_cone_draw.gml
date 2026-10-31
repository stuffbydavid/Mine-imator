/// @arg matrix
/// @arg position
/// @arg rotation
/// @arg size

function view_shape_cone_draw(mat, position, rotation, size)
{
	var rotmat, detail;
	rotmat = matrix_create(vec3(0), rotation, vec3(1))
	detail = 8
	
	var top3d, end3d, top2d, start2d, end2d;
	top3d = point3D_mul_matrix(point3D(0, 0, size * 1.5), rotmat)
	top3d = point3D_add(top3d, position)
	top3d = point3D_mul_matrix(top3d, mat)
	
	top2d = view_shape_project(top3d)
	if (point3D_project_error)
		return 0
	
	render_set_culling(false)
	draw_primitive_begin(pr_trianglelist)
	
	for (var i = .125; i <= 1.125; i += 1/detail)
	{
		end3d = point3D_mul_matrix(point3D(cos(pi * 2 * i) * size, sin(pi * 2 * i) * size, -(size * 1.5)), rotmat)
		end3d = point3D_mul_matrix(point3D_add(end3d, position), mat)
		
		end2d = view_shape_project(end3d)
		if (point3D_project_error)
			break
		
		if (i > .125)
			view_shape_triangle_draw(start2d, end2d, top2d)
		
		start2d = end2d
	}
	
	draw_primitive_end()
	render_set_culling(true)
}

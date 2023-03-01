/// view_shape_cone_draw(mat, position, rotation, size)
/// @arg mat
/// @arg position
/// @arg rotation
/// @arg size

function view_shape_cone_draw(mat, position, rotation, size)
{
	var rotmat, detail;
	rotmat = matrix_create(vec3(0), rotation, vec3(1))
	detail = 8
	
	var top3D, end3D;
	var top2D, start2D, end2D;
	top3D = point3D_mul_matrix(point3D(0, 0, size * 1.5), rotmat)
	top3D = point3D_add(top3D, position)
	top3D = point3D_mul_matrix(top3D, mat)
	
	top2D = view_shape_project(top3D)
	if (point3D_project_error)
		return 0
	
	render_set_culling(false)
	draw_primitive_begin(pr_trianglelist)
	
	for (var i = .125; i <= 1.125; i += 1/detail)
	{
		end3D = point3D_mul_matrix(point3D(cos(pi * 2 * i) * size, sin(pi * 2 * i) * size, -(size * 1.5)), rotmat)
		end3D = point3D_mul_matrix(point3D_add(end3D, position), mat)
		
		end2D = view_shape_project(end3D)
		if (point3D_project_error)
			break
		
		if (i > .125)
			view_shape_triangle_draw(start2D, end2D, top2D)
		
		start2D = end2D
	}
	
	draw_primitive_end()
	render_set_culling(true)
}

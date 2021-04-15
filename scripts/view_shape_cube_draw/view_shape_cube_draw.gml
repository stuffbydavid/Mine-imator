/// view_shape_cube_draw(mat, position, size)
/// @arg mat
/// @arg position
/// @arg size

var mat, position, size;
mat = argument0
position = argument1
size = argument2

var top1, top2, top3, top4;
var bottom1, bottom2, bottom3, bottom4;

var top1mat, top2mat, top3mat, top4mat;
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

// Project to 2D
var top12D, top22D, top32D, top42D;
var bottom12D, bottom22D, bottom32D, bottom42D;

top12D = view_shape_project(top1mat)
if (point3D_project_error)
	return 0

top22D = view_shape_project(top2mat)
if (point3D_project_error)
	return 0

top32D = view_shape_project(top3mat)
if (point3D_project_error)
	return 0

top42D = view_shape_project(top4mat)
if (point3D_project_error)
	return 0

bottom12D = view_shape_project(bottom1mat)
if (point3D_project_error)
	return 0

bottom22D = view_shape_project(bottom2mat)
if (point3D_project_error)
	return 0

bottom32D = view_shape_project(bottom3mat)
if (point3D_project_error)
	return 0

bottom42D = view_shape_project(bottom4mat)
if (point3D_project_error)
	return 0

// Draw cube
render_set_culling(false)
draw_primitive_begin(pr_trianglelist)

// Top
view_shape_triangle_draw(top12D, top22D, top32D)
view_shape_triangle_draw(top22D, top32D, top42D)

// Bottom
view_shape_triangle_draw(bottom12D, bottom22D, bottom32D)
view_shape_triangle_draw(bottom22D, bottom32D, bottom42D)

// Front
view_shape_triangle_draw(top12D, top22D, bottom12D)
view_shape_triangle_draw(top22D, bottom12D, bottom22D)

// Back
view_shape_triangle_draw(top32D, top42D, bottom32D)
view_shape_triangle_draw(top42D, bottom32D, bottom42D)

// Left(Right not need if fully opaque)
view_shape_triangle_draw(top12D, top32D, bottom12D)
view_shape_triangle_draw(top32D, bottom12D, bottom32D)

draw_primitive_end()
render_set_culling(true)

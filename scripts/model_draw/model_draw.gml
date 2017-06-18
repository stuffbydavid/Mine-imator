/// model_draw(model [, x / matrix [, y, z [, xrot, yrot, zrot [, xscale, yscale, zscale]]]])

if (argument_count = 2)
	matrix_set(matrix_world, argument[1])
else if (argument_count > 7)
	matrix_set(matrix_world, matrix_build(argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8], argument[9]))
else if (argument_count > 4)
	matrix_set(matrix_world, matrix_build(argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], 1, 1, 1))
else if (argument_count > 1)
	matrix_set(matrix_world, matrix_build(argument[1], argument[2], argument[3], 0, 0, 0, 1, 1, 1))
	
vertex_submit(argument[0], pr_trianglelist, -1)

if (argument_count > 1)
	matrix_world_reset()

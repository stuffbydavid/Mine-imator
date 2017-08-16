/// render_world_model_file_parts(modelfile, texturename, resource)
/// @arg modelfile
/// @arg texturename
/// @arg resource
/// @desc Renders a modelfile in its default position.

var modelfile, texname, res, mat;
modelfile = argument0
texname = argument1
res = argument2
mat = matrix_get(matrix_world)

for (var p = 0; p < modelfile.part_amount; p++) 
{
	var part = modelfile.part[p]
	
	matrix_set(matrix_world, matrix_multiply(part.default_matrix, mat))
	render_world_model_part(part, texname, res, 0)
	if (part.part_amount > 0)
		render_world_model_file_parts(part, texname, res)
}

matrix_set(matrix_world, mat)
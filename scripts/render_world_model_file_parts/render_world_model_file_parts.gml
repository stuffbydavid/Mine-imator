/// render_world_model_file_parts(modelfile, texturenamemap, resource)
/// @arg modelfile
/// @arg texturenamemap
/// @arg resource
/// @desc Renders a modelfile in its default position.

var modelfile, texnamemap, res, mat;
modelfile = argument0
texnamemap = argument1
res = argument2
mat = matrix_get(matrix_world)

for (var p = 0; p < ds_list_size(modelfile.part_list); p++) 
{
	var part = modelfile.part_list[|p];
	
	matrix_set(matrix_world, matrix_multiply(part.default_matrix, mat))
	render_world_model_part(part, texnamemap, res, 0)
	if (part.part_list != null && ds_list_size(part.part_list) > 0)
		render_world_model_file_parts(part, texnamemap, res)
}

matrix_set(matrix_world, mat)
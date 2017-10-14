/// render_world_model_file_parts(modelfile, texturenamemap, hidelist, resource)
/// @arg modelfile
/// @arg texturenamemap
/// @arg hidelist
/// @arg resource
/// @desc Renders a modelfile in its default position.

var modelfile, texnamemap, hidelist, res, mat;
modelfile = argument0
texnamemap = argument1
hidelist = argument2
res = argument3
mat = matrix_get(matrix_world)

for (var p = 0; p < ds_list_size(modelfile.part_list); p++) 
{
	var part = modelfile.part_list[|p];
	if (hidelist != null && ds_list_find_index(hidelist, part.name) > -1)
		continue
	
	matrix_set(matrix_world, matrix_multiply(part.default_matrix, mat))
	render_world_model_part(part, texnamemap, res, 0, null)
	if (part.part_list != null && ds_list_size(part.part_list) > 0)
		render_world_model_file_parts(part, texnamemap, hidelist, res)
}

matrix_set(matrix_world, mat)
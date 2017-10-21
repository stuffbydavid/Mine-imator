/// render_world_model_file_parts(modelfile, resource, texturenamemap, hidelist, planevbuffermap)
/// @arg modelfile
/// @arg resource
/// @arg texturenamemap
/// @arg hidelist
/// @arg planevbuffermap
/// @desc Renders a modelfile in its default position.

var modelfile, res, texnamemap, hidelist, planevbuffermap, mat;
modelfile = argument0
res = argument1
texnamemap = argument2
hidelist = argument3
planevbuffermap = argument4
mat = matrix_get(matrix_world)

for (var p = 0; p < ds_list_size(modelfile.part_list); p++) 
{
	var part = modelfile.part_list[|p];
	if (hidelist != null && ds_list_find_index(hidelist, part.name) > -1)
		continue
	
	matrix_set(matrix_world, matrix_multiply(part.default_matrix, mat))
	render_world_model_part(part, res, texnamemap, 0, null, planevbuffermap)
	if (part.part_list != null && ds_list_size(part.part_list) > 0)
		render_world_model_file_parts(part, res, texnamemap, hidelist, planevbuffermap)
}

matrix_set(matrix_world, mat)
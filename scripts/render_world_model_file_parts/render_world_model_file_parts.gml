/// render_world_model_file_parts(modelfile, resource, texturenamemap, hidelist, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap)
/// @arg modelfile
/// @arg resource
/// @arg texturenamemap
/// @arg hidelist
/// @arg shapevbuffermap
/// @arg colornamemap
/// @arg shapehidelist
/// @arg shapetexnamemap
/// @desc Renders a modelfile in its default position.

var modelfile, res, texnamemap, hidelist, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap, mat;
modelfile = argument0
res = argument1
texnamemap = argument2
hidelist = argument3
shapevbuffermap = argument4
colornamemap = argument5
shapehidelist = argument6
shapetexnamemap = argument7
mat = matrix_get(matrix_world)

for (var p = 0; p < ds_list_size(modelfile.part_list); p++) 
{
	var part = modelfile.part_list[|p];
	if (hidelist != null && ds_list_find_index(hidelist, part.name) > -1)
		continue
	
	if (part.part_mixing_shapes)
		render_set_uniform_int("uColorsExt", part.part_mixing_shapes)
	
	matrix_set(matrix_world, matrix_multiply(part.default_matrix, mat))
	render_world_model_part(part, res, texnamemap, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap, null)
	
	if (part.part_mixing_shapes)
		render_set_uniform_int("uColorsExt", 0)
	
	if (part.part_list != null && ds_list_size(part.part_list) > 0)
		render_world_model_file_parts(part, res, texnamemap, hidelist, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap)
}

matrix_set(matrix_world, mat)
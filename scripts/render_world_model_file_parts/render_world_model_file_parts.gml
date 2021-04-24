/// render_world_model_file_parts(modelfile, resource, texturenamemap, hidelist, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap, [matrixmap])
/// @arg modelfile
/// @arg resource
/// @arg texturenamemap
/// @arg hidelist
/// @arg shapevbuffermap
/// @arg colornamemap
/// @arg shapehidelist
/// @arg shapetexnamemap
/// @arg [matrixmap]
/// @desc Renders a modelfile in its default position. If a matrix map is given, renders all parts in their depth order.

function render_world_model_file_parts()
{
	var modelfile, res, texnamemap, hidelist, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap, matrixmap, partlist, mat;
	modelfile = argument[0]
	res = argument[1]
	texnamemap = argument[2]
	hidelist = argument[3]
	shapevbuffermap = argument[4]
	colornamemap = argument[5]
	shapehidelist = argument[6]
	shapetexnamemap = argument[7]
	matrixmap = null
	partlist = modelfile.part_list
	
	if (argument_count > 8)
	{
		matrixmap = argument[8]
		partlist = modelfile.render_part_list
	}
	
	mat = matrix_get(matrix_world)
	
	for (var p = 0; p < ds_list_size(partlist); p++) 
	{
		var part = partlist[|p];
		
		if (matrixmap != null)
		{
			// If matrix isn't available, skip part
			if (ds_map_exists(matrixmap, part.name))
				matrix_set(matrix_world, matrixmap[?part.name])
			else
				continue
		}
		else
		{
			// Hidden?
			if (hidelist != null && ds_list_find_index(hidelist, part.name) > -1)
				continue
			
			matrix_set(matrix_world, matrix_multiply(part.default_matrix, mat))	
		}
		
		if (part.part_mixing_shapes)
			render_set_uniform_int("uColorsExt", part.part_mixing_shapes)
		
		render_world_model_part(part, res, texnamemap, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap, null)
		
		if (part.part_mixing_shapes)
			render_set_uniform_int("uColorsExt", 0)
		
		// Render child parts
		if (matrixmap = null)
		{
			if (part.part_list != null && ds_list_size(part.part_list) > 0)
				render_world_model_file_parts(part, res, texnamemap, hidelist, shapevbuffermap, colornamemap, shapehidelist, shapetexnamemap)
		}
	}
	
	matrix_set(matrix_world, mat)
}

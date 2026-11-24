/// @desc Caches model meshes, hidden shapes and view-independent shape matrices for this timeline.
/// CppGen ArrRef model_part_shape_render_matrix
/// CppGen ArrRef model_part_shape_vbuffer
/// CppGen ArrRef model_part_shape_hidden

function tl_update_model_shape_render(refreshinfo = true)
{
	if (model_part = null || model_part.shape_list = null)
		return 0

	var shapes, shapecount, rebuild, updatematrices, updateinfo;
	shapes = model_part.shape_list
	shapecount = ds_list_size(shapes)
	rebuild = (model_part_shape_cache_part != model_part ||
		array_length(model_part_shape_render_matrix) != shapecount ||
		array_length(model_part_shape_vbuffer) != shapecount ||
		array_length(model_part_shape_hidden) != shapecount)
	updatematrices = (rebuild || model_part_shape_render_matrix_part != model_part)
	updateinfo = (rebuild || refreshinfo || model_part_shape_data_update)

	if (rebuild)
	{
		model_part_shape_render_matrix = []
		model_part_shape_vbuffer = []
		model_part_shape_hidden = []
		model_part_shape_cache_part = model_part
	}

	if (!updatematrices && !updateinfo)
		return 0

	var buffermap, hidelist;
	if (updateinfo)
	{
		buffermap = model_shape_vbuffer_map
		hidelist = temp.model_shape_hide_list
	}

	for (var s = 0; s < shapecount; s++)
	{
		var shape;
		shape = shapes[|s]
		if (updateinfo)
		{
			var vbuf = (buffermap != null ? buffermap[?shape] : null);
			model_part_shape_vbuffer[s] = (is_undefined(vbuf) ? null : vbuf)
			model_part_shape_hidden[s] = (hidelist != null && ds_list_find_index(hidelist, shape.description) > -1)
		}

		if (updatematrices)
		{
			if (shape.item_bounce || shape.face_camera)
				model_part_shape_render_matrix[s] = null
			else
				model_part_shape_render_matrix[s] = matrix_multiply(shape.matrix, matrix_render)
		}
	}

	model_part_shape_render_matrix_part = model_part
	model_part_shape_data_update = false
}

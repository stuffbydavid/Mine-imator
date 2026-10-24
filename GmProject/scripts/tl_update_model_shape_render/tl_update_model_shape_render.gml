/// CppSeparate RealType tl_update_model_shape_render(Scope<obj_timeline>, BoolType)
/// @desc Caches model meshes, hidden shapes and view-independent shape matrices for this timeline
/// @arg [refreshinfo]

function tl_update_model_shape_render(refreshinfo = true)
{
	if (model_part = null || model_part.shape_list = null)
		return 0

	var shapecount = ds_list_size(model_part.shape_list);
	var rebuild = (model_part_shape_cache_part != model_part ||
		array_length(model_part_shape_render_matrix) != shapecount ||
		array_length(model_part_shape_vbuffer) != shapecount ||
		array_length(model_part_shape_hidden) != shapecount);
	var updatematrices = (rebuild || model_part_shape_render_matrix_part != model_part);
	var updateinfo = (rebuild || refreshinfo || model_part_shape_data_dirty);

	if (rebuild)
	{
		model_part_shape_render_matrix = []
		model_part_shape_vbuffer = []
		model_part_shape_hidden = []
		model_part_shape_cache_part = model_part
	}

	if (!updatematrices && !updateinfo)
		return 0

	for (var s = 0; s < shapecount; s++)
	{
		var shape;
		shape = model_part.shape_list[|s]
		if (updateinfo)
		{
			var vbuf = (model_shape_vbuffer_map != null ? model_shape_vbuffer_map[?shape] : null);
			model_part_shape_vbuffer[s] = (is_undefined(vbuf) ? null : vbuf)
			model_part_shape_hidden[s] = (temp.model_shape_hide_list != null && ds_list_find_index(temp.model_shape_hide_list, shape.description) > -1)
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
	model_part_shape_data_dirty = false
}

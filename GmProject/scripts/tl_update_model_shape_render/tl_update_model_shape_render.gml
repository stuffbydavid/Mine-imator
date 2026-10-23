/// @desc Caches model meshes, hidden shapes and view-independent shape matrices for this timeline.

function tl_update_model_shape_render()
{
	if (model_part = null || model_part.shape_list = null)
		return 0
	
	var profile = debug_profiler_begin("Model shape cache");

	var updatematrices = (model_part_shape_render_matrix_part != model_part ||
		array_length(model_part_shape_render_matrix) != ds_list_size(model_part.shape_list));
	
	if (updatematrices)
	{
		model_part_shape_render_matrix = []
		model_part_shape_render_matrix_part = model_part
	}
	
	for (var s = 0; s < ds_list_size(model_part.shape_list); s++)
	{
		var shape, vbuf;
		shape = model_part.shape_list[|s]
		vbuf = (model_shape_vbuffer_map != null ? model_shape_vbuffer_map[?shape] : null)
		
		model_part_shape_vbuffer[s] = (is_undefined(vbuf) ? null : vbuf)
		model_part_shape_hidden[s] = (temp.model_shape_hide_list != null && ds_list_find_index(temp.model_shape_hide_list, shape.description) > -1)
		
		if (updatematrices)
		{
			if (shape.item_bounce || shape.face_camera)
				model_part_shape_render_matrix[s] = null
			else
				model_part_shape_render_matrix[s] = matrix_multiply(shape.matrix, matrix_render)
		}
	}

	if (model_part_merged_dirty || model_part_merged_part != model_part ||
		model_part_merged_count != ds_list_size(model_part.shape_list))
		tl_update_model_shape_merge()

	var shapecount = ds_list_size(model_part.shape_list);
	model_part_merged_compatible = (model_part_merged_vbuffer != null &&
		array_length(model_part_shape_tex) = shapecount &&
		array_length(model_part_shape_tex_material) = shapecount &&
		array_length(model_part_shape_tex_normal) = shapecount &&
		array_length(model_part_shape_material_res) = shapecount)

	if (!model_part_merged_compatible)
	{
		debug_profiler_end("Model shape cache", profile)
		return 0
	}

	var colornamemap = temp.model_color_map;
	var firstcolor = (colornamemap != null ? colornamemap[?model_part.shape_list[|0].description] : undefined);
	for (var s = 0; s < shapecount; s++)
	{
		var shapecolor = (colornamemap != null ? colornamemap[?model_part.shape_list[|s].description] : undefined);
		if (model_part_shape_hidden[s] ||
			model_part_shape_tex[s] != model_part_shape_tex[0] ||
			model_part_shape_tex_material[s] != model_part_shape_tex_material[0] ||
			model_part_shape_tex_normal[s] != model_part_shape_tex_normal[0] ||
			model_part_shape_material_res[s] != model_part_shape_material_res[0] ||
			is_undefined(shapecolor) != is_undefined(firstcolor))
		{
			model_part_merged_compatible = false
			break
		}
		if (!is_undefined(shapecolor) && shapecolor != firstcolor)
		{
			model_part_merged_compatible = false
			break
		}
	}
	debug_profiler_end("Model shape cache", profile)
}

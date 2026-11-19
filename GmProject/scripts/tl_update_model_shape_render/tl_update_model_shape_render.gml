/// @desc Caches model meshes, hidden shapes and view-independent shape matrices for this timeline.

function tl_update_model_shape_render()
{
	if (model_part = null || model_part.shape_list = null)
		return 0
	
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
}

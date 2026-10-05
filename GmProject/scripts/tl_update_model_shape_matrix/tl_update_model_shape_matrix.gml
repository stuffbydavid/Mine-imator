/// @desc Caches view-independent model shape matrices for this timeline.

function tl_update_model_shape_matrix()
{
	model_part_shape_render_matrix = []
	model_part_shape_render_matrix_part = model_part
	
	if (model_part = null || model_part.shape_list = null)
		return 0
	
	for (var s = 0; s < ds_list_size(model_part.shape_list); s++)
	{
		var shape = model_part.shape_list[|s];
		if (shape.item_bounce || shape.face_camera)
			model_part_shape_render_matrix[s] = null
		else
			model_part_shape_render_matrix[s] = matrix_multiply(shape.matrix, matrix_render)
	}
}

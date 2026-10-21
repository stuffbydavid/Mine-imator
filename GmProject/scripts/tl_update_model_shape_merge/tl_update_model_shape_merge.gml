/// @desc Rebuilds a model part's merged mesh only when its source geometry changes.

function tl_update_model_shape_merge()
{
	if (model_part_merged_vbuffer != null)
		vbuffer_destroy(model_part_merged_vbuffer)

	model_part_merged_vbuffer = null
	model_part_merged_dirty = false
	model_part_merged_part = model_part
	model_part_merged_count = ds_list_size(model_part.shape_list)

	if (!is_cpp() || !debug_merge_model_meshes || model_part_merged_count < 2)
		return 0

	var first, buffers, transforms;
	first = model_part.shape_list[|0]
	buffers = []
	transforms = []
	for (var s = 0; s < model_part_merged_count; s++)
	{
		var shape = model_part.shape_list[|s];
		if (shape.item_bounce || shape.face_camera || shape.move_required ||
			shape.wind_wave != e_vertex_wave.NONE || shape.locked != first.locked ||
			shape.color_alpha != first.color_alpha || shape.color_blend != first.color_blend ||
			shape.use_model_color != first.use_model_color ||
			shape.color_mix != first.color_mix || shape.color_mix_percent != first.color_mix_percent ||
			shape.texture_scroll_speed != first.texture_scroll_speed ||
			shape.texture_scroll_direction != first.texture_scroll_direction ||
			model_part_shape_vbuffer[s] = null)
			return 0

		buffers[s] = model_part_shape_vbuffer[s]
		transforms[s] = shape.matrix
	}

	var merged = vbuffer_merge(buffers, transforms);
	if (merged != 0)
		model_part_merged_vbuffer = merged
}

/// temp_update([copy])
/// @arg copy

function temp_update(copy = false)
{
	if (type = e_temp_type.CHARACTER ||
		type = e_temp_type.SPECIAL_BLOCK ||
		type = e_temp_type.BODYPART ||
		type = e_temp_type.MODEL)
	{
		temp_update_model(copy)
		if (type = e_temp_type.BODYPART)
			temp_update_model_part()
		temp_update_model_shape()
	}
	else if (type = e_temp_type.ITEM)
		render_generate_item()
	else if (type = e_temp_type.BLOCK)
		temp_update_block()
	else if (type_is_shape(type))
		temp_update_shape()
	
	if (object_index != obj_bench_settings)
	{
		temp_update_rot_point()
		temp_update_display_name()
		
		with (app)
		{
			tl_update_list()
			tl_update_matrix()
		}
	}
}

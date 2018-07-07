/// action_bench_model_name(name)
/// @arg name

with (bench_settings)
{
	if (model_name = argument0)
		return 0
		
	model_name = argument0
	model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
	temp_update_model()
	
	if (type = e_temp_type.BODYPART)
		temp_update_model_part()
	
	temp_update_model_shape()
	model_shape_update_color()
	
	with (preview)
	{
		preview_reset_view()
		update = true
	}
}
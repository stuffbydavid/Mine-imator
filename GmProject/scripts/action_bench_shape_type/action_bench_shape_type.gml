/// action_bench_shape_type(type)
/// @arg type

function action_bench_shape_type(type)
{
	if (!history_undo && !history_redo)
		history_set_var(action_bench_shape_type, bench_settings.shape_type, type, true)
	
	bench_settings.shape_type = type
	bench_settings.preview.update = true
	
	with (bench_settings)
		temp_update_shape()
}

/// action_bench_light_type(type)
/// @arg type

function action_bench_light_type(type)
{
	if (!history_undo && !history_redo)
		history_set_var(action_bench_light_type, bench_settings.light_type, type, true)
	
	bench_settings.light_type = type
}

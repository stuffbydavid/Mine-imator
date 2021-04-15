/// action_bench_light_type(type)
/// @arg type

var type;

if (history_undo)
	type = history_data.old_value
else if (history_redo)
	type = history_data.new_value
else
{
	type = argument0
	
	history_set_var(action_bench_light_type, bench_settings.light_type, type, true)
}

bench_settings.light_type = type

/// render_set_culling(enable)
/// @arg enable

if (gpu_get_cullmode() != test(argument0, cull_counterclockwise, cull_noculling))
	gpu_set_cullmode(test(argument0, cull_counterclockwise, cull_noculling))
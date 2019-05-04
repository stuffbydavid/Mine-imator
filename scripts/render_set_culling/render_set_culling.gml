/// render_set_culling(enable)
/// @arg enable

var mode = (argument0 ? cull_counterclockwise : cull_noculling);

if (gpu_get_cullmode() != mode)
	gpu_set_cullmode(mode)
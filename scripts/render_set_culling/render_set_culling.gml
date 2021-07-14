/// render_set_culling(enable)
/// @arg enable

function render_set_culling(enable)
{
	var mode = (enable ? cull_counterclockwise : cull_noculling);
	
	if (mode = gpu_get_cullmode())
		return 0
	
	gpu_set_cullmode(mode)
}

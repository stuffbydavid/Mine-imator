function render_set_culling(enabled)
{
	var mode = (enabled ? cull_counterclockwise : cull_noculling);
	
	if (mode = gpu_get_cullmode())
		return 0
	
	gpu_set_cullmode(mode)
}

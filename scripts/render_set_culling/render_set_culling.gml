/// render_set_culling(enable)
/// @arg enable

function render_set_culling(enable)
{
	gpu_set_cullmode(enable ? cull_counterclockwise : cull_noculling)
}

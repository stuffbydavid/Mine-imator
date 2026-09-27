/// render_surface_pool_free(pool)
/// @arg pool

function render_surface_pool_free(pool)
{
	if (!instance_exists(pool))
		return

	with (pool)
		render_surface_pool_event_destroy()
	instance_destroy(pool)
}

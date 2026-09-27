/// render_surface_pool_update()

function render_surface_pool_update()
{
	render_surface_pool_save()

	for (var i = ds_list_size(render_surface_pool_list) - 1; i >= 0; i--)
	{
		var pool = render_surface_pool_list[|i]
		if (!instance_exists(pool) || !pool.used)
		{
			render_surface_pool_free(pool)
			ds_list_delete(render_surface_pool_list, i)
		}
		else
			pool.used = false
	}
}

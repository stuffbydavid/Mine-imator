function render_surface_pool_update()
{
	render_surface_pool_save()

	for (var i = ds_list_size(render_surface_pool_list) - 1; i >= 0; i--)
	{
		var pool = render_surface_pool_list[|i];
		
		if (instance_exists(pool) && (pool.owner = view_main || pool.owner = view_second))
		{
			var view = pool.owner;
			if (view.show && pool.width = view.surface_width && pool.height = view.surface_height)
				pool.used = true
		}
		
		if (!instance_exists(pool) || !pool.used)
		{
			render_surface_pool_free(pool)
			ds_list_delete(render_surface_pool_list, i)
		}
		else
			pool.used = false
	}
}

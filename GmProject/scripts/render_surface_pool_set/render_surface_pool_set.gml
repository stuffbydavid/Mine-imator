/// render_surface_pool_set(owner, width, height)
/// @arg owner
/// @arg width
/// @arg height

function render_surface_pool_set(owner, width, height)
{
	render_surface_pool_save()

	var pool = null
	for (var i = 0; i < ds_list_size(render_surface_pool_list); i++)
	{
		var checkpool = render_surface_pool_list[|i]
		if (checkpool.owner = owner && checkpool.width = width && checkpool.height = height)
		{
			pool = checkpool
			break
		}
	}

	if (pool = null)
	{
		pool = new_obj(obj_render_surface_pool)
		pool.owner = owner
		if (is_string(owner))
			pool.owner_label = owner
		else if (owner = render_camera)
			pool.owner_label = "camera " + string(owner)
		else
			pool.owner_label = "view " + string(owner)
		pool.width = width
		pool.height = height
		ds_list_add(render_surface_pool_list, pool)
	}

	pool.used = true
	render_surface_pool_current = pool
	render_surface_pool_load(pool)
}

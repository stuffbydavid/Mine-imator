/// @desc The scenery timeline takes the place of the ground. A pending history
/// object can be supplied for checking the size after loading against the threshold.
/// @arg [historyobject]

function tl_replace_ground(hobj = null)
{
	var scenery = temp.scenery;
	if (!scenery)
		return 0

	if (hobj != null)
	{
		if (!scenery.ready)
		{
			scenery_ground_hobj = hobj
			return 0
		}

		// Keep the import's setting and undo state when loading finishes later
		hobj.scenery_replace_ground = (hobj.scenery_replace_ground &&
			scenery.scenery_size[X] > scenery_large_threshold && scenery.scenery_size[Y] > scenery_large_threshold)
		scenery_ground_hobj = null

		if (!hobj.scenery_replace_ground)
			return 0
	}
	
	lock = true
	animated = false
	rot_point_custom = true
	
	// Minecraft sea/ground level (Y=63)
	if (scenery.type = e_res_type.FROM_WORLD)
	{
		rot_point = point3D(
			scenery.scenery_size[X] * block_half_size,
			scenery.scenery_size[Y] * block_half_size,
			(63 - scenery.world_box_start[Y]) * block_size
		)
	}
	
	// Center
	else
		rot_point = vec3_mul(scenery.scenery_size, block_half_size)
	
	tl_update_rot_point()
	app.env_ground_show = false
}

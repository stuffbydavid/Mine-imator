/// tl_replace_ground()
/// @desc Scenery timeline takes the place of the ground.

function tl_replace_ground()
{
	var scenery = temp.scenery;
	if (!scenery)
		return 0
	
	lock = true
	rot_point_custom = true
	
	// Minecraft sea/ground level (Y=63)
	if (scenery.type = e_res_type.FROM_WORLD)
	{
		rot_point = point3D(
			scenery.scenery_size[X] * block_size / 2,
			scenery.scenery_size[Y] * block_size / 2,
			(63 - scenery.world_box_start[Y]) * block_size
		)
	}
	
	// Center
	else
		rot_point = vec3_mul(scenery.scenery_size, block_size / 2)
	
	tl_update_rot_point()
	app.background_ground_show = false
}
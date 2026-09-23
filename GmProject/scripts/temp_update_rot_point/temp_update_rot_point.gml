/// temp_update_rot_point()
/// @desc Updates the default rotation point of the template.

function temp_update_rot_point()
{
	rot_point = point3D(0)

	var rep, size, centerready;
	rep = (block_repeat_enable && block_center ? block_repeat : vec3(1))
	size = vec3(1)
	centerready = true

	switch (type)
	{
		case e_temp_type.SCENERY:
		{
			if (scenery = null || !scenery.ready)
			{
				centerready = false
				break
			}
			size = vec3(rep[X] * scenery.scenery_size[X], rep[Y] * scenery.scenery_size[Y], rep[Z] * scenery.scenery_size[Z])

			if (!block_center)
			{
				rot_point[X] = scenery.scenery_size[X] * block_half_size
				rot_point[Y] = scenery.scenery_size[Y] * block_half_size
				break
			}

			rot_point[X] = size[X] * block_half_size
			rot_point[Y] = size[Y] * block_half_size
			break
		}
		
		case e_temp_type.BLOCK:
		{
			size = array_copy_1d(rep)
			rot_point[X] = size[X] * block_half_size
			rot_point[Y] = size[Y] * block_half_size
			break
		}
		
		case e_temp_type.MODEL:
		{
			if (model != null && model.model_format = e_model_format.BLOCK)
			{
				rot_point[X] = block_half_size
				rot_point[Y] = block_half_size
			}
			break
		}
		
		case e_temp_type.ITEM:
		{
			rot_point[X] = item_size / 2
			rot_point[Y] = 0.5 * bool_to_float(item_3d)
			break
		}
		
		case e_temp_type.TEXT:
		{
			rot_point[Y] = 0.5 * bool_to_float(text_3d)
			break
		}
	}

	// Block offset to keep Minecraft grid alignment
	var offset = point3D(0);
	if (block_center && centerready && (type = e_temp_type.BLOCK || type = e_temp_type.SCENERY))
	{
		if (size[X] mod 2 = 0)
		{
			rot_point[X] -= block_half_size
			offset[X] = -block_half_size
		}
		if (size[Y] mod 2 = 0)
		{
			rot_point[Y] -= block_half_size
			offset[Y] = -block_half_size
		}
	}

	// Convert old rotation points
	if (block_center_legacy && centerready)
	{
		if (offset[X] != 0 || offset[Y] != 0)
		{
			with (obj_timeline)
			{
				if (temp = other.id && !rot_point_custom)
				{
					rot_point = point3D_sub(other.rot_point, offset)
					rot_point_custom = true
				}
			}
		}
		block_center_legacy = false
	}
	
	if (type_is_shape(type))
		rot_point[Z] = -8
	
	with (obj_timeline)
		if (temp = other.id)
			tl_update_rot_point()
}

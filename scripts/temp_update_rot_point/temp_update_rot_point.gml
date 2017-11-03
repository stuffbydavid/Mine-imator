/// temp_update_rot_point()
/// @desc Updates the default rotation point of the template.

rot_point = point3D(0, 0, 0)

var rep = test(block_repeat_enable, block_repeat, vec3(1))

switch (type)
{
	case e_temp_type.SCENERY:
	{
		if (scenery = null || !scenery.ready)
			break
		
		rot_point[X] = (rep[X] * scenery.scenery_size[X] * block_size) / 2
		rot_point[Y] = (rep[Y] * scenery.scenery_size[Y] * block_size) / 2
		break
	}
		
	case e_temp_type.BLOCK:
	{
		rot_point[X] = (rep[X] * block_size) / 2
		rot_point[Y] = (rep[Y] * block_size) / 2
		break
	}
		
	case e_temp_type.MODEL:
	{
		if (model != null && model.model_format = e_model_format.BLOCK)
		{
			rot_point[X] = block_size / 2
			rot_point[Y] = block_size / 2
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

if (type_is_shape(type))
	rot_point[Z] = -8

with (obj_timeline)
	if (temp = other.id)
		tl_update_rot_point()

with (app)
	tl_update_matrix()
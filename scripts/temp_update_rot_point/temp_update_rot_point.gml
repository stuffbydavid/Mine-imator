/// temp_update_rot_point()
/// @desc Updates the default rotation point of the template.

rot_point = point3D(0, 0, 0)

var rep = test(block_repeat_enable, block_repeat, vec3(1))

switch (type)
{
	case "scenery":
		if (scenery = null)
			break
		rot_point[X] = (rep[X] * scenery.scenery_size[X] * block_size) / 2
		rot_point[Y] = (rep[Y] * scenery.scenery_size[Y] * block_size) / 2
		break
		
	case "block":
		rot_point[X] = (rep[X] * block_size) / 2
		rot_point[Y] = (rep[Y] * block_size) / 2
		break
		
	case "item":
		rot_point[X] = item_size / 2
		rot_point[Y] = 0.5 * bool_to_float(item_3d)
		break
		
	case "text":
		break
	
	default:
		rot_point[Z] = -8
		break
}

with (obj_timeline)
	if (temp = other.id)
		tl_update_rot_point()

/// temp_update_rot_point()
/// @desc Updates the default rotation point of the template.

rot_point = point3D(0, 0, 0)

var repx, repy;
if (repeat_toggle)
{
	repx = repeat_x
	repy = repeat_y
}
else
{
	repx = 1
	repy = 1
}

switch (type)
{
	case "scenery":
		if (!scenery)
			break
		rot_point[XPOS] = (repx * scenery.scenery_size[X] * 16) / 2
		rot_point[YPOS] = (repy * scenery.scenery_size[Y] * 16) / 2
		break
		
	case "block":
		rot_point[XPOS] = (repx * 16) / 2
		rot_point[YPOS] = (repy * 16) / 2
		break
		
	case "item":
		rot_point[XPOS] = 8
		rot_point[YPOS] = 0.5 * bool_to_float(item_3d)
		break
		
	case "text":
		break
	
	default:
		rot_point[ZPOS] = -8
		break
}

with (obj_timeline)
	if (temp = other.id)
		tl_update_rot_point()

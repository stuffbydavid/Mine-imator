/// temp_get_shape_texobj(value)
/// @arg value

var val = argument0;

if (val = 0)
	return 0

if (val)
{
	if (val.type = "camera")
	{
		if (surface_exists(val.cam_surf))
			return val
	}
	else if (val.texture)
		return val
}

return shape_tex

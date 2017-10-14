/// temp_get_shape_texobj(value)
/// @arg value

var val = argument0;

if (val = 0) // None
	return null

if (val = null) // Default
	return shape_tex
	
if (val.type = e_tl_type.CAMERA) // Object
{
	if (surface_exists(val.cam_surf))
		return val
}
else if (val.texture != null)
	return val

return null
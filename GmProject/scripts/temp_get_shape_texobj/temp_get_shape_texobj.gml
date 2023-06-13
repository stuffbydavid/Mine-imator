/// temp_get_shape_texobj(value)
/// @arg value
/// @desc Returns the object whose texture to use when rendering instances of the template.
/// A value (id) is supplied from a keyframe, if none is available then it is null.

function temp_get_shape_texobj(val)
{
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
}

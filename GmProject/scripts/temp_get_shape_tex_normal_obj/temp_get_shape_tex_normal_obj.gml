/// temp_get_shape_tex_normal_obj(value)
/// @arg value
/// @desc Returns the object whose texture to use when rendering instances of the template.
/// A value (id) is supplied from a keyframe, if none is available then it is null.

function temp_get_shape_tex_normal_obj(val)
{
	if (val = 0) // None
		return null
	
	if (val = null) // Default
		return shape_tex_normal
	
	if (val.texture != null)
		return val
	
	return null
}

/// temp_get_block_texobj(value)
/// @arg value
/// @desc Returns the resource whose texture to use when rendering instances of the template.
///		  A value (id) is supplied from a keyframe, if none is available then it is null.

var val = argument0;

if (val = null || val.type = e_tl_type.CAMERA || val.block_sheet_texture = null)
	return block_tex
	
return val;
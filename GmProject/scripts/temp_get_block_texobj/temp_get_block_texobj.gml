/// temp_get_block_texobj(value)
/// @arg value
/// @desc Returns the resource whose texture to use when rendering instances of the template.
/// A value (id) is supplied from a keyframe, if none is available then it is null.

function temp_get_block_texobj(val)
{
	if (val = null || val.type = e_tl_type.CAMERA || val.block_sheet_texture = null)
	{
		// Animatable block in scenery, use scenery's library setting(If it's a pack)
		if (object_index = obj_timeline && type = e_tl_type.BLOCK)
		{
			if (part_of.type = e_tl_type.SCENERY)
			{
				with (part_of)
				{
					if (temp.block_tex.type = e_res_type.PACK || temp.block_tex.type = e_res_type.BLOCK_SHEET)
						return temp.block_tex
				}
			}
		}
		else
			return block_tex
	}
	
	return val;
}

/// temp_get_block_tex_normal_obj(value)
/// @arg value
/// @desc Returns the resource whose texture to use when rendering instances of the template.
/// A value (id) is supplied from a keyframe, if none is available then it is null.

function temp_get_block_tex_normal_obj(val)
{
	if (val = null || val.type = e_tl_type.CAMERA || val.block_sheet_tex_normal = null)
	{
		// Animatable block in scenery, use scenery's library setting(If it's a pack)
		if (object_index = obj_timeline && type = e_tl_type.BLOCK)
		{
			if (part_of.type = e_tl_type.SCENERY)
			{
				with (part_of)
				{
					if (temp.block_tex_normal)
						if (temp.block_tex_normal.type = e_res_type.PACK || temp.block_tex_normal.type = e_res_type.BLOCK_SHEET)
							return temp.block_tex_normal
				}
			}
		}
		else
			return block_tex_normal
	}
	
	return val;
}

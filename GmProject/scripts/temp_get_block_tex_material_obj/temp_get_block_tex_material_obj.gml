/// temp_get_block_tex_material_obj(value)
/// @arg value
/// @desc Returns the resource whose texture to use when rendering instances of the template.
/// A value (id) is supplied from a keyframe, if none is available then it is null.

function temp_get_block_tex_material_obj(val)
{
	if (val != null)
		val = res_eval(val)

	if (val = null || val.type = e_tl_type.CAMERA || val.block_sheet_texture_material[e_block_sheet.STATIC16] = null)
	{
		// Animatable block in scenery, use scenery's library setting(If it's a pack)
		if (object_index = obj_timeline && type = e_tl_type.BLOCK)
		{
			if (part_of != null && part_of.type = e_tl_type.SCENERY)
			{
				with (part_of)
				{
					if (temp.block_tex_material)
						if (res_eval(temp.block_tex_material).type = e_res_type.PACK || res_eval(temp.block_tex_material).type = e_res_type.BLOCK_SHEET)
							return res_eval(temp.block_tex_material)
				}
			}
		}
		if (block_tex_material = null)
			return res_eval(project_pack_res)
		return res_eval(block_tex_material)
	}
	
	return val;
}

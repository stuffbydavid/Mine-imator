/// @arg name
/// @arg resource

function block_texture_get_blend(texname, res)
{
	var col = mc_assets.block_texture_color_map[?texname];
	if (is_undefined(col))
		return c_white
	
	if (is_real(col))
		return col
		
	var colorid = biome_color_name_map[? col];
	if (is_undefined(colorid))
		return c_white
	
	switch (colorid)
	{
		case e_color_palette.PUMPKIN_STEM: return c_pumpkin_stem
		case e_color_palette.MELON_STEM: return c_melon_stem
		case e_color_palette.LILY_PAD: return c_lily_pad
	}

	res = res_eval(res)
	return res.color_list[@ colorid]
}

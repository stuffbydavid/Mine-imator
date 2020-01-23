/// block_texture_get_blend(name, resource)
/// @arg name
/// @arg resource

var texname, res, col;
texname = argument0
res = argument1
col = mc_assets.block_texture_color_map[?texname]

if (!is_undefined(col))
{
	if (!res.ready)
		res = mc_res
	
	if (is_real(col))
		return col
		
	switch (col)
	{
		case "grass": return res.color_grass;
		case "foliage": return res.color_foliage;
		case "water": return res.color_water;
		
		case "oak_leaves": return res.color_leaves_oak;
		case "spruce_leaves": return res.color_leaves_spruce;
		case "birch_leaves": return res.color_leaves_birch;
		case "jungle": return res.color_leaves_jungle;
		case "acacia": return res.color_leaves_acacia;
		case "dark_oak": return res.color_leaves_dark_oak;
	}
}
	
return c_white
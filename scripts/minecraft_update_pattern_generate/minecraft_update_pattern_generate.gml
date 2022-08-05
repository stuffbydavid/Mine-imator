/// minecraft_update_pattern_generate(type, color, patterns, colors, [res])
/// @arg type
/// @arg color
/// @arg patterns
/// @arg colors
/// @arg [res]
/// @desc Generates and returns a pattern skin

function minecraft_update_pattern_generate()
{
	var type, color, patternlist, colorlist, res;
	var skinratio, maskarray, patternskin;
	type = argument[0]
	color = argument[1]
	patternlist = argument[2]
	colorlist = argument[3]
	res = mc_res
	
	var patternbase, patterndir;
	patternbase = (type = "banner" ? "entity/banner_base" : "entity/shield_base")
	patterndir = (type = "banner" ? "entity/banner/" : "entity/shield/")
	
	if (argument_count > 4)
		res = argument[4]
	
	skinratio = 1
	maskarray = array()
	
	// Don't bother generating patterns with colors
	if (res.type = e_res_type.SKIN)
		return sprite_duplicate(res.model_texture);
	
	draw_set_color(c_white)
	draw_set_alpha(1)
	
	// Get the max size to generate skin
	skinratio = max(skinratio, ceil(sprite_get_width(res.model_texture_map[?patternbase]) / sprite_get_width(mc_res.model_texture_map[?patternbase])))
	for (var i = 0; i < ds_list_size(minecraft_pattern_list); i++)
	{
		var patternname = minecraft_pattern_list[|i];
		skinratio = max(skinratio, ceil(sprite_get_width(res.model_texture_map[?patterndir + patternname]) / sprite_get_width(mc_res.model_texture_map[?patterndir + patternname])))
	}
	
	// Generate masks
	shader_mask = (res.pack_format < e_minecraft_pack.FORMAT_115)
	for (var i = 0; i < ds_list_size(minecraft_pattern_list); i++)
	{
		var patternname = minecraft_pattern_list[|i];
		array_add(maskarray, texture_create_crop(res.model_texture_map[?patterndir + patternname], 0, 0, 64 * skinratio, 64 * skinratio))
	}
	shader_mask = false
	
	// Create skin
	var patternsurf = surface_create(64 * skinratio, 64 * skinratio);
	
	surface_set_target(patternsurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_image(res.model_texture_map[?patternbase], 0, 0, 0)
		
		draw_image(maskarray[0], 0, 0, 0, 1, 1, color, 1)
		
		for (var i = 0; i < array_length(patternlist); i++)
		{
			var pattern = ds_list_find_index(minecraft_pattern_list, patternlist[i]);
			draw_image(maskarray[pattern], 0, 0, 0, 1, 1, colorlist[i], 1)
		}
		
		// Alpha fix
		gpu_set_blendmode_ext(bm_src_color, bm_one)
		draw_image(maskarray[0], 0, 0, 0, 1, 1, c_black, 1)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	patternskin = texture_surface(patternsurf)
	
	// Destroy pattern masks
	for (var i = 0; i < array_length(maskarray); i++)
		texture_free(maskarray[i])
	
	surface_free(patternsurf)
	
	return patternskin
}

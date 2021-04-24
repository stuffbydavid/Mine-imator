/// minecraft_banner_generate(color, patterns, colors, [res])
/// @arg color
/// @arg patterns
/// @arg colors
/// @arg [res]
/// @desc Generates and returns a banner skin using banner data

function minecraft_banner_generate()
{
	var color, patternlist, colorlist, res;
	var skinratio, maskarray, bannerskin;
	color = argument[0]
	patternlist = argument[1]
	colorlist = argument[2]
	res = mc_res
	
	if (argument_count > 3)
		res = argument[3]
	
	skinratio = 1
	maskarray = array()
	
	// Don't bother generating patterns with colors
	if (res.type = e_res_type.SKIN)
		return sprite_duplicate(res.model_texture);
	
	// Get the max size to generate banner skin
	skinratio = max(skinratio, ceil(sprite_get_width(res.model_texture_map[?"entity/banner_base"]) / sprite_get_width(mc_res.model_texture_map[?"entity/banner_base"])))
	for (var i = 0; i < ds_list_size(minecraft_banner_pattern_list); i++)
	{
		var bannername = minecraft_banner_pattern_list[|i];
		skinratio = max(skinratio, ceil(sprite_get_width(res.model_texture_map[?"entity/banner/" + bannername]) / sprite_get_width(mc_res.model_texture_map[?"entity/banner/" + bannername])))
	}
	
	// Generate masks
	shader_mask = (res.pack_format < e_minecraft_pack.FORMAT_115)
	for (var i = 0; i < ds_list_size(minecraft_banner_pattern_list); i++)
	{
		var bannername = minecraft_banner_pattern_list[|i];
		array_add(maskarray, texture_create_crop(res.model_texture_map[?"entity/banner/" + bannername], 0, 0, 42 * skinratio, 41 * skinratio))
	}
	shader_mask = false
	
	// Create banner skin
	var bannersurf = surface_create(64 * skinratio, 64 * skinratio);
	
	surface_set_target(bannersurf)
	{
		draw_clear_alpha(c_black, 0)
		
		draw_image(res.model_texture_map[?"entity/banner_base"], 0, 0, 0)
		
		draw_image(maskarray[0], 0, 0, 0, 1, 1, color, 1)
		
		for (var i = 0; i < array_length(patternlist); i++)
		{
			var pattern = ds_list_find_index(minecraft_banner_pattern_list, patternlist[i]);
			draw_image(maskarray[pattern], 0, 0, 0, 1, 1, colorlist[i], 1)
		}
		
		// Alpha fix
		gpu_set_blendmode_ext(bm_src_color, bm_one) 
		draw_image(maskarray[0], 0, 0, 0, 1, 1, c_black, 1)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	// Destroy pattern masks
	for (var i = 0; i < array_length(maskarray); i++)
		texture_free(maskarray[i])
	
	bannerskin = texture_surface(bannersurf);
	surface_free(bannersurf)
	
	return bannerskin
}

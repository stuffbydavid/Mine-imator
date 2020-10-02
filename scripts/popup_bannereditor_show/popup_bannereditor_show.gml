/// popup_bannereditor_show(bannerobj)
/// @arg bannerobj

var bannerobj;
bannerobj = argument0

with (popup_bannereditor)
{
	preview.zoom = .6
	preview.goalzoom = .6
	preview.xyangle = 235
	preview.zangle = 0
	
	banner_edit = bannerobj
	
	with (banner_edit)
		other.banner_edit_preview = instance_copy(false)
	
	banner_edit_preview.model_tex = null
	
	preview.select = banner_edit_preview
	preview.last_select = banner_edit_preview
	
	ds_list_clear(pattern_list_edit)
	ds_list_clear(pattern_color_list_edit)
	
	for (var i = 0; i < array_length_1d(bannerobj.banner_pattern_list); i++)
		ds_list_add(pattern_list_edit, bannerobj.banner_pattern_list[i])
	
	for (var i = 0; i < array_length_1d(bannerobj.banner_color_list); i++)
		ds_list_add(pattern_color_list_edit, bannerobj.banner_color_list[i])
	
	var res;
	if (banner_edit.model_tex.type = e_res_type.SKIN)
		res = mc_res
	else
		res = banner_edit.model_tex
	
	// Generate pattern sprites
	if (pattern_resource != res || array_length_1d(pattern_sprites) = 0)
	{
		// Clear previous patterns
		for (var i = 0; i < array_length_1d(pattern_sprites); i++)
			sprite_delete(pattern_sprites[i])
		pattern_sprites = array()
		
		// Create new pattern sprites
		res_ratio = ceil(sprite_get_width(res.model_texture_map[?"entity/banner_base"]) / sprite_get_width(mc_res.model_texture_map[?"entity/banner_base"]))
		
		shader_mask = (res.pack_format < e_minecraft_pack.FORMAT_115)
		for (var i = 0; i < ds_list_size(minecraft_banner_pattern_list); i++)
		{
			var bannername = minecraft_banner_pattern_list[|i];
			array_add(pattern_sprites, texture_create_crop(res.model_texture_map[?"entity/banner/" + bannername], res_ratio, res_ratio, 20 * res_ratio, 40 * res_ratio))
		}
		shader_mask = false
		
		// Crop texture
		array_add(pattern_sprites, texture_create_crop(res.model_texture_map[?"entity/banner_base"], res_ratio, res_ratio, 20 * res_ratio, 40 * res_ratio))
		
		pattern_resource = res
	}
	
	update = true
}

popup_show(popup_bannereditor)
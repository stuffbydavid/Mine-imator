/// popup_pattern_editor_show(obj)
/// @arg obj

function popup_pattern_editor_show(obj)
{
	with (popup_pattern_editor)
	{
		preview.zoom = .6
		preview.goalzoom = .6
		preview.xyangle = 235
		preview.zangle = 0
		
		pattern_edit = obj
		
		with (pattern_edit)
			other.pattern_edit_preview = instance_copy(false)
		
		preview.select = pattern_edit_preview
		preview.last_select = pattern_edit_preview
		
		ds_list_clear(pattern_list_edit)
		ds_list_clear(pattern_color_list_edit)
		
		for (var i = 0; i < array_length(obj.pattern_pattern_list); i++)
			ds_list_add(pattern_list_edit, obj.pattern_pattern_list[i])
		
		for (var i = 0; i < array_length(obj.pattern_color_list); i++)
			ds_list_add(pattern_color_list_edit, obj.pattern_color_list[i])
		
		var res;
		if (pattern_edit.model_tex.type = e_res_type.SKIN)
			res = mc_res
		else
			res = pattern_edit.model_tex
		
		pattern_edit_preview.model_tex = res
		
		// Generate pattern sprites
		if (pattern_resource != res || array_length(pattern_sprites) = 0)
		{
			// Clear previous patterns
			for (var i = 0; i < array_length(pattern_sprites); i++)
				sprite_delete(pattern_sprites[i])
			
			pattern_sprites = array()
			
			// Create new pattern sprites
			res_ratio = ceil(sprite_get_width(res.model_texture_map[?"entity/banner_base"]) / sprite_get_width(mc_res.model_texture_map[?"entity/banner_base"]))
			
			shader_mask = (res.pack_format < e_minecraft_pack.FORMAT_115)
			for (var i = 0; i < ds_list_size(minecraft_pattern_list); i++)
			{
				var bannername = minecraft_pattern_list[|i];
				array_add(pattern_sprites, texture_create_crop(res.model_texture_map[?"entity/banner/" + bannername], res_ratio, res_ratio, 20 * res_ratio, 40 * res_ratio))
			}
			shader_mask = false
			
			// Crop texture
			array_add(pattern_sprites, texture_create_crop(res.model_texture_map[?"entity/banner_base"], res_ratio, res_ratio, 20 * res_ratio, 40 * res_ratio))
			
			pattern_resource = res
		}
		
		update = true
	}
	
	popup_show(popup_pattern_editor)
}

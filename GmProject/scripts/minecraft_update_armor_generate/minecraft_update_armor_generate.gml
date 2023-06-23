/// minecraft_update_armor_generate(data, [res])
/// @arg data
/// @arg [res]
/// @desc Generates and returns 4 armor skins

function minecraft_update_armor_generate(data, res = null)
{
	var skins = [null, null, null, null];
	if (res = null || !res_is_ready(res))
		res = mc_res
	
	for (var i = 0; i < 4; i++)
	{
		var piece = i * 4;
		var basemat, dye, trimpat, trimmat, layernum, basetex, basesprite;
		basemat = data[piece]
		
		if (basemat = "none")
			continue
		
		dye = data[piece + 1]
		trimpat = data[piece + 2]
		trimmat = data[piece + 3]
		layernum = ((i = 2) ? "2" : "1")
		
		basetex = "models/armor/" + basemat + "_layer_" + layernum
		basesprite = res.model_texture_map[?basetex]
		
		var armorsurf = surface_create(sprite_get_width(basesprite), sprite_get_height(basesprite)); 
		
		// Generate armor skin
		surface_set_target(armorsurf)
		{
			draw_clear_alpha(c_black, 0)
			
			// Base texture
			if (basemat = "leather")
			{
				draw_texture(basesprite, 0, 0, 1, 1, dye, 1)
				draw_texture(res.model_texture_map[?basetex + "_overlay"], 0, 0)
			}
			else
				draw_texture(basesprite, 0, 0)
		}
		surface_reset_target()
		
		// Trim
		if (trimpat != "none" && trimmat != "none")
		{
			var palette = res.model_texture_map[?"trims/color_palettes/" + trimmat + (trimmat = basemat ? "_darker" : "")];
			
			surface_set_target(armorsurf)
			{
				gpu_set_texrepeat(false)
				render_shader_obj = shader_map[?shader_palette]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_palette_set(palette, res.model_texture_map[?"trims/color_palettes/trim_palette"])
				}
				
				if (i = 2)
					draw_sprite(res.model_texture_map[?"trims/models/armor/" + trimpat + "_leggings"], 0, 0, 0)
				else
					draw_sprite(res.model_texture_map[?"trims/models/armor/" + trimpat], 0, 0, 0)
				
				with (render_shader_obj)
					shader_reset()
				
				gpu_set_texrepeat(true)
			}
			surface_reset_target()
		}
		
		skins[i] = texture_surface(armorsurf);
		surface_free(armorsurf)
	}
	
	return skins;
}

/// minecraft_update_armor_generate(model, data, [res])
/// @arg model
/// @arg data
/// @arg [res]
/// @desc Generates and returns 4 armor skins

function minecraft_update_armor_generate(model, data, res = null)
{
	var skins = [null, null, null, null];
	if (res = null || !res_is_ready(res) || (res.type != e_res_type.PACK && res.type != e_res_type.PACK_UNZIPPED))
		res = mc_res
	
	for (var i = 0; i < 4; i++)
	{
		var piece = i * 4;
		var basemat, dye, trimpat, trimmat, layername, basetex, basesprite;
		basemat = data[piece]
		
		if (basemat = "none")
			continue
		
		dye = data[piece + 1]
		trimpat = data[piece + 2]
		trimmat = data[piece + 3]
		//layernum = ((i = 2) ? "2" : "1")
		
		if (model == "armor_baby")
			layername = "humanoid_baby"
		else
			layername = (i = 2) ? "humanoid_leggings" : "humanoid"
		
		basetex = "entity/equipment/" + layername + "/" + basemat
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
		if (model != "armor_baby" && (trimpat != "none" && trimmat != "none"))
		{
			var palette = res.model_texture_map[?"palettes/trim/" + trimmat + (trimmat = basemat ? "_darker" : "")];
			
			surface_set_target(armorsurf)
			{
				gpu_set_texrepeat(false)
				render_shader_obj = shader_map[?shader_palette]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_palette_set(palette, res.model_texture_map[?"palettes/trim_base"])
				}
				
				draw_sprite(res.model_texture_map[?"trims/entity/" + layername + "/" + trimpat], 0, 0, 0)
				
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

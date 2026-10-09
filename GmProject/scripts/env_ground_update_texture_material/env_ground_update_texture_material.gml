/// @desc Updates the ground sprite depending on the chosen slot and texture.

function env_ground_update_texture_material()
{
	var texres  = res_eval(env_ground_tex_material);
	if (!texres.ready || (env_ground_slot = env_ground_slot_material && texres.save_id = env_ground_tex_material_prev))
		return 0
	
	env_ground_slot_material = env_ground_slot
	env_ground_tex_material_prev = texres.save_id
	
	// Clear old
	if (env_ground_material_ani)
	{
		if (env_ground_ani_texture_material[0] != null)
			for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
				texture_free(env_ground_ani_texture_material[f])
	}
	else if (env_ground_texture_material != null)
		texture_free(env_ground_texture_material)
	
	var size, bx, by, surf, decodedslot, sheet, slot;
	decodedslot = minecraft_assets_block_texture_picker_slot_decode(env_ground_slot)
	sheet = decodedslot[0]
	slot = decodedslot[1]
	
	if (sheet < 0)
	{
		env_ground_material_ani = false
		env_ground_texture_material = null
		
		return 0
	}
	
	if (texres.block_sheet_texture_material[sheet] = null)
		texres = mc_res
	
	if (texres.block_sheet_texture_material[sheet] = null ||
		(sheet = e_block_sheet.ANIMATED && texres.block_sheet_texture_material[sheet][0] = null))
	{
		env_ground_material_ani = false
		env_ground_texture_material = null
		
		return 0
	}
	
	// In static block list
	if (sheet != e_block_sheet.ANIMATED)
	{
		env_ground_material_ani = false
		
		size = ceil(texture_width(texres.block_sheet_texture_material[sheet]) / minecraft_block_sheet_size[sheet][X])
		bx = (slot mod minecraft_block_sheet_size[sheet][X]) * size
		by = (slot div minecraft_block_sheet_size[sheet][X]) * size
	}
	
	// In animated block list
	else
	{
		env_ground_material_ani = true
		
		size = ceil(texture_width(texres.block_sheet_texture_material[e_block_sheet.ANIMATED][0]) / minecraft_block_sheet_size[e_block_sheet.ANIMATED][X])
		bx = (slot mod minecraft_block_sheet_size[e_block_sheet.ANIMATED][X]) * size
		by = (slot div minecraft_block_sheet_size[e_block_sheet.ANIMATED][X]) * size
	}
	
	draw_texture_start()
	
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		// Animated
		if (env_ground_material_ani)
		{
			for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
			{
				draw_clear_alpha(c_black, 0)
				draw_texture_part(texres.block_sheet_texture_material[e_block_sheet.ANIMATED][f], 0, 0, bx, by, size, size)
				
				env_ground_ani_texture_material[f] = texture_surface(surf, true, false)
			}
		}
		
		// Static
		else
		{
			draw_clear_alpha(c_black, 0)
			draw_texture_part(texres.block_sheet_texture_material[sheet], 0, 0, bx, by, size, size)
			
			env_ground_texture_material = texture_surface(surf, true, false)
		}
	}
	surface_reset_target()
	surface_free(surf)
	
	draw_texture_done()
}

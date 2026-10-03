/// @desc Updates the ground sprite depending on the chosen slot and texture.

function env_ground_update_texture()
{
	var texres = res_eval(env_ground_tex);
	if (!texres.ready || (env_ground_slot = env_ground_slot_prev && texres.save_id = env_ground_tex_prev))
		return 0
	
	env_ground_slot_prev = env_ground_slot
	env_ground_tex_prev = texres.save_id
	
	// Clear old
	if (env_ground_ani)
	{
		if (env_ground_ani_texture[0] != null)
			for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
				texture_free(env_ground_ani_texture[f])
	}
	else if (env_ground_texture != null)
		texture_free(env_ground_texture)
	
	var size, bx, by, surf, decodedslot, sheet, slot;
	decodedslot = minecraft_assets_block_texture_picker_slot_decode(env_ground_slot)
	sheet = decodedslot[0]
	slot = decodedslot[1]
	
	if (sheet < 0)
	{
		env_ground_ani = false
		env_ground_texture = texture_create_missing()
		env_ground_name = ""
		
		return 0
	}
	
	if (texres.block_sheet_texture[sheet] = null)
		texres = mc_res
	
	// In static block list
	if (sheet != e_block_sheet.ANIMATED)
	{
		env_ground_ani = false
		env_ground_name = mc_assets.block_texture_list[sheet][|slot]
		
		size = texture_width(texres.block_sheet_texture[sheet]) / minecraft_block_sheet_size[sheet][X]
		bx = (slot mod minecraft_block_sheet_size[sheet][X]) * size
		by = (slot div minecraft_block_sheet_size[sheet][X]) * size
	}
	
	// In animated block list
	else
	{
		// Static block sheet only
		if (texres.block_sheet_texture[e_block_sheet.ANIMATED] = null)
		{
			env_ground_ani = false
			env_ground_texture = texture_create_missing()
			env_ground_name = ""
			
			return 0
		}
		
		env_ground_ani = true
		env_ground_name = mc_assets.block_texture_ani_list[|slot]
		
		size = texture_width(texres.block_sheet_texture[e_block_sheet.ANIMATED][0]) / minecraft_block_sheet_size[e_block_sheet.ANIMATED][X]
		bx = (slot mod minecraft_block_sheet_size[e_block_sheet.ANIMATED][X]) * size
		by = (slot div minecraft_block_sheet_size[e_block_sheet.ANIMATED][X]) * size
	}
	
	draw_texture_start()
	
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		// Animated
		if (env_ground_ani)
		{
			for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
			{
				draw_clear_alpha(c_black, 0)
				draw_texture_part(texres.block_sheet_texture[e_block_sheet.ANIMATED][f], 0, 0, bx, by, size, size)
				
				env_ground_ani_texture[f] = texture_surface(surf)
				sprite_set_texture_page(env_ground_ani_texture[f], false)
			}
		}
		
		// Static
		else
		{
			draw_clear_alpha(c_black, 0)
			draw_texture_part(texres.block_sheet_texture[sheet], 0, 0, bx, by, size, size)
			
			env_ground_texture = texture_surface(surf)
			sprite_set_texture_page(env_ground_texture, false)
		}
	}
	surface_reset_target()
	surface_free(surf)
	
	draw_texture_done()
}

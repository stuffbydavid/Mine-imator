/// background_ground_update_texture()
/// @desc Updates the ground sprite depending on the chosen slot and texture.

function background_ground_update_texture()
{
	if (!background_ground_tex.ready || (background_ground_slot = background_ground_slot_prev && background_ground_tex.save_id = background_ground_tex_prev))
		return 0
	
	background_ground_slot_prev = background_ground_slot
	background_ground_tex_prev = background_ground_tex.save_id
	
	// Clear old
	if (background_ground_ani)
	{
		if (background_ground_ani_texture[0] != null)
			for (var f = 0; f < block_sheet_ani_frames; f++)
				texture_free(background_ground_ani_texture[f])
	}
	else if (background_ground_texture != null)
		texture_free(background_ground_texture)
	
	var size, bx, by, surf, tex;
	
	// In static block list
	if (background_ground_slot < ds_list_size(mc_assets.block_texture_list))
	{
		background_ground_ani = false
		background_ground_name = mc_assets.block_texture_list[|background_ground_slot]
		size = texture_width(background_ground_tex.block_sheet_texture) / block_sheet_width
		bx = (background_ground_slot mod block_sheet_width) * size
		by = (background_ground_slot div block_sheet_width) * size
	}
	
	// In animated block list
	else
	{
		// Static block sheet only
		if (background_ground_tex.block_sheet_ani_texture = null)
		{
			background_ground_ani = false
			background_ground_texture = texture_create_missing()
			background_ground_name = ""
			return 0
		}
		
		var slot = background_ground_slot - ds_list_size(mc_assets.block_texture_list);
		background_ground_ani = true
		background_ground_name = mc_assets.block_texture_ani_list[|slot]
		size = texture_width(background_ground_tex.block_sheet_ani_texture[0]) / block_sheet_ani_width
		bx = (slot mod block_sheet_ani_width) * size
		by = (slot div block_sheet_ani_width) * size
	}
	
	draw_texture_start()
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		// Animated
		if (background_ground_ani)
		{
			for (var f = 0; f < block_sheet_ani_frames; f++)
			{
				draw_clear_alpha(c_black, 0)
				draw_texture_part(background_ground_tex.block_sheet_ani_texture[f], 0, 0, bx, by, size, size)
				background_ground_ani_texture[f] = texture_surface(surf)
				sprite_set_texture_page(background_ground_ani_texture[f], false)
			}
		}
		
		// Static
		else
		{
			draw_clear_alpha(c_black, 0)
			draw_texture_part(background_ground_tex.block_sheet_texture, 0, 0, bx, by, size, size)
			background_ground_texture = texture_surface(surf)
			sprite_set_texture_page(background_ground_texture, false)
		}
	}
	surface_reset_target()
	surface_free(surf)
	draw_texture_done()
}

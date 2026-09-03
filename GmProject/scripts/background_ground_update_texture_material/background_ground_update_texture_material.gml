/// background_ground_update_texture_material()
/// @desc Updates the ground sprite depending on the chosen slot and texture.

function background_ground_update_texture_material()
{
	if (!background_ground_tex_material.ready || (background_ground_slot = background_ground_slot_material && background_ground_tex_material.save_id = background_ground_tex_material_prev))
		return 0
	
	background_ground_slot_material = background_ground_slot
	background_ground_tex_material_prev = background_ground_tex_material.save_id
	
	// Clear old
	if (background_ground_material_ani)
	{
		if (background_ground_ani_texture_material[0] != null)
			for (var f = 0; f < minecraft_block_animated_sheet_size[2]; f++)
				texture_free(background_ground_ani_texture_material[f])
	}
	else if (background_ground_texture_material != null)
		texture_free(background_ground_texture_material)
	
	var size, bx, by, surf, tex;
	
	// In static block list
	if (background_ground_slot < ds_list_size(mc_assets.block_texture_list))
	{
		background_ground_material_ani = false
		size = ceil(texture_width(background_ground_tex_material.block_sheet_texture_material) / minecraft_block_sheet_size[0])
		bx = (background_ground_slot mod minecraft_block_sheet_size[0]) * size
		by = (background_ground_slot div minecraft_block_sheet_size[0]) * size
	}
	
	// In animated block list
	else
	{
		// Static block sheet only
		if (background_ground_tex_material.block_sheet_ani_texture_material = null)
		{
			background_ground_material_ani = false
			background_ground_texture_material = texture_create_fill(c_black)
			return 0
		}
		
		var slot = background_ground_slot - ds_list_size(mc_assets.block_texture_list);
		background_ground_material_ani = true
		size = ceil(texture_width(background_ground_tex_material.block_sheet_ani_texture_material[0]) / minecraft_block_animated_sheet_size[0])
		bx = (slot mod minecraft_block_animated_sheet_size[0]) * size
		by = (slot div minecraft_block_animated_sheet_size[0]) * size
	}
	
	draw_texture_start()
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		// Animated
		if (background_ground_material_ani)
		{
			for (var f = 0; f < minecraft_block_animated_sheet_size[2]; f++)
			{
				draw_clear_alpha(c_black, 0)
				draw_texture_part(background_ground_tex_material.block_sheet_ani_texture_material[f], 0, 0, bx, by, size, size)
				background_ground_ani_texture_material[f] = texture_surface(surf)
			}
		}
		
		// Static
		else
		{
			draw_clear_alpha(c_black, 0)
			draw_texture_part(background_ground_tex_material.block_sheet_texture_material, 0, 0, bx, by, size, size)
			background_ground_texture_material = texture_surface(surf)
		}
	}
	surface_reset_target()
	surface_free(surf)
	draw_texture_done()
}

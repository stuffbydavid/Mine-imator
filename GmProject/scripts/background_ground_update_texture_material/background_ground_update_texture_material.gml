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
			for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
				texture_free(background_ground_ani_texture_material[f])
	}
	else if (background_ground_texture_material != null)
		texture_free(background_ground_texture_material)
	
	var size, bx, by, surf, tex;
	var decodedslot = minecraft_assets_block_texture_picker_slot_decode(background_ground_slot)
	var sheet = decodedslot[0]
	var slot = decodedslot[1]
	var texres = background_ground_tex_material
	if (sheet < 0)
	{
		background_ground_material_ani = false
		background_ground_texture_material = texture_create_fill(c_black)
		return 0
	}
	if (texres.block_sheet_texture_material[sheet] = null)
		texres = mc_res
	
	// In static block list
	if (sheet != e_block_sheet.ANIMATED)
	{
		background_ground_material_ani = false
		size = ceil(texture_width(texres.block_sheet_texture_material[sheet]) / minecraft_block_sheet_size[sheet][X])
		bx = (slot mod minecraft_block_sheet_size[sheet][X]) * size
		by = (slot div minecraft_block_sheet_size[sheet][X]) * size
	}
	
	// In animated block list
	else
	{
		// Static block sheet only
		if (texres.block_sheet_texture_material[e_block_sheet.ANIMATED] = null)
		{
			background_ground_material_ani = false
			background_ground_texture_material = texture_create_fill(c_black)
			return 0
		}
		
		background_ground_material_ani = true
		size = ceil(texture_width(texres.block_sheet_texture_material[e_block_sheet.ANIMATED][0]) / minecraft_block_sheet_size[e_block_sheet.ANIMATED][X])
		bx = (slot mod minecraft_block_sheet_size[e_block_sheet.ANIMATED][X]) * size
		by = (slot div minecraft_block_sheet_size[e_block_sheet.ANIMATED][X]) * size
	}
	
	draw_texture_start()
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		// Animated
		if (background_ground_material_ani)
		{
			for (var f = 0; f < minecraft_block_animated_sheet_frame_count; f++)
			{
				draw_clear_alpha(c_black, 0)
				draw_texture_part(texres.block_sheet_texture_material[e_block_sheet.ANIMATED][f], 0, 0, bx, by, size, size)
				background_ground_ani_texture_material[f] = texture_surface(surf)
			}
		}
		
		// Static
		else
		{
			draw_clear_alpha(c_black, 0)
			draw_texture_part(texres.block_sheet_texture_material[sheet], 0, 0, bx, by, size, size)
			background_ground_texture_material = texture_surface(surf)
		}
	}
	surface_reset_target()
	surface_free(surf)
	draw_texture_done()
}

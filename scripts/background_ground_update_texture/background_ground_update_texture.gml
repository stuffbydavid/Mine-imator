/// background_ground_update_texture()
/// @desc Updates the ground sprite depending on the chosen tile and texture.

if (!background_ground_tex.ready)
    return 0

// Clear old
if (background_ground_ani)
{
	if (background_ground_ani_texture[0])
		for (var f = 0; f < block_sheet_ani_frames; f++)
		    texture_free(background_ground_ani_texture[f])
}
else if (background_ground_texture)
	texture_free(background_ground_texture)
	
var slot, size, bx, by, surf;
slot = ds_list_find_index(mc_version.block_texture_list, background_ground_name)

// Check animated block list
if (slot < 0)
{
	slot = ds_list_find_index(mc_version.block_texture_ani_list, background_ground_name)
	if (slot < 0)
		return 0

	background_ground_ani = true
	size = texture_width(background_ground_tex.block_sheet_ani_texture[0]) / block_sheet_ani_width
	bx = (slot mod block_sheet_ani_width) * size
	by = (slot div block_sheet_ani_width) * size
}
else
{
	background_ground_ani = false
	size = texture_width(background_ground_tex.block_sheet_texture) / block_sheet_width
	bx = (slot mod block_sheet_width) * size
	by = (slot div block_sheet_width) * size
}

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
		}
	}
	
	// Static
	else
	{
        draw_clear_alpha(c_black, 0)
        draw_texture_part(background_ground_tex.block_sheet_texture, 0, 0, bx, by, size, size)
		background_ground_texture = texture_surface(surf)
	}
}
surface_reset_target()
surface_free(surf)

background_ground_slot = slot
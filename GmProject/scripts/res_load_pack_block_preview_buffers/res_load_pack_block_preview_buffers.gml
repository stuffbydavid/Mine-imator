/// res_load_pack_block_preview_buffers()
/// @desc Creates block preview buffers from cached sheets.

function res_load_pack_block_preview_buffers()
{
	var tex, surf, frames;
	tex = null
	surf = null
	frames = null
	draw_texture_start()
	
	// Create static sheet previews
	for (var size = 0; size < e_block_sheet.static_amount; size++)
	{
		tex = block_sheet_texture[size]
		if (tex <= 0)
			continue

		surf = surface_create(minecraft_block_sheet_size[size][X], minecraft_block_sheet_size[size][Y])
		surface_set_target(surf)
		{
			gpu_set_tex_filter(true)
			draw_clear_alpha(c_black, 0)
			draw_texture_part(tex, 0, 0, 0, 0, texture_width(tex), texture_height(tex), 1 / block_size_list[size], 1 / block_size_list[size])
			gpu_set_tex_filter(false)
		}
		surface_reset_target()

		if (load_assets_block_preview_buffer[size] != null)
			buffer_delete(load_assets_block_preview_buffer[size])
		
		load_assets_block_preview_buffer[size] = buffer_create(minecraft_block_sheet_size[size][X] * minecraft_block_sheet_size[size][Y] * 4, buffer_fixed, 4)
		buffer_get_surface(load_assets_block_preview_buffer[size], surf, 0)
		surface_free(surf)
	}
	
	// Create animated sheet preview
	frames = block_sheet_texture[e_block_sheet.ANIMATED]
	if (frames != null && array_length(frames) > 0 && frames[0] > 0)
	{
		surf = surface_create(minecraft_block_sheet_size[e_block_sheet.ANIMATED][X], minecraft_block_sheet_size[e_block_sheet.ANIMATED][Y])
		surface_set_target(surf)
		{
			draw_clear_alpha(c_black, 0)
			draw_texture_part(frames[0], 0, 0, 0, 0, texture_width(frames[0]), texture_height(frames[0]), 1 / block_size, 1 / block_size)
		}
		surface_reset_target()

		if (load_assets_block_preview_ani_buffer != null)
			buffer_delete(load_assets_block_preview_ani_buffer)
		
		load_assets_block_preview_ani_buffer = buffer_create(minecraft_block_sheet_size[e_block_sheet.ANIMATED][X] * minecraft_block_sheet_size[e_block_sheet.ANIMATED][Y] * 4, buffer_fixed, 4)
		buffer_get_surface(load_assets_block_preview_ani_buffer, surf, 0)
		surface_free(surf)
	}
	draw_texture_done()
	return 0
}

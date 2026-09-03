/// res_update_block_preview()
/// @desc Updates the preview of a loaded terrain file.

function res_update_block_preview()
{
	if (block_preview_texture)
		texture_free(block_preview_texture)
	
	var surf, size;
	size = texture_width(block_sheet_texture) / minecraft_block_sheet_size[0]
	surf = surface_create(32, 32)
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		draw_texture_slot(block_sheet_texture, ds_list_find_index(mc_assets.block_texture_list, "block/stone"), 0, 0, size, size, minecraft_block_sheet_size[0], minecraft_block_sheet_size[1])
		draw_texture_slot(block_sheet_texture, ds_list_find_index(mc_assets.block_texture_list, "block/grass_side"), 16, 0, size, size, minecraft_block_sheet_size[0], minecraft_block_sheet_size[1])
		draw_texture_slot(block_sheet_texture, ds_list_find_index(mc_assets.block_texture_list, "block/tnt_side"), 0, 16, size, size, minecraft_block_sheet_size[0], minecraft_block_sheet_size[1])
		draw_texture_slot(block_sheet_texture, ds_list_find_index(mc_assets.block_texture_list, "block/sapling_oak"), 16, 16, size, size, minecraft_block_sheet_size[0], minecraft_block_sheet_size[1])
	}
	surface_reset_target()
	
	block_preview_texture = texture_surface(surf)
	surface_free(surf)
}

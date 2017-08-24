/// res_update_block_preview()
/// @desc Updates the preview of a loaded terrain file.

if (block_preview_texture)
	texture_free(block_preview_texture)
	
var surf, size;
size = texture_width(block_sheet_texture) / block_sheet_width
surf = surface_create(32, 32)
surface_set_target(surf)
{
	draw_clear_alpha(c_black, 0)
	draw_texture_slot(block_sheet_texture, ds_list_find_index(mc_assets.block_texture_list, "blocks/stone"), 0, 0, size, size, block_sheet_width, block_sheet_height)
	draw_texture_slot(block_sheet_texture, ds_list_find_index(mc_assets.block_texture_list, "blocks/grass_side"), 16, 0, size, size, block_sheet_width, block_sheet_height)
	draw_texture_slot(block_sheet_texture, ds_list_find_index(mc_assets.block_texture_list, "blocks/tnt_side"), 0, 16, size, size, block_sheet_width, block_sheet_height)
	draw_texture_slot(block_sheet_texture, ds_list_find_index(mc_assets.block_texture_list, "blocks/sapling_oak"), 16, 16, size, size, block_sheet_width, block_sheet_height)
}
surface_reset_target()

block_preview_texture = texture_surface(surf)
surface_free(surf)

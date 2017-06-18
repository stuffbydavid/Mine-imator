/// res_update_block_preview()
/// @desc Updates the preview of a loaded terrain file.

var surf, size;

if (block_preview_texture)
    texture_free(block_preview_texture)
size = texture_width(block_texture[0]) / 32

surf = surface_create(32, 32)
surface_set_target(surf)
{
    draw_clear_alpha(c_black, 0)
    draw_texture_part(block_texture[0], 0, 0, 0, 0, size, size * 2, 16 / size, 16 / size) // Stone & Cobblestone
    draw_texture_part(block_texture[0], 16, 0, size, 0, size, size, 16 / size, 16 / size, res_def.color_grass, 1) // Grass
    draw_texture_part(block_texture[0], 16, 16, 16 * size, 10 * size, size, size, 16 / size, 16 / size) // TNT
}
surface_reset_target()

block_preview_texture = texture_surface(surf)
surface_free(surf)

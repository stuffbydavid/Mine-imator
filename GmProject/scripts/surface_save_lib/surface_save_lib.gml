/// surface_save_lib(surface, filename, [straightalpha])
/// @arg surface
/// @arg filename
/// @arg [straightalpha]

function surface_save_lib(surf, fn, straightalpha = false)
{
	if (straightalpha)
	{
		render_surface[1] = surface_require(render_surface[1], surface_get_width(surf), surface_get_height(surf))
		surface_set_target(render_surface[1])
		{
			draw_clear_alpha(c_black, 0)
			gpu_set_blendmode_ext(bm_one, bm_zero)
			shader_set(shader_map[?shader_unpremultiply].shader)
			draw_surface(surf, 0, 0)
			shader_reset()
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		surf = render_surface[1]
	}

	if (!file_copy_temp || string_contains(fn, file_directory_get()))
	{
		surface_save(surf, fn)
		return 0
	}
	file_delete_lib(temp_image)
	surface_save(surf, temp_image)
	file_copy_lib(temp_image, fn)
}

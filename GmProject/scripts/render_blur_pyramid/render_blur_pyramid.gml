/// render_blur_pyramid(surf, radius, weight, [hdr], [levels], [dirx], [diry], [radiusdiv])
/// @arg surf
/// @arg radius
/// @arg weight
/// @arg [hdr]
/// @arg [levels]
/// @arg [dirx]
/// @arg [diry]
/// @arg [radiusdiv]

function render_blur_pyramid(surf, radius, weight, hdr = false, levels = 6, dirx = undefined, diry = undefined, radiusdiv = 8)
{
	// Return original surf if no radius (prevents downsamples from showing)
	if (radius <= 0)
	{
		var format = hdr ? e_surface_format.rgba32float : e_surface_format.rgba8unorm;
		render_surface_blur[0] = surface_require(render_surface_blur[0], render_width, render_height, false, format)
		surface_set_target(render_surface_blur[0])
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_exists(surf, 0, 0)
		}
		surface_reset_target()
		return 1;
	}

	var downsource = surf;
	var directional = dirx != undefined && diry != undefined;
	var blurx = directional ? dirx : 1;
	var blury = directional ? diry : 0;

	// Each level keeps a similar blur radius in its own pixels
	for (var i = 0; i < levels; i++)
	{
		var scale = power(2, i + 1);
		var levelwidth = max(1, ceil(render_width / scale));
		var levelheight = max(1, ceil(render_height / scale));
		var format = hdr ? e_surface_format.rgba32float : e_surface_format.rgba8unorm;
		render_surface_blur[i] = surface_require(render_surface_blur[i], levelwidth, levelheight, false, format)
		render_surface_blur_temp[i] = surface_require(render_surface_blur_temp[i], levelwidth, levelheight, false, format)

		gpu_set_texfilter(true)
		surface_set_target(render_surface_blur[i])
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_size(downsource, 0, 0, levelwidth, levelheight)
		}
		surface_reset_target()
		gpu_set_texfilter(false)

		var blurradius = radius * scale / radiusdiv;
		surface_set_target(render_surface_blur_temp[i])
		{
			render_shader_obj = shader_map[?shader_blur]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_blur_set(render_blur_kernel, blurradius, blurx, blury, true)
			}
			draw_surface_exists(render_surface_blur[i], 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()

		if (!directional)
		{
			surface_set_target(render_surface_blur[i])
			{
				render_shader_obj = shader_map[?shader_blur]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_blur_set(render_blur_kernel, blurradius, 0, 1, true)
				}
				draw_surface_exists(render_surface_blur_temp[i], 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
		}

		downsource = directional ? render_surface_blur_temp[i] : render_surface_blur[i]
	}

	// Reconstruct the pyramid with the requested weight for broader levels
	if (directional)
	{
		surface_set_target(render_surface_blur[levels - 1])
		{
			draw_surface_exists(render_surface_blur_temp[levels - 1], 0, 0)
		}
		surface_reset_target()

		for (var i = levels - 2; i >= 0; i--)
		{
			surface_set_target(render_surface_blur[i])
			{
				render_shader_obj = shader_map[?shader_add]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_add_set(render_surface_blur[i + 1], weight, c_white, 1, true)
				}
				draw_surface_exists(render_surface_blur_temp[i], 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
		}
	}
	else
	{
		for (var i = levels - 2; i >= 0; i--)
		{
			surface_set_target(render_surface_blur_temp[i])
			{
				render_shader_obj = shader_map[?shader_add]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_add_set(render_surface_blur[i + 1], weight, c_white, 1, true)
				}
				draw_surface_exists(render_surface_blur[i], 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()

			surface_set_target(render_surface_blur[i])
			{
				draw_surface_exists(render_surface_blur_temp[i], 0, 0)
			}
			surface_reset_target()
		}
	}

	var totalweight = 0;
	for (var i = 0; i < levels; i++)
		totalweight += power(weight, i)
	return totalweight;
}

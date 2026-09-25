/// render_high_glow(basesurf, [hdr])
/// @arg basesurf
/// @arg [hdr]

function render_high_glow(prevsurf, hdr = false)
{
	var glowcolorsurf = render_surface_glow;
	var resultsurf = render_high_get_apply_surf(hdr);
	var baseradius = ((project_render_glow_radius * 10) * render_height / 500);
	var levelweight = clamp(0.5 + project_render_glow_radius, 0.5, 2.75);

	gpu_set_tex_repeat(false)
	var totalweight = render_blur_pyramid(glowcolorsurf, baseradius, levelweight, hdr);
	var glowstrength = project_render_glow_intensity / totalweight;

	// Apply Glow
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)

		render_shader_obj = shader_map[?shader_add]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_add_set(render_surface_blur[0], glowstrength, c_white, 1, baseradius > 0)
		}
		draw_surface_exists(prevsurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()

	// Add to lens
	if (render_camera_lens_dirt_glow)
	{
		if (hdr)
			render_surface_hdr_post[0] = surface_require(render_surface_hdr_post[0], render_width, render_height, false, e_surface_format.rgba16float)
		else
			render_surface[0] = surface_require(render_surface[0], render_width, render_height)
		prevsurf = hdr ? render_surface_hdr_post[0] : render_surface[0]

		surface_set_target(prevsurf)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface(render_surface_lens, 0, 0)
		}
		surface_reset_target()

		surface_set_target(render_surface_lens)
		{
			draw_clear_alpha(c_black, 1)
			render_shader_obj = shader_map[?shader_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_add_set(render_surface_blur[0], glowstrength, c_white, 1, baseradius > 0)
			}
			draw_surface_exists(prevsurf, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
	}

	gpu_set_tex_repeat(true)
	return resultsurf
}

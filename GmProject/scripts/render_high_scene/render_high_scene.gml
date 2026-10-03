/// @desc Applies lighting to the scene.

function render_high_scene()
{
	var resultsurf;
	
	gpu_set_blendmode_ext(bm_one, bm_zero)
	render_surface_hdr[1] = surface_require(render_surface_hdr[1], render_width, render_height, true, surface_rgba16float)
	resultsurf = render_surface_hdr[1] // Render directly to target?
	
	render_pass_capture(e_render_pass.SPECULAR, render_surface_specular)
	
	// Composite
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		// Apply lighting surfaces
		render_shader_obj = shader_map[?shader_high_lighting_apply]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_lighting_apply_set(render_surface_shadows, render_surface[0], render_surface_mask, render_surface_material)
		}
		draw_surface_exists(render_surface_diffuse, 0, 0)
		
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	// Add specular fallback to metallic surface in a composite copy used for reflections. (metallic is black in resultsurf due to no diffuse, but reflections need a color to hit)
	// re-use render_surface_shadows to save mem instead of a new hdr surf
	if (render_reflections)
	{
		render_surface_shadows = surface_require(render_surface_shadows, render_width, render_height, false, surface_rgba16float)
		surface_set_target(render_surface_shadows)
		{
			draw_clear_alpha(c_black, 0)

			render_shader_obj = shader_map[?shader_high_lighting_apply]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_lighting_apply_set(null, null, render_surface_mask, render_surface_material, true)
			}
			draw_surface_exists(resultsurf, 0, 0)

			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
	}
	gpu_set_blendmode(bm_normal)
	
	return resultsurf
}

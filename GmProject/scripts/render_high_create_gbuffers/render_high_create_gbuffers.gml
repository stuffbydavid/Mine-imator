/// @desc Creates render passes for use re-used data in more complex effects.

function render_high_create_gbuffers()
{
	var needglow, needsss, maskdepth, depthformat, fogdepth;
	needglow = (render_glow || render_pass = e_render_pass.ALL || render_pass = e_render_pass.GLOW)
	needsss = (render_auxiliary_material || render_pass = e_render_pass.ALL || render_pass = e_render_pass.SUBSURFACE || render_pass = e_render_pass.SUBSURFACE_RANGE)
	maskdepth = !render_mask_blend_is_supported()
	
	render_fog_combined = (renderer_current = e_renderer.STANDARD && render_auxiliary && !needglow && !needsss && !maskdepth)
	render_color_combined = (render_sun_combined && !render_glint && !needglow && !needsss && !maskdepth)
	if (render_color_combined)
		render_fog_combined = true
	fogdepth = (render_auxiliary && !render_fog_combined)

	// Recreate the mask when switching between combined rendering and the fallback
	if (is_cpp() && surface_exists(render_surface_mask) && surface_get_depth_enabled(render_surface_mask) != maskdepth)
	{
		surface_free(render_surface_mask)
		
		render_surface_mask = null
		render_gbuffers_cache_ready = false
	}
	
	if (is_cpp() && surface_exists(render_surface_fog) && surface_get_depth_enabled(render_surface_fog) != fogdepth)
	{
		surface_free(render_surface_fog)
		
		render_surface_fog = null
		render_gbuffers_cache_ready = false
	}
	
	// A cached glint buffer is only needed while glint is visible
	if (!render_glint && render_surface_specular_base != null)
	{
		surface_free(render_surface_specular_base)
		
		render_surface_specular_base = null
		render_gbuffers_cache_ready = false
	}
	
	if (render_gbuffers_cache_enabled && render_gbuffers_cache_ready)
	{
		if (!surface_exists(render_surface_diffuse) || !surface_exists(render_surface_mask) ||
			!surface_exists(render_surface_material) || !surface_exists(render_surface_depth) ||
			!surface_exists(render_surface_normal) || !surface_exists(render_surface_specular) || !surface_exists(render_surface_fog) ||
			(render_glint && !surface_exists(render_surface_specular_base)) ||
			surface_get_width(render_surface_diffuse) != render_width || surface_get_height(render_surface_diffuse) != render_height)
		{
			render_gbuffers_cache_ready = false
		}
		
		if (render_auxiliary && ((needsss && (!surface_exists(render_surface_sss) || !surface_exists(render_surface_sss_range))) ||
			(needglow && !surface_exists(render_surface_glow))))
		{
			render_gbuffers_cache_ready = false
		}
	}
	
	if (!render_gbuffers_cache_enabled)
		render_gbuffers_cache_ready = false
	
	// Determine depth format, place/build mode need a G component for object ID+face index
	if (is_cpp())
		depthformat = surface_rg32float
	else
		depthformat = (render_place ? surface_rgba32float : surface_r32float)
	
	if (render_surface_depth_format != depthformat)
	{
		if (surface_exists(render_surface_depth))
			surface_free(render_surface_depth)
		
		render_surface_depth = null
		render_surface_depth_format = depthformat
		render_gbuffers_cache_ready = false
	}

	render_surface_diffuse	= surface_require(render_surface_diffuse, render_width, render_height)
	render_surface_mask		= surface_require(render_surface_mask, render_width, render_height, maskdepth)
	render_surface_material = surface_require(render_surface_material, render_width, render_height, false)
	render_surface_depth	= surface_require(render_surface_depth, render_width, render_height, true, depthformat)
	render_surface_specular = surface_require(render_surface_specular, render_width, render_height, false, surface_rgba16float)
	render_surface_normal	= surface_require(render_surface_normal, render_width, render_height, false, surface_rgba16float)
	render_surface_fog = surface_require(render_surface_fog, render_width, render_height, fogdepth, surface_rgba16float)

	if (render_auxiliary || render_color_combined)
	{
		if (needsss)
		{
			render_surface_sss = surface_require(render_surface_sss, render_width, render_height, false, surface_r16float)
			render_surface_sss_range = surface_require(render_surface_sss_range, render_width, render_height, false)
		}
		
		if (needglow)
			render_surface_glow = surface_require(render_surface_glow, render_width, render_height, false)
	}

	if (!render_gbuffers_cache_ready)
	{
		render_high_clear_gbuffers()
		
		var combinedmask = false;
		if (render_color_combined)
			render_surface_shadows = surface_require(render_surface_shadows, render_width, render_height, false, surface_rgba16float)

		// Diffuse data
		surface_set_target(render_surface_diffuse)
		{
			gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha)

			// Background
			draw_clear_alpha(c_black, 0)
			render_world_background()

			// World
			render_world_start()
			render_world_sky()
			
			// Enable scene lighting mask rendering
			combinedmask = render_set_mask_blend(true, render_surface_mask, render_surface_fog)
			
			if (!combinedmask)
			{
				render_fog_combined = false
				render_color_combined = false

				surface_set_target_ext(1, render_surface_mask)
				surface_set_target_ext(2, render_surface_fog)
			}
			
			if (render_color_combined)
				render_color_combined = render_high_set_color_gbuffers(render_surface_depth, render_surface_normal, render_surface_material, render_surface_shadows, render_surface_specular)

			if (render_color_combined)
				render_place_begin(render_surface_depth)
			
			// Combined color writes depth to MRT 3
			render_place_output = (render_color_combined ? 3 : 0)
			render_world(e_render_mode.COLOR)

			if (render_color_combined)
				render_high_set_sun_blend(6, false)
			
			if (combinedmask)
				render_set_mask_blend(false, render_surface_mask)
			else
			{
				surface_reset_target()
				surface_set_target(render_surface_diffuse)
			}
			
			if (render_color_combined)
				render_place_end()
			
			if (app.place_build)
				render_world_build_box()
			
			render_world_done()

			if (render_background)
			{
				render_set_projection_ortho(0, 0, render_width, render_height, 0)
				gpu_set_colorwriteenable(false, false, false, true)
				gpu_set_blendmode_ext(bm_one, bm_zero)
				draw_box(0, 0, render_width, render_height, false, c_black, 1)
				gpu_set_colorwriteenable(true, true, true, true)
			}

			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		
		// Restore standalone fog depth if the combined target could not be attached
		if (render_auxiliary && !render_fog_combined && is_cpp() && !surface_get_depth_enabled(render_surface_fog))
		{
			surface_free(render_surface_fog)

			render_surface_fog = surface_require(null, render_width, render_height, true, surface_rgba16float)
		}

		// Separate scene lighting pass (GameMaker)
		if (!combinedmask)
		{
			surface_set_target(render_surface_mask)
			{
				draw_clear_alpha(c_black, 0)
				gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha)
				render_world_start()
				render_world(e_render_mode.SCENE_TEST)
				render_world_done()
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
		}

		if (!render_color_combined)
		{
			// G-buffers
			if (render_sun_combined)
			{
				if (render_glint)
				{
					render_surface_hdr[0] = surface_require(render_surface_hdr[0], render_width, render_height, true, surface_rgba16float)
					render_surface_hdr[1] = surface_require(render_surface_hdr[1], render_width, render_height, false, surface_rgba16float)
					surface_clear(render_surface_hdr[0], c_black)
					surface_clear(render_surface_hdr[1], c_black)
				}
				else
				{
					// Clear final sunlight targets before the combined pass
					render_surface_shadows = surface_require(render_surface_shadows, render_width, render_height, false, surface_rgba16float)
					surface_clear(render_surface_shadows, c_black)
				}
			}
		
			surface_set_target_ext(0, render_surface_depth)
			surface_set_target_ext(1, render_surface_normal)
			surface_set_target_ext(2, render_surface_material)
			if (render_glint)
				surface_set_target_ext(3, render_surface_specular)
			{
				var sunindex = (render_glint ? 4 : 3);
				gpu_set_blendmode_ext(bm_one, bm_zero)
			
				if (render_sun_combined)
				{
					surface_set_target_ext(sunindex, render_glint ? render_surface_hdr[0] : render_surface_shadows)
					surface_set_target_ext(sunindex + 1, render_glint ? render_surface_hdr[1] : render_surface_specular)
					render_high_set_sun_blend(sunindex, true)
				}
			
				render_world_start(depth_far)
				render_place_begin(render_surface_depth)
				render_world(e_render_mode.G_BUFFERS)
				render_world_done()
				render_place_end()
			
				if (render_sun_combined)
					render_high_set_sun_blend(sunindex, false)

				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
		}

		// Auxiliary buffers
		if (render_auxiliary && !render_fog_combined)
		{
			surface_clear(render_surface_fog, c_black, 0)
			surface_set_target_ext(0, render_surface_fog)
			if (!render_auxiliary_material)
			{
				if (render_glow)
					surface_set_target_ext(1, render_surface_glow)
			}
			else
			{
				surface_set_target_ext(1, render_surface_sss)
				surface_set_target_ext(2, render_surface_sss_range)
				if (render_glow)
					surface_set_target_ext(3, render_surface_glow)
			}
			{
				gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha)
				render_world_start()
				render_world(e_render_mode.AUXILIARY)
				render_world_done()
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()

			// Glow alpha fix
			if (render_glow)
			{
				surface_set_target(render_surface_glow)
				{
					render_set_projection_ortho(0, 0, render_width, render_height, 0)
					gpu_set_blendmode_ext(bm_src_color, bm_one)
					draw_box(0, 0, render_width, render_height, false, c_black, 1)
					gpu_set_blendmode(bm_normal)
				}
				surface_reset_target()
			}
		}
		else if (render_fog_combined)
		{
			// Keep the full camera projection previously restored by the auxiliary pass
			render_world_start()
			render_world_done()
		}
		if (render_gbuffers_cache_enabled)
		{
			if (render_glint)
			{
				render_surface_specular_base = surface_require(render_surface_specular_base, render_width, render_height, false, surface_rgba16float)
				surface_set_target(render_surface_specular_base)
				{
					gpu_set_blendmode_ext(bm_one, bm_zero)
					draw_surface(render_surface_specular, 0, 0)
					gpu_set_blendmode(bm_normal)
				}
				surface_reset_target()
			}
			
			render_gbuffers_cache_ready = true
		}
	}
	else
	{
		if (render_auxiliary)
			render_world_start()
		else
			render_world_start(depth_far)
		
		render_world_done()

		if (render_glint)
		{
			surface_set_target(render_surface_specular)
			{
				gpu_set_blendmode_ext(bm_one, bm_zero)
				draw_surface(render_surface_specular_base, 0, 0)
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
		}
		else
			surface_clear(render_surface_specular, c_black)
	}

	if (render_pass != e_render_pass.COMBINED)
	{
		render_pass_capture(e_render_pass.DIFFUSE, render_surface_diffuse)
		render_pass_capture(e_render_pass.MATERIAL, render_surface_material)
		render_pass_capture(e_render_pass.DEPTH, render_surface_depth)
		render_pass_capture(e_render_pass.NORMAL, render_surface_normal)
		render_pass_capture(e_render_pass.FOG, render_surface_fog)
		render_pass_capture(e_render_pass.MASK, render_surface_mask)
		render_pass_capture(e_render_pass.GLOW, render_surface_glow)
		render_pass_capture(e_render_pass.SUBSURFACE, render_surface_sss)
		render_pass_capture(e_render_pass.SUBSURFACE_RANGE, render_surface_sss_range)
		render_pass_capture(e_render_pass.EMISSIVE, render_surface_fog)
		render_pass_capture(e_render_pass.ROUGHNESS, render_surface_material)
		render_pass_capture(e_render_pass.METALLIC, render_surface_material)
		render_pass_capture(e_render_pass.FRESNEL, render_surface_material)
		render_pass_capture(e_render_pass.SSAO_MASK, render_surface_material)
	}
}

/// @desc Renders the scene in high quality.
/*
	COLOR pass:
	
		- render_surface_diffuse (rgba8unorm, MRT 0)
			RGBA: Diffuse data

		- render_surface_mask (rgba8unorm, MRT 1 in C++)
			R: Scene lighting mask, with independent alpha blending
			Separate SCENE_TEST pass in GM or when combined mask rendering is unavailable
		
		- render_surface_fog (r8unorm, MRT 2 when render_fog_combined)
			R: Fog strength, overwritten independently of diffuse blend modes
			Standard fog-only auxiliary work is combined here when independent MRT blending is available
			Glow, SSS and build mode retain the separate auxiliary pass
	
	shader_high_gbuffers:
	
		- render_surface_depth (r32float, MRT 0)
			R: Depth
	
		- render_surface_normal (rgba16float, MRT 1)
			RGB: Packed view-space normal
			A: Emissive
	
		- render_surface_material (rgba8unorm, MRT 2)
			R: Roughness
			G: Metallic
			B: Fresnel Term
			A: SSAO Mask
	
		- render_surface_specular (rgba16float, MRT 3 only when render_glint)
			RGB: Glint
			A: Unused
			Glint sampling and the fourth attachment are skipped when no visible glint is used
	
	shader_high_auxiliary / shader_high_auxiliary_standard (unless render_fog_combined):
	
		- render_surface_fog (r8unorm, MRT 0)
			R: Fog strength

		- render_surface_sss (r16float, MRT 1 when render_auxiliary_material)
			R: Subsurface Amount

		- render_surface_sss_range (rgba8unorm, MRT 2 when render_auxiliary_material)
			RGB: Subsurface RGB radius
			A: Unused

		- render_surface_glow (rgba8unorm, optional MRT 1 in Standard or MRT 3 with SSS)
			RGBA: Glow color
	
	C++ depth attachments are retained on diffuse/depth and on mask/fog only for their standalone passes
	Normal, material, specular, SSS, SSS range and glow do not need separate depth attachments
	Auxiliary SSS/glow surfaces are only required when needed by rendering or pass capture
	When G-buffer caching is enabled, render_surface_specular_base stores glint only while render_glint is true
	Specular remains allocated for additive lighting/reflections, restored from cached glint or cleared before each cached sample
*/

function render_high()
{
	render_alpha_hash = (render_alpha_hash_allowed && project_render_alpha_mode)
	
	if (!render_use_samples && renderer_current = e_renderer.REALISTIC)
	{
		ds_map_clear(render_shadow_cache_ready)
		render_gbuffers_cache_ready = false
	}
	
	var samplestart, sampleend, finalsurf;
	if (!render_use_samples)
	{
		render_update_pcss_kernel()
		
		samplestart = 0
		sampleend = 1
	}
	else
	{
		render_update_samples()
		
		if (render_samples_done)
		{
			samplestart = 0
			sampleend = 0
		}
		else
		{
			samplestart = render_samples - 1
			sampleend = render_samples
		}
	}
	
	// Render
	for (var s = samplestart; s < sampleend; s++)
	{
		render_sample_current = s
		random_set_seed(render_sample_current)
		
		// Update random jitter
		render_high_update_jitter()
		
		// Create render passes
		render_high_create_gbuffers()
		
		// Shadows
		if (render_shadows)
			render_high_shadows()
		
		// Indirect lighting
		if (render_indirect)
			render_high_indirect()
		
		// SSAO
		if (render_ssao)
			render_high_ssao()
		
		// Composite current effects, avoid render surf 0 going forward
		finalsurf = render_high_scene()
		
		// Reflections
		if (render_reflections)
			render_high_reflections(finalsurf)
		
		// Fog
		if (env_fog_show && renderer_current != e_renderer.STANDARD)
			render_high_fog(finalsurf)

		// Apply HDR effects before tonemapping (DoF, Bloom, Glow, Lens Dirt)
		render_refresh_effects(true, true, true)
		finalsurf = render_post(finalsurf, true, true, true)
		finalsurf = render_high_tonemap(finalsurf)

		// Finish the combined tile before assembling the all-passes grid
		if (render_pass = e_render_pass.ALL)
		{
			render_refresh_effects(false, true)
			finalsurf = render_post(finalsurf, false, true)
		}
		
		// Store debug passes and samples before final post processing
		if (render_pass || render_use_samples)
		{
			render_target = surface_require(render_target, render_width, render_height)
			surface_set_target(render_target)
			{
				if (render_pass = e_render_pass.ALL)
				{
					draw_clear_alpha(c_black, 1)
					render_pass_grid_draw(finalsurf)
				}
				else if (render_pass)
				{
					draw_clear_alpha(c_black, 1)
					render_pass_draw(render_pass, render_pass_surf, 0, 0, render_width, render_height)
				}
				else
				{
					draw_clear_alpha(c_black, 0)
					gpu_set_blendmode_ext(bm_one, bm_zero)
					draw_surface_exists(finalsurf, 0, 0)
					gpu_set_blendmode(bm_normal)
				}
			}
			surface_reset_target()
		}
		
		if (render_use_samples)
			render_high_samples_add()
	}
	
	if (render_use_samples)
	{
		render_high_samples_unpack()
		finalsurf = render_target
	}
	
	// Apply basic post-process effects
	if (!render_pass)
	{
		render_refresh_effects(false, true)
		finalsurf = render_post(finalsurf, false, true)
		
		if (app.project_render_aa && app.project_render_aa_mode = e_aa_mode.FXAA)
			finalsurf = render_high_aa(finalsurf)
		
		render_target = surface_require(render_target, render_width, render_height)
		if (finalsurf != render_target)
		{
			gpu_set_blendmode_ext(bm_one, bm_zero)
			surface_set_target(render_target)
			{
				draw_clear_alpha(c_black, 0)
				draw_surface_exists(finalsurf, 0, 0)
			}
			surface_reset_target()
			gpu_set_blendmode(bm_normal)
		}
	}
	
	// Reset progressive AA matrix
	aa_matrix = MAT_IDENTITY
	
	if (render_use_samples)
		render_samples_clear = false
	
	render_alpha_hash = false
}

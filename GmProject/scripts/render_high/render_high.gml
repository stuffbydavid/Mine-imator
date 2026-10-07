/// @desc Renders the scene in high quality (Standard/Realistic).
/*
	Preparing the scene (render_high_create_gbuffers):
		COLOR draws object colors and records which objects receive lighting
		G_BUFFERS records distance, surface direction, material properties and optional glint
		AUXILIARY records fog, glow and light passing through materials when needed
		
		C++ records the lighting mask alongside COLOR, while GameMaker uses SCENE_TEST separately
	
	Buffer contents:
		render_surface_diffuse (rgba8unorm):
			RGB object colors before lighting
			A opacity
		
		render_surface_mask (rgba8unorm):
			R lighting mask
			A object opacity used for blending
		
		render_surface_fog (r8unorm):
			R fog strength, from clear to fully fogged
		
		render_surface_depth (r32float):
			R camera depth
			G/B zero
			A one when writing a full RGBA target
		
		render_surface_normal (rgba16float):
			RGB packed surface direction relative to the camera
			A emissive strength
		
		render_surface_material (rgba8unorm):
			R roughness
			G metallic
			B angle-dependent reflectivity
			A ambient occlusion mask
		
		render_surface_specular (rgba16float):
			RGB glint and lighting highlights
			A used when blending lighting
		
		render_surface_shadows (rgba16float):
			RGB light reaching the surface
			A used when blending lighting
		
		render_surface_hdr[0/1] (rgba16float):
			RGB temporary lighting color/highlights
			A object opacity used for blending
		
	These temporary images are reused later for indirect lighting and the lit scene
		render_surface_sss (r16float):
			R amount of light passing through the material
		
		render_surface_sss_range (rgba8unorm):
			RGB light transmission radius per color channel
			A unused
		
		render_surface_glow (rgba8unorm):
			RGB glow color
			A opacity
		
		render_surface_specular_base (rgba16float):
			RGB cached glint
			A unused
		
		render_surface_sun_buffer[]:
			R sun shadow depth per cascade, repeated in G/B/A on full RGBA targets in GameMaker
			C++ reads native depth instead of these color channels
		
		render_surface_samples (rgba32float in C++, rgba16float in GameMaker):
			RGBA accumulated sample colors and opacity
		
		render_target (rgba8unorm):
			RGBA finished image colors and opacity, or the selected debug image
		
		Diffuse and scene depth keep depth storage for deciding which object is in front
		Mask and fog need their own depth storage only when drawn separately
		Glow and light transmission images are only created when needed by rendering or debug output
	
	Combined layouts:
		- COLOR writes diffuse, mask and optional fog
		- G_BUFFERS writes depth, normal, material and optional glint
		- Combined sunlight adds lighting color and highlights to G_BUFFERS
		- With glint these go to temporary images, otherwise directly to shadows/specular
		- The full COLOR combination writes diffuse, mask, fog, depth, normal, material, shadows and specular together
		- AUXILIARY writes fog plus optional light transmission and glow
	
	Standard optimizations (C++ only):
		- render_fog_combined records fog alongside COLOR when no separate glow or light transmission data is needed
			This skips AUXILIARY without changing the object's color blending
		- render_sun_combined prepares sun shadows first, then calculates sunlight alongside G_BUFFERS
			This skips the separate HIGH_LIGHT_SUN draw
		- render_color_combined also records G_BUFFERS and sunlight alongside COLOR
			This skips G_BUFFERS as well, but needs the sunlight shortcut and no glint, glow or light transmission data
		- The fog and sunlight optimizations can still work independently when the full combination is unavailable
		- Build mode, graphics support, camera range, caching and debug output can require separate draws
	
	Realistic optimizations:
		- Alpha hashing builds transparency across samples by keeping or discarding pixels instead of partially blending them
			Transparent shadows also use hashing, so their shadow maps must be redrawn for each sample
		- render_shadow_cache_enabled reuses sun cascades and point/spot shadow maps when transparent and jittered shadows are off
			Soft shadow filtering can still vary between samples without rebuilding cached shadow maps
		- render_gbuffers_cache_enabled reuses scene colors, depth, materials and auxiliary data when AA is off or uses FXAA
			This scene cache also requires transparent shadows to be off and no hashed alpha to be requested
			Cached glint is restored before adding each sample's lighting, rather than accumulating lighting into the cached image
		- Cache readiness is cleared when sampling restarts, including camera, output size or shadow quality changes
	
	Lighting and effects:
		- Sun shadows draw the scene from the sun, with one draw per cascade
		- Point and spot lights keep their own lighting draws and any required shadow maps
		- Without glint, combined sunlight goes straight into the final lighting images
		- Glint and local lights use temporary lighting images before adding their results
		- Indirect lighting and ambient occlusion are calculated when enabled
		- render_high_scene combines object colors and lighting, then reflections and fog are applied as needed
		 -Standard includes fog in the lighting result, while Realistic applies fog separately
		- Camera effects such as depth of field and bloom are applied before adjusting brightness and colors
	
	Finishing the image:
		- Realistic adds each sample to the accumulated image, reusing cached scene data when safe
		- Debug output can save individual rendering stages instead of the finished image
		- The remaining camera effects and final edge smoothing are applied after samples are combined
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
		render_sun_combined = (
			is_cpp() && renderer_current = e_renderer.STANDARD && render_shadows &&
			env_sunlight_color_final != c_black && !app.place_build && render_mask_blend_supported() &&
			cam_far_prev <= cam_near + depth_far && !render_gbuffers_cache_enabled)
		
		if (render_sun_combined)
		{
			render_shadow_cache_update([], true)
			render_high_shadows_sun()
		}
		
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

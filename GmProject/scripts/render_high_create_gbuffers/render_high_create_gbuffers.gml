/// render_high_create_gbuffers()
/// @arg Creates render passes for use re-used data in more complex effects.

/*
	G-Buffers docs:
	
	render_surface_diffuse
		- RGBA: Diffuse data
	
	render_surface_depth (r32float)
		- R: Depth
	
	render_surface_normal (rgba32float)
		- RGB: View-space normal
		- A: Emissive
	
	render_surface_material
		- R: Roughness
		- G: Metallic
		- B: Fresnel Term
		- A: Unused
	
	render_surface_specular
		- RGB: Glint
		- A: Unused
	
	Specular is an additive effect, used for glint/specular/reflections.
*/

function render_high_create_gbuffers()
{
	render_surface_diffuse = surface_require(render_surface_diffuse, render_width, render_height)
	render_surface_material = surface_require(render_surface_material, render_width, render_height)
	render_surface_depth = surface_require(render_surface_depth, render_width, render_height, true, e_surface_format.r32float)
	render_surface_specular = surface_require(render_surface_specular, render_width, render_height, false, e_surface_format.rgba32float)
	render_surface_normal = surface_require(render_surface_normal, render_width, render_height, true, e_surface_format.rgba32float)
	
	render_high_clear_gbuffers()
	
	// Diffuse data
	surface_set_target(render_surface_diffuse)
	{
		// Background
		draw_clear_alpha(c_black, 0)
		render_world_background()
		
		// World
		render_world_start()
		render_world_sky()
		render_world(e_render_mode.COLOR)
		render_world_done()
		
		// 2D mode
		render_set_projection_ortho(0, 0, render_width, render_height, 0)
		
		// Alpha fix
		gpu_set_blendmode_ext(bm_src_color, bm_one) 
		if (render_background)
			draw_box(0, 0, render_width, render_height, false, c_black, 1)
		else
		{
			render_world_start()
			render_world(e_render_mode.ALPHA_FIX)
			render_world_done()
		}
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	// G-buffers
	surface_set_target_ext(0, render_surface_depth)
	surface_set_target_ext(1, render_surface_normal)
	surface_set_target_ext(2, render_surface_material)
	surface_set_target_ext(3, render_surface_specular)
	{
		gpu_set_blendmode_ext(bm_one, bm_zero)
		render_world_start(depth_far)
		render_world(e_render_mode.G_BUFFERS)
		render_world_done()
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	// Noise
	render_sample_noise_texture = render_get_noise_texture(render_sample_current)
	
	if (render_pass = e_render_pass.DIFFUSE)
		render_pass_surf = surface_duplicate(render_surface_diffuse)
	
	if (render_pass = e_render_pass.MATERIAL)
		render_pass_surf = surface_duplicate(render_surface_material)
	
	if (render_pass = e_render_pass.DEPTH)
		render_pass_surf = surface_duplicate(render_surface_depth)
	
	if (render_pass = e_render_pass.NORMAL)
		render_pass_surf = surface_duplicate(render_surface_normal)
}

/// shader_high_light_point_set()

function shader_high_light_point_set()
{
	render_set_uniform_int("uIsSky", 0)
	render_set_uniform_int("uIsWater", 0)
	
	render_set_uniform_vec3("uLightPosition", render_light_from[X], render_light_from[Y], render_light_from[Z])
	render_set_uniform_color("uLightColor", render_light_color, 1)
	render_set_uniform("uLightStrength", render_light_strength)
	render_set_uniform("uLightNear", render_light_near)
	render_set_uniform("uLightFar", render_light_far)
	render_set_uniform("uLightFadeSize", render_light_fade_size)
	render_set_uniform_int("uLightRealisticFalloff", render_light_realistic_falloff)
	render_set_uniform_vec3("uShadowPosition", render_shadow_from[X], render_shadow_from[Y], render_shadow_from[Z])
	render_set_uniform("uLightSpecular", render_light_specular_strength)
	render_set_uniform("uLightSize", render_light_size)
	render_set_uniform("uShadowRadius", render_light_size * .5 * app.project_render_shadows_blur_size)
	render_set_uniform_int("uShadowBlurQuality", app.project_render_shadows_jittered ? 0 : app.project_render_shadows_blur_quality)
	render_set_uniform("uPCSSKernel", render_pcss_kernel_rotated)
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	render_set_uniform("uGamma", render_gamma)
	
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_point_atlas_buffer))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], true)
	gpu_set_texrepeat_ext(sampler_map[?"uDepthBuffer"], false)
	render_set_uniform("uDepthBufferSize", app.project_render_shadows_point_buffer_size)
}

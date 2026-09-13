/// shader_high_light_spot_set()

function shader_high_light_spot_set()
{
	render_set_uniform("uEmissive", 0)
	
	render_set_uniform_int("uIsSky", 0)
	render_set_uniform_int("uIsWater", 0)
	
	render_set_uniform("uLightMatrix", render_spot_matrix)
	render_set_uniform("uShadowMatrix", render_shadow_matrix)
	render_set_uniform_vec3("uLightPosition", render_light_from[X], render_light_from[Y], render_light_from[Z])
	render_set_uniform_color("uLightColor", render_light_color, 1)
	render_set_uniform("uLightStrength", render_light_strength)
	render_set_uniform("uLightSpecular", render_light_specular_strength)
	var shadowscale = 1 / max(2 * tan((render_light_fov / 57.2958) * .5), .0001)
	render_set_uniform("uShadowRadius", render_light_size * .5 * app.project_render_shadows_blur_size * shadowscale)
	render_set_uniform_int("uShadowBlurQuality", app.project_render_shadows_jittered ? 0 : app.project_render_shadows_blur_quality)
	render_set_uniform("uPCSSKernel", render_pcss_kernel_rotated)
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	render_set_uniform("uGamma", render_gamma)
	
	render_set_uniform("uLightNear", render_light_near)
	render_set_uniform("uLightFar", render_light_far)
	render_set_uniform("uLightFadeSize", render_light_fade_size)
	render_set_uniform("uLightSpotSharpness", render_light_spot_sharpness)
	
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_spot_buffer))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], true)
}

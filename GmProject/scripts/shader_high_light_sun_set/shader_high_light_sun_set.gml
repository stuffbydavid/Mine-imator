/// shader_high_light_sun_set()

function shader_high_light_sun_set()
{
	render_set_uniform("uEmissive", 0)
	
	render_set_uniform_int("uIsGround", 0)
	render_set_uniform_int("uIsSky", 0)
	render_set_uniform_int("uIsWater", 0)
	
	var cascade1 = render_cascades[render_cascades_count > 1 ? 1 : 0]
	var cascade2 = render_cascades[render_cascades_count > 2 ? 2 : render_cascades_count - 1]
	render_set_uniform_mat4_array("uLightMatBiasMVP", array(render_cascades[0].matBias, cascade1.matBias, cascade2.matBias))
	
	render_set_uniform("uSunNear", [render_cascades[0].near, cascade1.near, cascade2.near])
	render_set_uniform("uSunFar", [render_cascades[0].far, cascade1.far, cascade2.far])
	render_set_uniform("uCascadeWorldSize", [render_cascades[0].worldSize, cascade1.worldSize, cascade2.worldSize])
	render_set_uniform_color("uLightColor", render_light_color, 1)
	render_set_uniform("uLightStrength", render_light_strength)
	render_set_uniform("uLightSpecular", render_light_specular_strength)
	render_set_uniform("uGamma", render_gamma)
	render_set_uniform_int("uShadowBlurQuality", app.project_render_shadows_jittered ? 0 : app.project_render_shadows_blur_quality)
	render_set_uniform("uPCSSKernel", render_pcss_kernel_rotated)
	render_set_uniform("uSunShadowScale", render_sun_shadow_scale)
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	
	render_set_uniform_vec3("uLightDirection", render_sun_direction[X], render_sun_direction[Y], render_sun_direction[Z])
	
	texture_set_stage(sampler_map[?"uDepthBuffer0"], surface_get_texture(render_surface_sun_buffer[0]))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer0"], true)
	
	texture_set_stage(sampler_map[?"uDepthBuffer1"], surface_get_texture(render_surface_sun_buffer[render_cascades_count > 1 ? 1 : 0]))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer1"], true)
	
	texture_set_stage(sampler_map[?"uDepthBuffer2"], surface_get_texture(render_surface_sun_buffer[render_cascades_count > 2 ? 2 : render_cascades_count - 1]))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer2"], true)
	
	render_set_uniform("uCascadeEndClipSpace", [render_cascades[0].clipEndDepth, cascade1.clipEndDepth, cascade2.clipEndDepth])
	render_set_uniform_int("uCascadeCount", render_cascades_count)
}

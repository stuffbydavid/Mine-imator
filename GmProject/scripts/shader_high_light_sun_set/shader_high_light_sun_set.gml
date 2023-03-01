/// shader_high_light_sun_set()

function shader_high_light_sun_set()
{
	render_set_uniform("uEmissive", 0)
	
	render_set_uniform_int("uIsGround", 0)
	render_set_uniform_int("uIsSky", 0)
	render_set_uniform_int("uIsWater", 0)
	
	render_set_uniform_mat4_array("uLightMatBiasMVP", array(render_cascades[0].matBias, render_cascades[1].matBias, render_cascades[2].matBias))
	
	render_set_uniform("uSunNear", [render_cascades[0].near, render_cascades[1].near, render_cascades[2].near])
	render_set_uniform("uSunFar", [render_cascades[0].far, render_cascades[1].far, render_cascades[2].far])
	render_set_uniform_color("uLightColor", render_light_color, 1)
	render_set_uniform("uLightStrength", render_light_strength)
	render_set_uniform("uLightSpecular", render_light_specular_strength)
	
	render_set_uniform_vec3("uLightDirection", render_sun_direction[X], render_sun_direction[Y], render_sun_direction[Z])
	
	texture_set_stage(sampler_map[?"uDepthBuffer0"], surface_get_texture(render_surface_sun_buffer[0]))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer0"], true)
	
	texture_set_stage(sampler_map[?"uDepthBuffer1"], surface_get_texture(render_surface_sun_buffer[1]))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer1"], true)
	
	texture_set_stage(sampler_map[?"uDepthBuffer2"], surface_get_texture(render_surface_sun_buffer[2]))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer2"], true)
	
	render_set_uniform("uCascadeEndClipSpace", [render_cascades[0].clipEndDepth, render_cascades[1].clipEndDepth, render_cascades[2].clipEndDepth])
}

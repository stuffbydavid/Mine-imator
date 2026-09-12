/// new_shader(name)
/// @arg name

function new_shader(name)
{
	with (new_obj(obj_shader))
	{
		id.name = name
		shader = asset_get_index(name)
		script = asset_get_index(name + "_set")
		uniform_map = ds_map_create()
		sampler_map = ds_map_create()
		
		// Set common uniforms
		new_shader_sampler("uTexture")
		new_shader_uniform("uTextureSize")
		new_shader_uniform("uTextureOffset")
		new_shader_uniform("uBlendColor")
		
		// Wind
		new_shader_uniform("uTime")
		new_shader_uniform("uWindEnable")
		new_shader_uniform("uWindTerrain")
		new_shader_uniform("uWindSpeed")
		new_shader_uniform("uWindStrength")
		new_shader_uniform("uWindDirection")
		new_shader_uniform("uWindDirectionalSpeed")
		new_shader_uniform("uWindDirectionalStrength")
		
		// Fog
		new_shader_uniform("uFogShow")
		new_shader_uniform("uFogColor")
		new_shader_uniform("uFogDistance")
		new_shader_uniform("uFogSize")
		new_shader_uniform("uFogHeight")
		
		new_shader_uniform("uCameraPosition")
		
		// Rendering effects
		new_shader_uniform("uTAAMatrix")
		new_shader_uniform("uSampleIndex")
		new_shader_uniform("uAlphaHash")
		
		shader_map[?shader] = id
		return id
	}
}

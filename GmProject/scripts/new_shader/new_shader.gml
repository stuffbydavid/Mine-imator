function new_shader(name)
{
	with (new_obj(obj_shader))
	{
		self.name = name
		shader = asset_get_index(name)
		script = asset_get_index(name + "_set")
		uniform_handle = array_create(e_uniform.amount, -1)
		uniform_used = array_create(e_uniform.amount, false)
		sampler_map = ds_map_create()
		sampler_name_list = ds_list_create()
		sampler_texture = array_create(e_texture_channel.amount, -1)
		
		// Set common uniforms
		sampler_texture[e_texture_channel.DIFFUSE] = new_shader_sampler("uTexture")
		new_shader_uniform(e_uniform.TEXTURE_SIZE)
		new_shader_uniform(e_uniform.TEXTURE_OFFSET)
		new_shader_uniform(e_uniform.BLEND_COLOR)
		
		// Wind
		new_shader_uniform(e_uniform.TIME)
		new_shader_uniform(e_uniform.WIND_ENABLE)
		new_shader_uniform(e_uniform.WIND_TERRAIN)
		new_shader_uniform(e_uniform.WIND_SPEED)
		new_shader_uniform(e_uniform.WIND_STRENGTH)
		new_shader_uniform(e_uniform.WIND_DIRECTION)
		new_shader_uniform(e_uniform.WIND_DIRECTIONAL_SPEED)
		new_shader_uniform(e_uniform.WIND_DIRECTIONAL_STRENGTH)
		
		// Fog
		new_shader_uniform(e_uniform.FOG_SHOW)
		new_shader_uniform(e_uniform.FOG_COLOR)
		new_shader_uniform(e_uniform.FOG_DISTANCE)
		new_shader_uniform(e_uniform.FOG_SIZE)
		new_shader_uniform(e_uniform.FOG_HEIGHT)
		
		new_shader_uniform(e_uniform.CAMERA_POSITION)
		
		// Rendering effects
		new_shader_uniform(e_uniform.AA_MATRIX)
		new_shader_uniform(e_uniform.TAA_MATRIX)
		new_shader_uniform(e_uniform.SAMPLE_INDEX)
		new_shader_uniform(e_uniform.ALPHA_HASH)
		
		// Build mode
		new_shader_uniform(e_uniform.VIEWPORT_SIZE)
		new_shader_uniform(e_uniform.LINE_LENGTH)
		
		shader_map[?shader] = id
		return id
	}
}

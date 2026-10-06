/// @desc Adds timeline material uniforms.

function shader_material_uniforms()
{
	// Color
	shader_color_uniforms()

	// Render setting
	new_shader_uniform(e_uniform.DEFAULT_EMISSIVE)
	new_shader_uniform(e_uniform.DEFAULT_SUBSURFACE)
	
	// Material textures
	sampler_texture[e_texture_channel.MATERIAL] = new_shader_sampler(e_sampler.TEXTURE_MATERIAL)
	sampler_texture[e_texture_channel.NORMAL] = new_shader_sampler(e_sampler.TEXTURE_NORMAL)
	new_shader_uniform(e_uniform.MATERIAL_FORMAT)
	
	// Surface
	new_shader_uniform(e_uniform.ROUGHNESS)
	new_shader_uniform(e_uniform.METALLIC)
	new_shader_uniform(e_uniform.EMISSIVE)
	
	// Subsurface
	new_shader_uniform(e_uniform.SSS)
	new_shader_uniform(e_uniform.SSS_RADIUS)
	new_shader_uniform(e_uniform.SSS_COLOR)
	new_shader_uniform(e_uniform.SSS_BACKLIGHT_SPREAD)
	new_shader_uniform(e_uniform.SSS_BACKLIGHT_STRENGTH)
	new_shader_uniform(e_uniform.SSS_BRIGHT_BACKLIGHT)
	
	// Other
	new_shader_uniform(e_uniform.IS_WATER)
	new_shader_uniform(e_uniform.WATER_MATERIAL_TIME)
	new_shader_uniform(e_uniform.WATER_MATERIAL_STRENGTH)
	new_shader_uniform(e_uniform.WATER_MATERIAL_SCALE)
	new_shader_uniform(e_uniform.WATER_MATERIAL_OCTAVES)
	new_shader_uniform(e_uniform.HAS_NORMAL_MAP)
}

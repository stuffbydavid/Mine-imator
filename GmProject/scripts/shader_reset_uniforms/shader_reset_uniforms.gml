/// shader_reset_uniforms()
/// @desc Uniforms to help prevent uniform updating in render_world_tl()

function shader_reset_uniforms()
{
	shader_uniform_color_ext = null
	shader_uniform_rgb_add = null
	shader_uniform_rgb_sub = null
	shader_uniform_hsb_add = null
	shader_uniform_hsb_sub = null
	shader_uniform_hsb_mul = null
	shader_uniform_mix_color = null
	shader_uniform_mix_percent = null
	shader_uniform_emissive = null
	shader_uniform_metallic = null
	shader_uniform_roughness = null
	shader_uniform_wind = null
	shader_uniform_wind_terrain = null
	shader_uniform_fog = null
	shader_uniform_sss = null
	shader_uniform_sss_red = null
	shader_uniform_sss_green = null
	shader_uniform_sss_blue = null
	shader_uniform_sss_color = null
	shader_uniform_wind_strength = null
	shader_uniform_glow = null
	shader_uniform_glow_texture = null
	shader_uniform_glow_color = null
}
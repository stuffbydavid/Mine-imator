function shader_high_light_point_shadowless_set()
{
	render_set_uniform_int(e_uniform.IS_SKY, 0)
	render_set_uniform_int(e_uniform.LIGHT_AMOUNT, render_shadowless_point_amount)
	render_set_uniform(e_uniform.LIGHT_DATA, render_shadowless_point_data)
	render_set_uniform(e_uniform.EMISSIVE, 0)
	
	render_light_specular_strength = 1
	render_set_uniform(e_uniform.LIGHT_SPECULAR, render_light_specular_strength)
	render_set_uniform(e_uniform.GAMMA, render_gamma)
}

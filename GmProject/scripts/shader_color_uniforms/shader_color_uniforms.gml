/// @desc Adds timeline color uniforms.

function shader_color_uniforms()
{
	new_shader_uniform(e_uniform.COLORS_EXT)
	new_shader_uniform(e_uniform.RGB_ADD)
	new_shader_uniform(e_uniform.RGB_SUB)
	new_shader_uniform(e_uniform.HSB_ADD)
	new_shader_uniform(e_uniform.HSB_SUB)
	new_shader_uniform(e_uniform.HSB_MUL)
	new_shader_uniform(e_uniform.MIX_COLOR)
}

/// shader_color_uniforms()
/// @desc Adds timeline color uniforms

function shader_color_uniforms()
{
	new_shader_uniform("uColorsExt")
	new_shader_uniform("uRGBAdd")
	new_shader_uniform("uRGBSub")
	new_shader_uniform("uHSBAdd")
	new_shader_uniform("uHSBSub")
	new_shader_uniform("uHSBMul")
	new_shader_uniform("uMixColor")
}

/// render_color_camera_set()

function shader_color_camera_set()
{
	// Color
	render_set_uniform("uEmissive", render_camera.value[e_value.EMISSIVE])
	render_set_uniform_color("uBlendColor", render_camera.value[e_value.RGB_MUL], render_camera.value[e_value.ALPHA])
	render_set_uniform_color("uRGBAdd", render_camera.value[e_value.RGB_ADD], 1)
	render_set_uniform_color("uRGBSub", render_camera.value[e_value.RGB_SUB], 1)
	render_set_uniform_color("uHSBAdd", render_camera.value[e_value.HSB_ADD], 1)
	render_set_uniform_color("uHSBSub", render_camera.value[e_value.HSB_SUB], 1)
	render_set_uniform_color("uHSBMul", render_camera.value[e_value.HSB_MUL], 1)
	render_set_uniform_color("uMixColor", render_camera.value[e_value.MIX_COLOR], render_camera.value[e_value.MIX_PERCENT])
}

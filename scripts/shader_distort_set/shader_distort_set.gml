/// shader_distort_set()

function shader_distort_set()
{
	render_set_uniform("uDistortAmount", render_camera.value[e_value.CAM_DISTORT_AMOUNT])
	render_set_uniform_int("uRepeatImage", render_camera.value[e_value.CAM_DISTORT_REPEAT])
}

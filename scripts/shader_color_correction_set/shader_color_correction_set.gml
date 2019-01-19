/// shader_color_correction_set()

render_set_uniform("uContrast", render_camera.value[e_value.CAM_CONTRAST] + 1)
render_set_uniform("uBrightness", render_camera.value[e_value.CAM_BRIGHTNESS])
render_set_uniform("uSaturation", render_camera.value[e_value.CAM_SATURATION])
render_set_uniform_color("uColorBurn", render_camera.value[e_value.CAM_COLOR_BURN], 1)
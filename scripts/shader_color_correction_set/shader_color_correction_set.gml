/// shader_color_correction_set()

render_set_uniform("uContrast", 1 + render_camera.value[e_value.CAM_CONTRAST])
render_set_uniform("uBrightness", render_camera.value[e_value.CAM_BRIGHTNESS])
render_set_uniform("uSaturation", render_camera.value[e_value.CAM_SATURATION])
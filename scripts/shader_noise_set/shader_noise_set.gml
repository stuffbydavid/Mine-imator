/// shader_grain_set()

render_set_uniform_vec2("uScreenSize", render_width, render_height)

render_set_uniform("uStrength", render_camera.value[e_value.CAM_GRAIN_STRENGTH])
render_set_uniform("uSaturation", render_camera.value[e_value.CAM_GRAIN_SATURATION])
render_set_uniform("uSize", render_camera.value[e_value.CAM_GRAIN_SIZE])

/// shader_vignette_set()

render_set_uniform_vec2("uScreenSize", render_width, render_height)

render_set_uniform("uRadius", render_camera.value[e_value.CAM_VIGNETTE_RADIUS])
render_set_uniform("uSoftness", render_camera.value[e_value.CAM_VIGNETTE_SOFTNESS])
render_set_uniform("uStrength", render_camera.value[e_value.CAM_VIGNETTE_STRENGTH])

render_set_uniform_color("uColor", render_camera.value[e_value.CAM_VIGNETTE_COLOR], 1)
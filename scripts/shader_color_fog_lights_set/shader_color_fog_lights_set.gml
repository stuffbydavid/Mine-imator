/// shader_color_fog_lights_set()

render_set_uniform_int("uIsGround", 0)
render_set_uniform_int("uIsSky", 0)

// Colors
render_set_uniform_int("uColorsExt", 0)

// Lights
render_set_uniform_int("uLightAmount", app.background_light_amount)
render_set_uniform("uLightData", app.background_light_data)
render_set_uniform_color("uAmbientColor", app.background_ambient_color_final, 1)
render_set_uniform("uBrightness", 0)
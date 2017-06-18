/// shader_high_light_apply_set()

var uAmbientColor = shader_get_uniform(shader_high_light_apply, "uAmbientColor");

shader_set(shader_high_light_apply)

shader_set_uniform_color(uAmbientColor, background_ambient_color_final, 1)

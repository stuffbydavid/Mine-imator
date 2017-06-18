/// shader_high_aa_set()

var uScreenSize = shader_get_uniform(shader_high_aa, "uScreenSize"), 
    uPower = shader_get_uniform(shader_high_aa, "uPower");

shader_set(shader_high_aa)

shader_set_uniform_f(uScreenSize, render_width, render_height)
shader_set_uniform_f(uPower, setting_render_aa_power)

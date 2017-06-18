/// shader_set_fog(shader)
/// @arg shader

var shader, fog;
shader = argument0
fog = (render_lights && shader_fog && app.background_fog_show)

var uFogShow = shader_get_uniform(shader, "uFogShow"), 
    uFogColor = shader_get_uniform(shader, "uFogColor"), 
    uFogDistance = shader_get_uniform(shader, "uFogDistance"), 
    uFogSize = shader_get_uniform(shader, "uFogSize"), 
    uFogHeight = shader_get_uniform(shader, "uFogHeight")

shader_set_uniform_f(uFogShow, bool_to_float(fog))

if (fog)
{
    shader_set_uniform_color(uFogColor, app.background_fog_color_final, 1)
    shader_set_uniform_f(uFogDistance, app.background_fog_distance)
    shader_set_uniform_f(uFogSize, app.background_fog_size)
    shader_set_uniform_f(uFogHeight, app.background_fog_height)
}

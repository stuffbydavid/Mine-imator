/// shader_set_wind(shader)
/// @arg shader

var shader = argument0;
var uTime = shader_get_uniform(shader, "uTime"), 
    uWindEnabled = shader_get_uniform(shader, "uWindEnabled"), 
    uWindTerrain = shader_get_uniform(shader, "uWindTerrain"), 
    uWindSpeed = shader_get_uniform(shader, "uWindSpeed"), 
    uWindStrength = shader_get_uniform(shader, "uWindStrength");

shader_set_uniform_f(uTime, current_step)
shader_set_uniform_f(uWindEnabled, bool_to_float(shader_wind))
shader_set_uniform_f(uWindTerrain, bool_to_float(shader_wind_terrain))
shader_set_uniform_f(uWindSpeed, app.background_wind * app.background_wind_speed)
shader_set_uniform_f(uWindStrength, app.background_wind_strength)

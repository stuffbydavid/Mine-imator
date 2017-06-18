/// shader_high_fog_apply_set(fogsurface)
/// @arg fogsurface

var fogBuffer = shader_get_sampler_index(shader_high_fog_apply, "fogBuffer"), 
    fogColor = shader_get_uniform(shader_high_fog_apply, "fogColor");

shader_set(shader_high_fog_apply)

texture_set_stage(fogBuffer, surface_get_texture(argument0))

shader_set_uniform_color(fogColor, background_fog_color_final, 1)

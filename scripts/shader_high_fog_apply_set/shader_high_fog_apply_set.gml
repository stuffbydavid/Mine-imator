/// shader_high_fog_apply_set(fogbuffer)
/// @arg fogbuffer

var fogbuffer = argument0;

texture_set_stage(sampler_map[?"uFogBuffer"], surface_get_texture(fogbuffer))
render_set_uniform_color("uFogColor", app.background_fog_color_final, 1)
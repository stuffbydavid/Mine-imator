/// shader_high_fog_apply_set(fogbuffer)
/// @arg fogbuffer

function shader_high_fog_apply_set(fogbuffer)
{
	texture_set_stage(sampler_map[?"uFogBuffer"], surface_get_texture(fogbuffer))
	render_set_uniform_color("uFogColor", app.background_fog_object_color_final, 1)
}

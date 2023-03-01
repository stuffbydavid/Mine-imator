/// shader_high_raytrace_resolve_set(indirect)
/// @arg indirect

function shader_high_raytrace_resolve_set(indirect = false)
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_depth))
	gpu_set_texrepeat_ext(sampler_map[?"uDepthBuffer"], false)
	
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(render_surface_normal))
	gpu_set_texrepeat_ext(sampler_map[?"uNormalBuffer"], false)
	
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(render_surface_material))
	gpu_set_texrepeat_ext(sampler_map[?"uMaterialBuffer"], false)
	
	render_set_uniform("uNormalBufferScale", is_cpp() ? normal_buffer_scale : 1)
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	render_set_uniform_int("uIndirect", bool_to_float(indirect))
}

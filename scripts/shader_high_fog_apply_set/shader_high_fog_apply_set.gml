/// shader_high_reflections_apply_set(reflectionsbuffer)
/// @arg reflectionsbuffer

function shader_high_reflections_apply_set(reflectionsbuffer)
{
	texture_set_stage(sampler_map[?"uReflectionsBuffer"], surface_get_texture(reflectionsbuffer))
}

/// shader_depth_set()

var uTexture = shader_get_sampler_index(shader_depth, "uTexture"), 
	uNear = shader_get_uniform(shader_depth, "uNear"), 
	uFar = shader_get_uniform(shader_depth, "uFar");

shader_set(shader_depth)

if (shader_texture_gm)
	texture_set_stage(uTexture, shader_texture)
else
	texture_set_stage_lib(uTexture, shader_texture)
	
shader_set_uniform_f(uNear, proj_depth_near)
shader_set_uniform_f(uFar, proj_depth_far)

shader_set_wind(shader_depth)

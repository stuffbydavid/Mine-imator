/// shader_depth_point_set()

var uTexture = shader_get_sampler_index(shader_depth_point, "uTexture"), 
	uEye = shader_get_uniform(shader_depth_point, "uEye"), 
	uNear = shader_get_uniform(shader_depth_point, "uNear"), 
	uFar = shader_get_uniform(shader_depth_point, "uFar");

shader_set(shader_depth_point)

if (shader_texture_gm)
	texture_set_stage(uTexture, shader_texture)
else
	texture_set_stage_lib(uTexture, shader_texture)
	
shader_set_uniform_f(uEye, proj_from[X], proj_from[Y], proj_from[Z])
shader_set_uniform_f(uNear, proj_depth_near)
shader_set_uniform_f(uFar, proj_depth_far)

shader_set_wind(shader_depth_point)

/// shader_replace_set()

var uTexture = shader_get_sampler_index(shader_replace, "uTexture"), 
	uReplaceColor = shader_get_uniform(shader_replace, "uReplaceColor");

shader_set(shader_replace)

shader_set_texture(uTexture, shader_texture)

shader_set_uniform_color(uReplaceColor, shader_replace_color, 1)

shader_set_wind(shader_replace)

/// shader_blend_fog_set()

var uTexture = shader_get_sampler_index(shader_blend_fog, "uTexture"), 
    uBlendColor = shader_get_uniform(shader_blend_fog, "uBlendColor");

shader_set(shader_blend_fog)

texture_set_filtering(uTexture, shader_texture_filter_linear, shader_texture_filter_mipmap)
if (shader_texture_gm)
    texture_set_stage(uTexture, shader_texture)
else
    texture_set_stage_lib(uTexture, shader_texture)

shader_set_uniform_color(uBlendColor, shader_blend_color, shader_alpha)

shader_set_fog(shader_blend_fog)
shader_set_wind(shader_blend_fog)

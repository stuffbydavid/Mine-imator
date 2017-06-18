/// tl_set_shader()
/// @desc Sets the colorizing parameters.

shader_tl = id
shader_blend_color = c_white
shader_alpha = value_inherit[ALPHA]
shader_rgbadd = value_inherit[RGBADD]
shader_rgbsub = value_inherit[RGBSUB]
shader_rgbmul = value_inherit[RGBMUL]
shader_hsbadd = value_inherit[HSBADD]
shader_hsbsub = value_inherit[HSBSUB]
shader_hsbmul = value_inherit[HSBMUL]
shader_mixcolor = value_inherit[MIXCOLOR]
shader_mixpercent = value_inherit[MIXPERCENT]
shader_brightness = value_inherit[BRIGHTNESS]
shader_colors_ext = (shader_alpha < 1 || shader_rgbadd - shader_rgbsub != c_black || shader_rgbmul < c_white || shader_hsbadd - shader_hsbsub != c_black || shader_hsbmul < c_white || shader_mixpercent > 0)

shader_wind = wind
shader_wind_terrain = wind_terrain
shader_ssao = ssao
shader_fog = fog

/// tl_set_shader()
/// @desc Sets the colorizing parameters.

shader_tl = id
shader_blend_color = c_white
shader_alpha = value_inherit[e_value.ALPHA]
shader_rgbadd = value_inherit[e_value.RGB_ADD]
shader_rgbsub = value_inherit[e_value.RGB_SUB]
shader_rgbmul = value_inherit[e_value.RGB_MUL]
shader_hsbadd = value_inherit[e_value.HSB_ADD]
shader_hsbsub = value_inherit[e_value.HSB_SUB]
shader_hsbmul = value_inherit[e_value.HSB_MUL]
shader_mixcolor = value_inherit[e_value.MIX_COLOR]
shader_mixpercent = value_inherit[e_value.MIX_PERCENT]
shader_brightness = value_inherit[e_value.BRIGHTNESS]
shader_colors_ext = (shader_alpha < 1 ||
					 shader_rgbadd - shader_rgbsub != c_black ||
					 shader_rgbmul < c_white ||
					 shader_hsbadd - shader_hsbsub != c_black ||
					 shader_hsbmul < c_white ||
					 shader_mixpercent > 0)

shader_wind = wind
shader_wind_terrain = wind_terrain
shader_ssao = ssao
shader_fog = fog

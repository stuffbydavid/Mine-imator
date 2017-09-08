/// shader_clear()

shader_tl = null
shader_texture = -1
shader_texture_surface = false
shader_blend_color = c_white
shader_alpha = 1

shader_colors_ext = false
shader_rgbadd = 0
shader_rgbsub = 0
shader_rgbmul = c_white
shader_hsbadd = 0
shader_hsbsub = 0
shader_hsbmul = c_white
shader_mixcolor = 0
shader_mixpercent = 0
shader_brightness = 0

shader_texture_filter_linear = false
shader_texture_filter_mipmap = false
shader_wind = false
shader_wind_terrain = true
shader_ssao = true
shader_fog = true
shader_is_ground = false

if (shader_current() > -1)
	shader_reset()
	
gpu_set_tex_mip_enable(false)
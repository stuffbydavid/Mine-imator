/// render_world_ground()
/// @desc Renders a seemingly infinite plane with a repeated texture.

if (!background_ground_show)
	return 0

var xo, yo;
xo = (cam_from[X] div 16) * 16
yo = (cam_from[Y] div 16) * 16

shader_is_ground = true
shader_blend_color = block_texture_get_blend(background_ground_name, background_ground_tex)
if (background_ground_ani)
	shader_texture = background_ground_ani_texture[block_texture_get_frame()]
else
	shader_texture = background_ground_texture
	
shader_texture_filter_mipmap = app.setting_texture_filtering

switch (render_mode)
{
	case "colorfog": shader_color_fog_set() break
	case "colorfoglights":
		shader_blend_color = color_multiply(color_add(background_ambient_color_final, background_sunlight_color_final), shader_blend_color) // Simulate normal
		if (background_fog_show)
			shader_blend_fog_set()
		else
			shader_blend_set()
		break
		
	case "alphafix":
		shader_blend_color = c_black
		shader_blend_set()
		break
		
	case "highssaodepthnormal": shader_high_ssao_depth_normal_set() break
	case "highlightsun":		shader_high_light_sun_set() break
	case "highlightspot":		shader_high_light_spot_set() break
	case "highlightpoint":		shader_high_light_point_set() break
	case "highlightnight":		shader_high_light_night_set() break
	case "highfog":				shader_high_fog_set() break
	case "highdofdepth":		shader_depth_set() break
}

vbuffer_render(background_ground_vbuffer, point3D(xo, yo, 0))

shader_is_ground = false
shader_clear()

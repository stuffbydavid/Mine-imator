/// shader_use()
/// @desc Sets the shader depending on the mode

switch (render_mode)
{
	case "click":
		shader_replace_color = shader_tl
		shader_replace_set()
		break
	
	case "select":
	case "preview": shader_blend_set() break
	case "colorfog": shader_color_fog_set() break
	case "colorfoglights": shader_color_fog_lights_set() break
	
	case "alphafix":
		shader_blend_color = c_black
		shader_blend_set()
		break
		
	case "alphatest":
		shader_blend_color = c_black
		shader_alpha_test_set()
		break
	
	// High quality
	case "highssaodepthnormal": shader_high_ssao_depth_normal_set() break
	case "highdofdepth":
	case "highlightsundepth":
	case "highlightspotdepth": shader_depth_set() break
	case "highlightpointdepth": shader_depth_point_set() break
	case "highlightsun": shader_high_light_sun_set() break
	case "highlightspot": shader_high_light_spot_set() break
	case "highlightpoint": shader_high_light_point_set() break
	case "highlightnight": shader_high_light_night_set() break
	case "highfog": shader_high_fog_set() break
}

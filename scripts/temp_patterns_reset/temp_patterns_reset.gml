/// temp_patterns_reset()
/// @desc Resets banner patterns to default settings.

function temp_patterns_reset()
{
	if (model_name != "banner")
		return 0
	
	banner_pattern_list = 0
	banner_pattern_list = array()
	
	banner_color_list = 0
	banner_color_list = array()
	
	banner_base_color = c_minecraft_white
	
	banner_skin = minecraft_banner_generate(banner_base_color, banner_pattern_list, banner_color_list)
}

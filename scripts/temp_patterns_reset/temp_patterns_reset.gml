/// temp_patterns_reset()
/// @desc Resets pattern to default settings.

function temp_patterns_reset()
{
	if (pattern_type = "")
		return 0
	
	pattern_pattern_list = 0
	pattern_pattern_list = array()
	
	pattern_color_list = 0
	pattern_color_list = array()
	
	pattern_base_color = c_minecraft_white
	
	pattern_skin = minecraft_update_pattern_generate(pattern_type, pattern_base_color, pattern_pattern_list, pattern_color_list)
}

/// action_lib_model_banner(color, patterns_array, colors_array)
/// @arg color
/// @arg patterns_array
/// @arg colors_array

var color, patterns, colors;

if (history_undo)
{
	color = history_data.old_banner_color
	patterns = array_copy_1d(history_data.old_banner_patterns)
	colors = array_copy_1d(history_data.old_banner_colors)
}
else if (history_redo)
{
	color = history_data.new_banner_color
	patterns = array_copy_1d(history_data.new_banner_patterns)
	colors = array_copy_1d(history_data.new_banner_colors)
}
else
{
	var hobj;
	color = argument0
	patterns = array_copy_1d(argument1)
	colors = array_copy_1d(argument2)
	history_pop()
	
	if (history_amount > 0 && history[0].script = action_lib_model_banner)
		hobj = history[0]
	else
	{
		history_push()
		hobj = new_history(action_lib_model_banner)
		hobj.old_banner_color = color
		hobj.old_banner_patterns = array_copy_1d(temp_edit.banner_pattern_list)
		hobj.old_banner_colors = array_copy_1d(temp_edit.banner_color_list)
	}
	hobj.new_banner_color = color
	hobj.new_banner_patterns = patterns
	hobj.new_banner_colors = colors
	history[0] = hobj
}

with (temp_edit)
{
	banner_base_color = color
	banner_pattern_list = patterns
	banner_color_list = colors
}

array_add(banner_update, temp_edit)
lib_preview.update = true
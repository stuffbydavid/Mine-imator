/// action_lib_model_pattern(color, patterns_array, colors_array)
/// @arg color
/// @arg patterns_array
/// @arg colors_array

function action_lib_model_pattern(color, patterns, colors)
{
	if (history_undo)
	{
		color = history_data.old_pattern_color
		patterns = array_copy_1d(history_data.old_pattern_patterns)
		colors = array_copy_1d(history_data.old_pattern_colors)
	}
	else if (history_redo)
	{
		color = history_data.new_pattern_color
		patterns = array_copy_1d(history_data.new_pattern_patterns)
		colors = array_copy_1d(history_data.new_pattern_colors)
	}
	else
	{
		var hobj;
		history_pop()
		
		if (history_amount > 0 && history[0].script = action_lib_model_pattern)
			hobj = history[0]
		else
		{
			history_push()
			hobj = new_history(action_lib_model_pattern)
			hobj.old_pattern_color = color
			hobj.old_pattern_patterns = array_copy_1d(temp_edit.pattern_pattern_list)
			hobj.old_pattern_colors = array_copy_1d(temp_edit.pattern_color_list)
		}
		
		hobj.new_pattern_color = color
		hobj.new_pattern_patterns = patterns
		hobj.new_pattern_colors = colors
		
		history[0] = hobj
	}
	
	with (temp_edit)
	{
		pattern_base_color = color
		pattern_pattern_list = patterns
		pattern_color_list = colors
	}
	
	array_add(pattern_update, temp_edit)
	lib_preview.update = true
}

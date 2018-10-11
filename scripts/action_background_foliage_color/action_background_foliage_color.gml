/// action_background_foliage_color(color)
/// @arg color

if (history_undo)
	col = history_data.old_value
else if (history_redo)
	col = history_data.new_value
else
{
	col = argument0
	if (action_tl_select_single(null, e_tl_type.BACKGROUND))
	{
		tl_value_set_start(action_background_foliage_color, true)
		tl_value_set(e_value.BG_FOLIAGE_COLOR, col, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_foliage_color, background_foliage_color, col, true)
}

background_foliage_color = col

with (obj_resource)
	res_update_colors()

properties.library.preview.update = true
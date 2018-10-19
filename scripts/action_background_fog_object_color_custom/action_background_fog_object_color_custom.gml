/// action_background_fog_object_color_custom(custom)
/// @arg custom

var custom;

if (history_undo)
	custom = history_data.old_value
else if (history_redo)
	custom = history_data.new_value
else
{
	custom = argument0
	if (action_tl_select_single(null, e_tl_type.BACKGROUND))
	{
		tl_value_set_start(action_background_fog_object_color_custom, true)
		tl_value_set(e_value.BG_FOG_CUSTOM_OBJECT_COLOR, custom, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_fog_object_color_custom, background_fog_object_color_custom, custom, false)
}

background_fog_object_color_custom = custom

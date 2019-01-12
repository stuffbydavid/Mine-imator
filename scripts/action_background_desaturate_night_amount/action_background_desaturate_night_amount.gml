/// action_background_desaturate_night_amount(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value * 100
else if (history_redo)
	val = history_data.new_value * 100
else
{
	val = argument0
	add = argument1
	if (action_tl_select_single(null, e_tl_type.BACKGROUND))
	{
		tl_value_set_start(action_background_desaturate_night_amount, true)
		tl_value_set(e_value.BG_DESATURATE_NIGHT_AMOUNT, val / 100, add)
		tl_value_set_done()
		return 0
	}
	
	history_set_var(action_background_desaturate_night_amount, background_desaturate_night_amount, background_desaturate_night_amount * add + val / 100, true)
}

background_desaturate_night_amount = background_desaturate_night_amount * add + val / 100

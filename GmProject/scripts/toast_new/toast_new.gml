/// toast_new(variant, text)
/// @arg variant
/// @arg text

function toast_new(variant, text)
{
	var toast, type, color, icon;
	color = setting_theme.toast_color[variant]
	switch (variant)
	{
		case e_toast.INFO: icon = icons.INFO; type = "info"; break;
		case e_toast.POSITIVE: icon = icons.TICK; type = "positive"; break;
		case e_toast.WARNING: icon = icons.WARNING_TRIANGLE; type = "warning"; break;
		case e_toast.NEGATIVE: icon = icons.WARNING_TRIANGLE; type = "negative"; break;
		default: icon = icons.HELP; type = "unknown";
	}

	for (var i = ds_list_size(toast_list) - 1; i >= 0; i--)
	{
		toast = toast_list[|i]
		if (toast.text != text || setting_theme.toast_color[toast.variant] != color)
			continue

		toast.time_created = current_time
		toast.shake_time = current_time
		toast.dismiss_time = max(2, string_length(text) * .1)
		toast.remove = false
		toast.remove_alpha = 1
		toast.variant = variant
		toast.icon = icon
		toast.iid = null
		ds_list_clear(toast.actions)
		toast_last = toast
		return toast
	}

	toast = new_obj(obj_toast);
	ds_list_add(toast_list, toast)
	toast_amount++
	
	toast.icon = icon
	toast.variant = variant
	toast.text = text
	toast.dismiss_time = max(2, (string_length(toast.text) * .1))
	toast_last = toast
	
	log("New toast", toast.text, type)
	
	return toast
}

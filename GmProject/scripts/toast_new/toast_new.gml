/// toast_new(variant, text)
/// @arg variant
/// @arg text

function toast_new(variant, text)
{
	var toast, type
	toast = new_obj(obj_toast);
	ds_list_add(toast_list, toast)
	toast_amount++
	
	switch (variant)
	{
		case e_toast.INFO: toast.icon = icons.INFO; type = "info"; break;
		case e_toast.POSITIVE: toast.icon = icons.TICK; type = "positive"; break;
		case e_toast.WARNING: toast.icon = icons.WARNING_TRIANGLE; type = "warning"; break;
		case e_toast.NEGATIVE: toast.icon = icons.WARNING_TRIANGLE; type = "negative"; break;
		default: toast.icon = icons.HELP; type = "unknown";
	}
	
	toast.variant = variant
	toast.text = text
	toast.dismiss_time = max(2, (string_length(toast.text) * .1))
	toast_last = toast
	
	log("New toast", toast.text, type)
	
	return toast
}

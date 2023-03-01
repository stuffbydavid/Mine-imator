/// action_setting_scenery_remove_edges(value)
/// @arg value

function action_setting_scenery_remove_edges(val)
{
	setting_scenery_remove_edges = val
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}

function action_setting_scenery_remove_edges(value)
{
	setting_scenery_remove_edges = value
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}

/// menu_event_destroy()

if (menu_list != null)
	list_destroy(menu_list)

instance_destroy(menu_scroll_vertical)
instance_destroy(menu_scroll_horizontal)

ds_list_delete(app.menu_list, ds_list_find_index(app.menu_list, id))
app.menu_count--

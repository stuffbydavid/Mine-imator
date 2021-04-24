/// menu_timeline_init(menu)
/// @arg menu

function menu_timeline_init(menu)
{
	list_init_start()
	menu_add_timeline(null, -1, menu)
	return list_init_end()
}

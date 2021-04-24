/// menu_clear()

function menu_clear()
{
	menu_amount = 0
	
	if (instance_exists(menu_list))
		list_destroy(menu_list)
	
	menu_list = null
}

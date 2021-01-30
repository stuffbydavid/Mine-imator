/// menu_clear()

/*
with (obj_menuitem)
	instance_destroy()
*/

menu_amount = 0

if (instance_exists(menu_list))
	list_destroy(menu_list)

menu_list = null

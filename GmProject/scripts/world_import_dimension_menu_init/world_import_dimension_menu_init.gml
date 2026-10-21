/// @desc Add the dimensions visited in the world to the menu list.

function world_import_dimension_menu_init()
{
	menu_add_item("overworld", text_get("world_import/overworld"))
	if (world_import_has_dimension("the_nether"))
		menu_add_item("the_nether", text_get("world_import/the_nether"))
	if (world_import_has_dimension("the_end"))
		menu_add_item("the_end", text_get("world_import/the_end"))
}

/// world_import_dimension_menu_init()
/// Add the dimensions available on the system to the menu list.

function world_import_dimension_menu_init()
{
	menu_add_item("overworld", text_get("worldimportoverworld"))
	if (world_import_has_dimension("the_nether"))
		menu_add_item("the_nether", text_get("worldimportthenether"))
	if (world_import_has_dimension("the_end"))
		menu_add_item("the_end", text_get("worldimporttheend"))
}
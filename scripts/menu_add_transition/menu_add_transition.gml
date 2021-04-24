/// draw_menu_add_transition(transition)
/// @arg transition
/// @desc Adds a new transition to the dropdown menu.

function menu_add_transition()
{
	var item = new_obj(obj_menuitem);
	item.value = argument0
	item.script = null

	app.menu_item[app.menu_amount] = item
	app.menu_amount++
}

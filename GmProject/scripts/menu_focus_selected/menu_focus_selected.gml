/// menu_focus_selected()
/// @desc Sets the scrollbar position to show the selected value.

function menu_focus_selected()
{
	for (var m = 0; m < menu_amount; m++)
	{
		if (menu_value = menu_list.item[|m].value)
		{
			menu_scroll_vertical.value = floor(clamp(m - floor(menu_show_amount / 2), 0, max(0, menu_amount - menu_show_amount)) / floor(menu_w / menu_item_w)) * menu_item_h
			menu_scroll_vertical.value_goal = menu_scroll_vertical.value
			break
		}
	}
}

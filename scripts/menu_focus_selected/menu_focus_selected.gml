/// menu_focus_selected()
/// @desc Sets the scrollbar position to show the selected value.

for (var m = 0; m < menu_amount; m++)
{
	if (menu_value = menu_item[m].value)
	{
		menu_scroll.value = floor(clamp(m - floor(menu_show_amount / 2), 0, max(0, menu_amount - menu_show_amount)) / floor(menu_w / menu_item_w)) * menu_item_h
		break
	}
}
/// draw_button_sidemenu(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var xx, yy, wid, hei;
var mouseon;
xx = argument0
yy = argument1
wid = argument2
hei = argument3

mouseon = app_mouse_box(xx, yy, wid, hei)

if (mouseon)
	mouse_cursor = cr_handpoint
	
microani_set("menu", null, mouseon, mouseon && mouse_left, sidemenu_open)

if (sidemenu_open || mcroani_arr[e_mcroani.ACTIVE_LINEAR] > 0)
{
	var frame = floor((sprite_get_number(spr_sidemenu_open) - 1) * mcroani_arr[e_mcroani.ACTIVE_LINEAR]);
	draw_image(spr_sidemenu_open, frame, xx + wid/2, yy + wid/2, 1, 1, c_text_secondary, a_text_secondary)
	tip_set(text_get("tooltipsidemenuclose"), xx, yy, wid, hei)
}
else
{
	var frame = floor((sprite_get_number(spr_sidemenu_hover) - 1) * mcroani_arr[e_mcroani.HOVER_LINEAR]);
	draw_image(spr_sidemenu_hover, frame, xx + wid/2, yy + wid/2, 1, 1, c_text_secondary, a_text_secondary)
	tip_set(text_get("tooltipsidemenuopen"), xx, yy, wid, hei)
}

microani_update(mouseon, mouseon && mouse_left, sidemenu_open, false)

if (mouse_left_released && mouseon)
{
	if (sidemenu_open)
	{
		sidemenu_open = false
		menu_panel_ani_type = "hide"
	}
	else
	{
		sidemenu_open = true
		menu_panel_ani_type = "show"
	}
}
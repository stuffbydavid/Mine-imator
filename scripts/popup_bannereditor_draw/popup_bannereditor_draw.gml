/// popup_bannereditor_draw()

var patternlist, colorlist;
patternlist = popup_bannereditor.pattern_list_edit
colorlist = popup_bannereditor.pattern_color_list_edit

if (keyboard_check_pressed(vk_escape))
	popup_close()

var banner, bannerpatternres;
banner = popup_bannereditor.banner_edit

if (banner.model_tex.type = e_res_type.SKIN)
	bannerpatternres = mc_res
else
	bannerpatternres = banner.model_tex

// Preview
draw_box(dx, dy, 20 * 8, 40 * 8, false, banner.banner_base_color, 1)

for (var i = 0; i < ds_list_size(patternlist); i++)
{
	var pattern = ds_list_find_index(minecraft_banner_pattern_list, patternlist[|i]);
	draw_sprite_ext(popup_bannereditor.pattern_sprites[pattern], 0, dx, dy, (1 / popup_bannereditor.res_ratio) * 8, (1 / popup_bannereditor.res_ratio) * 8, 0, colorlist[|i], 1)
}

gpu_set_blendmode_ext(bm_zero, bm_src_color)
draw_sprite_ext(popup_bannereditor.pattern_sprites[array_length_1d(popup_bannereditor.pattern_sprites) - 1], 0, dx, dy, (1 / popup_bannereditor.res_ratio) * 8, (1 / popup_bannereditor.res_ratio) * 8, 0, c_white, 1)
gpu_set_blendmode(bm_normal)

// Pattern list buttons
var buttonx, buttony;
buttonx = dx + 160 + (16 * 2) + 2
buttony = dy + 328

// New button
if (draw_button_normal("bannereditornew", buttonx, buttony, 24, 24, e_button.NO_TEXT, false, false, true, icons.CREATE))
{
	if (popup_bannereditor.banner_pattern_edit > -1)
	{
		ds_list_insert(patternlist, popup_bannereditor.banner_pattern_edit, minecraft_banner_pattern_list[|0])
		ds_list_insert(colorlist, popup_bannereditor.banner_pattern_edit, c_minecraft_white)
		popup_bannereditor.banner_pattern_edit++
	}
	else
	{
		ds_list_add(patternlist, minecraft_banner_pattern_list[|1])
		ds_list_add(colorlist, c_minecraft_white)
		popup_bannereditor.banner_pattern_edit = ds_list_size(patternlist)
	}
}

dx += (20 * 8) + 16
draw_separator_vertical(dx, dy, 320)

dx += 16 + 2
	
// Pattern list
var listy = dy;
var listh = 44;
var listw = 232;
var listcount = ds_list_size(patternlist) + 1;
	
draw_label(text_get("bannereditorpatterns") + ":", dx, listy + 4 + 9, fa_left, fa_bottom)
listy += 16
	
popup_bannereditor.pattern_scroll.snap_value = listh
scrollbar_draw(popup_bannereditor.pattern_scroll, "vertical", dx + listw - 15, dy, listh * 7, listcount * listh)
	
for (var i = round(popup_bannereditor.pattern_scroll.value / listh); i < listcount; i++)
{
	var dw = listw - (15 * popup_bannereditor.pattern_scroll.needed);
	var notbase = (i > 0);
	var patternindex = i - 1;
	
	if (listy + listh > (dy + 16) + (listh * 7))
		break
		
	var mouseon = app_mouse_box(dx, listy, dw, listh);
	var selectmouseon, selectwidth;
	selectmouseon = false
	selectwidth = dw - ((28 + (30 * (listcount > 1))) * mouseon) * notbase
		
	if (mouseon)
	{
		popup_mouseon = false
		mouse_cursor = cr_handpoint
		selectmouseon = app_mouse_box(dx, listy, selectwidth, listh)
	}
		
	var pattern = test(notbase, ds_list_find_index(minecraft_banner_pattern_list, patternlist[|patternindex]), 0);
	
	if (popup_bannereditor.banner_pattern_edit = i || (selectmouseon && (mouse_left || mouse_left_released)))
	{
		draw_box(dx, listy, selectwidth, listh, false, setting_color_highlight, 1)
		draw_sprite_ext(popup_bannereditor.pattern_sprites[pattern], 0, dx + 30 + 8, listy + 2, 1 / popup_bannereditor.res_ratio, 1 / popup_bannereditor.res_ratio, 0, c_white, 1)
	}
	else
		draw_sprite_ext(popup_bannereditor.pattern_sprites[pattern], 0, dx + 30 + 8, listy + 2, 1 / popup_bannereditor.res_ratio, 1 / popup_bannereditor.res_ratio, 0, c_black, 1)
		
	if (selectmouseon && mouse_left_released)
	{
		if (popup_bannereditor.banner_pattern_edit = i)
			popup_bannereditor.banner_pattern_edit = -1
		else
			popup_bannereditor.banner_pattern_edit = i
	}
		
	// Buttons
	if (mouseon && notbase)
	{
		if (listcount > 1)
		{
			// Move up
			if (i > 1)
			{
				if (draw_button_normal("bannereditormoveup", dx + dw - 24 - 26, listy + 2, 18, 18, e_button.NO_TEXT, false, false, true, icons.ARROW_UP))
				{
					var swappattern, swapcolor;
					swappattern = patternlist[|patternindex - 1]
					swapcolor = colorlist[|patternindex - 1]
						
					patternlist[|patternindex - 1] = patternlist[|patternindex]
					colorlist[|patternindex - 1] = colorlist[|patternindex]
						
					patternlist[|patternindex] = swappattern
					colorlist[|patternindex] = swapcolor
				}
			}
			
			// Move down
			if (i < listcount - 1)
			{
				if (draw_button_normal("bannereditormovedown", dx + dw - 24 - 26, listy + listh - 20, 18, 18, e_button.NO_TEXT, false, false, true, icons.ARROW_DOWN))
				{
					var swappattern, swapcolor;
					swappattern = patternlist[|patternindex + 1]
					swapcolor = colorlist[|patternindex + 1]
						
					patternlist[|patternindex + 1] = patternlist[|patternindex]
					colorlist[|patternindex + 1] = colorlist[|patternindex]
						
					patternlist[|patternindex] = swappattern
					colorlist[|patternindex] = swapcolor
				}
			}
		}
			
		// Remove
		if (draw_button_normal("bannereditorremove", dx + dw - 24, listy + listh / 2-10, 20, 20, e_button.NO_TEXT, false, false, true, icons.CLOSE))
		{
			ds_list_delete(patternlist, patternindex)
			ds_list_delete(colorlist, patternindex)
			
			popup_bannereditor.banner_pattern_edit--
			
			i++
			//if (ds_list_size(patternlist) = 0 || i = popup_bannereditor.banner_pattern_edit)
			//	popup_bannereditor.banner_pattern_edit = -1
				
			continue
		}
	}
		
	var color = test(notbase, colorlist[|patternindex], banner.banner_base_color);
	
	draw_box(dx + 10, listy + 12, 20, 20, false, color, 1)
	draw_box(dx + 10, listy + 12, 20, 20, false, c_black, .25)
	draw_box(dx + 10 + 2, listy + 12 + 2, 20 - 4, 20 - 4, false, color, 1)
		
	listy += listh
}

dx += 232 + 16
	
draw_separator_vertical(dx, dy, 320)
	
dx += 16 + 2

// Selected pattern options
if (popup_bannereditor.banner_pattern_edit > -1)
{
	// Draw color options
	var buttonx, buttony, padding, buttonsize, buttonmouseon, color;
	buttonx = dx + 3
	buttony = dy
	padding = 2
	buttonsize = 24
	buttonmouseon = false
	color = c_white
		
	draw_label(text_get("bannereditorpatterncolor") + ":", dx, buttony + 4 + 9, fa_left, fa_bottom)
	buttony += 16
		
	for (var c = 0; c < ds_list_size(minecraft_color_list); c++)
	{
		color = minecraft_color_list[|c]
		buttonmouseon = app_mouse_box(buttonx, buttony, buttonsize, buttonsize)
	
		if (buttonmouseon)
			draw_box(buttonx - 1, buttony - 1, buttonsize + 2, buttonsize + 2, false, c_black, .5)
	
		draw_box(buttonx, buttony, buttonsize, buttonsize, false, color, 1)
		draw_box(buttonx, buttony, buttonsize, buttonsize, false, c_black, .25)
		draw_box(buttonx + 2, buttony + 2, buttonsize - 4, buttonsize - 4, false, color, 1)
	
		if (buttonmouseon)
		{
			draw_box(buttonx, buttony, buttonsize, buttonsize, false, c_black, .25 + (mouse_left * .25))
			popup_mouseon = false
			mouse_cursor = cr_handpoint
				
			if (mouse_left_released)
			{
				if (popup_bannereditor.banner_pattern_edit = 0)
					banner.banner_base_color = color
				else
					colorlist[|popup_bannereditor.banner_pattern_edit - 1] = color
			}
		}
		
		buttonx += (buttonsize + padding)
	
		// Can we draw another button? If not, move down
		if ((buttonx + (buttonsize + padding) > dx + 232))
		{
			buttonx = dx + 3
			buttony += buttonsize + padding
		}
	}
	
	dy = buttony + 8
	
	// Draw pattern options
	if (popup_bannereditor.banner_pattern_edit > 0)
	{
		var startx, buttonwidth, buttonheight;
		startx = dx
		buttonwidth = 20
		buttonheight = 40
		buttonx = startx
		buttony = dy
		padding = 4
		
		draw_label(text_get("bannereditorpatterntype") + ":", startx, buttony + 4 + 9, fa_left, fa_bottom)
		buttony += 16
		
		for (var p = 1; p < ds_list_size(minecraft_banner_pattern_list); p++)
		{
			draw_sprite_ext(popup_bannereditor.pattern_sprites[array_length_1d(popup_bannereditor.pattern_sprites) - 1], 0, buttonx, buttony, (1 / popup_bannereditor.res_ratio), (1 / popup_bannereditor.res_ratio), 0, c_white, 1)
			draw_sprite_ext(popup_bannereditor.pattern_sprites[p], 0, buttonx, buttony, (1 / popup_bannereditor.res_ratio), (1 / popup_bannereditor.res_ratio), 0, colorlist[|popup_bannereditor.banner_pattern_edit - 1], 1)
			
			buttonmouseon = app_mouse_box(buttonx, buttony, 20, 40)
			
			if (buttonmouseon)
			{
				draw_box(buttonx, buttony, 20, 40, false, c_black, 0.25 + (.25 * mouse_left))
				popup_mouseon = false
				mouse_cursor = cr_handpoint
				
				if (mouse_left_released)
					patternlist[|popup_bannereditor.banner_pattern_edit - 1] = minecraft_banner_pattern_list[|p]
			}
			
			buttonx += (buttonwidth + padding)
	
			// Can we draw another button? If not, move down
			if (buttonx + (buttonsize + padding) > dx + 232)
			{
				buttonx = startx
				buttony += buttonheight + padding
			}
		}
	}
}

// Cancel
dw = 100
dh = 32
dx = round(content_x + content_width / 2 - dw - 4)
dy = content_y + content_height - 32

if (draw_button_normal("bannereditorcancel", dx, dy, dw, 32))
{
	banner.banner_base_color = popup_bannereditor.prev_base_color
	popup_close()
}

// OK
dx = content_x + content_width / 2 + 4
if (draw_button_normal("bannereditorok", dx, dy, dw, 32))
{
	if (banner = temp_edit)
	{
		properties.library.preview.update = true
		action_lib_model_banner(banner.banner_base_color, array_set_ds_list(patternlist), array_set_ds_list(colorlist))
	}
	else if (banner.object_index = obj_bench_settings)
	{
		banner.banner_pattern_list = array_set_ds_list(patternlist)
		banner.banner_color_list = array_set_ds_list(colorlist)
		
		array_add(banner_update, banner)
		
		bench_settings.preview.update = true
	}
	
	popup_close()
}

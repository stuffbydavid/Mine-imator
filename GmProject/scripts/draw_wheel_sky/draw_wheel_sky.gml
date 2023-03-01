/// draw_wheel_sky(name, x, y, value, default, script, tbx, time)
/// @arg name
/// @arg x
/// @arg y
/// @arg value
/// @arg default
/// @arg script
/// @arg tbx
/// @arg time

function draw_wheel_sky(name, xx, yy, value, def, script, tbx, time)
{
	var rad, sunx, suny, moonx, moony, mouseon, sunmouseon, moonmouseon;
	
	if (textbox_jump)
		ds_list_add(textbox_list, [tbx, content_tab, yy, content_y, content_height])
	
	rad = 49
	if (xx + rad < content_x || xx - rad > content_x + content_width || yy + rad < content_y || yy - rad > content_y + content_height)
		return 0
	
	mouseon = app_mouse_box(xx - rad, yy - rad, rad*2, rad*2) && content_mouseon
	
	context_menu_area(xx - (rad + 10), yy - (rad + 10), (rad + 10) * 2, (rad + 10) * 2, "contextmenuvalue", value, time ? e_context_type.TIME : e_context_type.NUMBER, script, def)
	
	// Use "Pressing" & "Disabled" states for animations with sun/moon
	microani_set(name, script, mouseon, (window_busy = name && !wheel_drag_moon), (window_focus = string(tbx)), (window_busy = name && wheel_drag_moon))
	
	var active, color, alpha;
	active = min(1, microani_arr[e_microani.PRESS] + microani_arr[e_microani.ACTIVE] + microani_arr[e_microani.DISABLED])
	
	// Outline
	color = merge_color(c_text_tertiary, c_text_secondary, min(1, microani_arr[e_microani.HOVER] + active))
	alpha = lerp(a_text_tertiary, a_text_secondary, min(1, microani_arr[e_microani.HOVER] + active))
	draw_image(spr_circle_96, 0, xx, yy, 1, 1, color, alpha)
	
	// Label
	color = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.HOVER])
	color = merge_color(color, c_accent, active)
	alpha = lerp(a_text_secondary, a_text_main, microani_arr[e_microani.HOVER])
	alpha = lerp(alpha, 1, active)
	draw_label(text_get(name), xx, yy - 4, fa_center, fa_bottom, color, alpha, font_label)
	
	// Sun
	color = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.PRESS])
	color = merge_color(color, c_accent, microani_arr[e_microani.PRESS])
	alpha = lerp(a_text_secondary, a_text_main, microani_arr[e_microani.PRESS])
	alpha = lerp(alpha, 1, microani_arr[e_microani.PRESS])
	sunx = floor(xx + lengthdir_x(rad, value + 90))
	suny = floor(yy + lengthdir_y(rad, value + 90))
	sunmouseon = (app_mouse_box(sunx - 10, suny - 10, 20, 20) && content_mouseon)
	draw_circle_ext(sunx, suny, 14, false, 16, c_level_middle, 1)
	draw_image(spr_icons, icons.SUN, sunx, suny, 1, 1, color, alpha)
	
	// Moon
	color = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.DISABLED])
	color = merge_color(color, c_accent, microani_arr[e_microani.DISABLED])
	alpha = lerp(a_text_secondary, a_text_main, microani_arr[e_microani.DISABLED])
	alpha = lerp(alpha, 1, microani_arr[e_microani.DISABLED])
	moonx = floor(xx + lengthdir_x(rad, value - 90))
	moony = floor(yy + lengthdir_y(rad, value - 90))
	moonmouseon = (app_mouse_box(moonx - 10, moony - 10, 20, 20) && content_mouseon)
	draw_circle_ext(moonx, moony, 14, false, 16, c_level_middle, 1)
	draw_image(spr_icons, icons.MOON, moonx, moony, 1, 1, color, alpha)
	
	microani_update(mouseon || sunmouseon || moonmouseon, (window_busy = name && !wheel_drag_moon), (window_focus = string(tbx)), (window_busy = name && wheel_drag_moon))
	
	// Click
	if (sunmouseon || moonmouseon)
	{
		mouse_cursor = cr_handpoint
		
		if (mouse_left_pressed) // Start dragging
		{
			window_focus = name
			window_busy = name
			wheel_drag_moon = moonmouseon // Drag moon?
			
			if (!wheel_drag_moon)
			{
				var add = angle_difference_fix(point_direction(xx, yy, mouse_x, mouse_y) - 90, value);
				script_execute(script, add, true)
			}
		}
	}
	
	// Dragging
	if (window_busy = name)
	{
		var angle1, angle2, add;
		mouse_cursor = cr_handpoint
		angle1 = point_direction(xx, yy, mouse_x, mouse_y) - 90
		angle2 = point_direction(xx, yy, mouse_previous_x, mouse_previous_y) - 90
		add = angle_difference_fix(angle1, angle2)
		script_execute(script, add, true)
		
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
		}
	}
	
	// Textbox
	draw_set_font(font_value)
	
	var label, labelw, labelx;
	
	if (time)
		label = (window_focus = string(tbx) ? tbx.text : rotation_get_time(value))
	else
		label = (window_focus = string(tbx) ? tbx.text : (string(value) + tbx.suffix))
	
	labelw = string_width(label)
	labelx = xx - labelw/2
	
	if (window_focus = string(tbx))
	{
		if (textbox_draw(tbx, labelx, yy + 4, labelw, 18))
		{
			if (time)
				script_execute(script, time_get_rotation(tbx.text), false)
			else
				script_execute(script, clamp(string_get_real(tbx.text, 0), -no_limit, no_limit), false)
		}
	}
	else
		draw_label(label, labelx, yy + 4, fa_left, fa_top, c_text_main, a_text_main, font_value)
	
	// Textbox click
	if (app_mouse_box(labelx, yy + 4, labelw, 16))
	{
		mouse_cursor = cr_handpoint
		
		if (mouse_left_pressed)
		{
			if (time)
				tbx.text = rotation_get_time(value)
			else
				tbx.text = string(value)
			
			window_focus = string(tbx)
		}
	}
}

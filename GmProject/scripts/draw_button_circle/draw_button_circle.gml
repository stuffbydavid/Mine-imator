/// @arg label
/// @arg x
/// @arg y
/// @arg [radius]
/// @arg [type]
/// @arg [color]
/// @arg [icon]
/// @arg [script]
/// @arg [value]
/// @arg [tip]
/// @arg [disabled]
/// @arg [ignore]

function draw_button_circle(label, xx, yy, rad = 32, type = e_button.PRIMARY, color = c_accent, icon = null, script = null, value = null, tip = "", disabled = false, ignore = false)
{
	var font, cap, capwid, mouseon, mouseclick;
	var w, h;
	
	cap = label
	font = (type != e_button.TOOLBAR ? font_button : font_value)
	w = rad * 2
	h = rad * 2
	
	draw_set_font(font)
	capwid = string_width(cap)
	
	if (yy > content_y + content_height || yy + h < content_y || xx > content_x + content_width || xx + w < content_x)
		return 0
	
	mouseon = app_mouse_box(xx - rad-2, yy - rad-2, w + 4, h + 4, "view/click") && content_mouseon && !disabled
	mouseclick = mouseon && mouse_left
	microani_set(label, script, mouseon, mouseclick, false)
	
	var focus, backcolor, backalpha, linecolor, linealpha, contentcolor, contentalpha, contentx;
	focus = (script = null ? 0 : max(microani_arr[e_microani.ACTIVE], microani_arr[e_microani.PRESS]))
	
	if (type = e_button.PRIMARY || type = e_button.BIG)
	{
		backcolor = merge_color(color, merge_color(color, c_white, .25), microani_arr[e_microani.HOVER])
		backcolor = merge_color(backcolor, merge_color(color, c_white, 1), focus)
		backcolor = merge_color(backcolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
		backalpha = lerp(1, a_text_tertiary, microani_arr[e_microani.DISABLED])
		
		linecolor = merge_color(merge_color(color, c_overlay, .75), merge_color(color, c_overlay, 1), focus)
		linealpha = lerp(0, script = null ? 0 : 1, microani_arr[e_microani.HOVER])
		
		contentcolor = c_button_text
		contentalpha = 1
	}
	else
	{
		backcolor = merge_color(color, merge_color(color, c_black, .1), focus)
		backalpha = lerp(.5, .75, microani_arr[e_microani.HOVER])
		backalpha = lerp(backalpha, .25, focus)
		backalpha = lerp(backalpha, 0, microani_arr[e_microani.DISABLED])
		
		contentcolor = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.HOVER])
		contentcolor = merge_color(contentcolor, c_accent, focus)
		contentcolor = merge_color(contentcolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
		contentalpha = lerp(0, a_text_main, microani_arr[e_microani.HOVER])
		contentalpha = lerp(contentalpha, 1, focus)
		contentalpha = lerp(contentalpha, a_text_tertiary, microani_arr[e_microani.DISABLED])
		
		linecolor = merge_color(color, merge_color(color, c_white, .75), focus)
		linealpha = lerp(.75, 1, focus)
	}
	
	if (type = e_button.PRIMARY)
	{
		draw_image(spr_control_dial, 0, xx, yy, (rad+3)/24, (rad+3)/24, linecolor, linealpha)
		draw_image(spr_circle_32, 0, xx, yy, rad/16, rad/16, backcolor, backalpha)
	}
	
	if (type = e_button.SECONDARY)
	{
		draw_image(spr_circle_32, 0, xx, yy, rad/16, rad/16, linecolor, linealpha)
		draw_image(spr_circle_32, 0, xx, yy, rad/16, rad/16, c_level_top, backalpha)
	}
	
	contentx = floor(xx + rad - ((capwid + (icon = null ? 0 : 32)) / 2))
	
	if (icon != null)
	{
		draw_image(spr_icons, icon, contentx + 12, yy + h/2, 1, 1, contentcolor, contentalpha)
		contentx += 32
	}
	
	draw_label(cap, contentx - rad, yy, fa_left, fa_middle, contentcolor, contentalpha)
	
	microani_update(mouseon, mouseclick, false, disabled)
	
	if (mouseon)
	{
		if (tip != "")
			tip_set(text_get(tip), xx - rad-2, yy - rad-2, w + 4, h + 4)
		
		if (script != null)
		{
			mouse_cursor = cr_handpoint
			
			if (mouse_left_released)
			{
				if (!ignore)
					script_execute(script, value)
				return true
			}
		}
	}
	return false
}

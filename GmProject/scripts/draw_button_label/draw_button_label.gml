/// draw_button_label(name, x, y, [width, [icon, [type, [script, [anchor, [disabled]]]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg [width
/// @arg [icon
/// @arg [type
/// @arg [script
/// @arg [anchor
/// @arg [disabled]]]]]]

function draw_button_label(name, xx, yy, w = null, icon = null, type = e_button.PRIMARY, script = null, anchor = e_anchor.LEFT, disabled = false)
{
	var h, font, cap, capwid, customw;
	h = 32
	
	cap = text_get(name)
	
	h = (type != e_button.TOOLBAR ? 32 : toolbar_size)
	font = (type != e_button.TOOLBAR ? font_button : font_value)
	
	if (type = e_button.BIG)
	{
		h = 64
		font = font_heading_big
	}
	
	// Calculate width/position
	draw_set_font(font)
	capwid = string_width(cap)
	
	if (w = null)
	{
		w = capwid + (icon = null ? 24 : 52)
		customw = false
	}
	else
		customw = true
	
	if (anchor = e_anchor.CENTER)
		xx = xx - floor(w/2)
	else if (anchor = e_anchor.RIGHT)
		xx -= w
	
	if (yy > content_y + content_height || yy + h < content_y || xx > content_x + content_width || xx + w < content_x)
		return 0
	
	var mouseon, mouseclick;
	
	mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon && !disabled
	mouseclick = mouseon && mouse_left
	microani_set(name, script, mouseon, mouseclick, false)
	
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	var focus, backcolor, backalpha, linecolor, linealpha, contentcolor, contentalpha, contentx;
	focus = max(microani_arr[e_microani.ACTIVE], microani_arr[e_microani.PRESS])
	
	if (type = e_button.PRIMARY || type = e_button.BIG)
	{
		backcolor = merge_color(c_accent, c_accent_hover, microani_arr[e_microani.HOVER])
		backcolor = merge_color(backcolor, c_accent_pressed, focus)
		backcolor = merge_color(backcolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
		backalpha = lerp(1, a_text_tertiary, microani_arr[e_microani.DISABLED])
		
		contentcolor = c_button_text
		contentalpha = a_button_text
	}
	else
	{
		backcolor = merge_color(c_overlay, c_accent_overlay, focus)
		backalpha = lerp(0, a_overlay, microani_arr[e_microani.HOVER])
		backalpha = lerp(backalpha, a_accent_overlay, focus)
		backalpha = lerp(backalpha, 0, microani_arr[e_microani.DISABLED])
		
		contentcolor = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.HOVER])
		contentcolor = merge_color(contentcolor, c_accent, focus)
		contentcolor = merge_color(contentcolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
		contentalpha = lerp(a_text_secondary, a_text_main, microani_arr[e_microani.HOVER])
		contentalpha = lerp(contentalpha, 1, focus)
		contentalpha = lerp(contentalpha, a_text_tertiary, microani_arr[e_microani.DISABLED])
		
		linecolor = merge_color(c_border, c_accent, focus)
		linealpha = lerp(a_border, a_accent, focus)
	}
	
	// Background
	draw_box(xx, yy, w, h, false, backcolor, backalpha)
	
	// Bevel
	if (type = e_button.PRIMARY || type = e_button.BIG)
		draw_box_bevel(xx, yy, w, h, 1)
	
	// Background
	if (type = e_button.SECONDARY)
	{
		draw_box(xx, yy, w, h, false, c_level_top, draw_get_alpha())
		draw_outline(xx, yy, w, h, 1, linecolor, linealpha, 1)
	}
	
	// Focus ring
	draw_box_hover(xx, yy, w, h, microani_arr[e_microani.PRESS])
	
	if (customw)
		contentx = floor((xx + w/2) - ((capwid + (icon = null ? 0 : 32)) / 2))
	else
		contentx = floor(xx + (icon = null ? 12 : 8))
	
	// Draw icon
	if (icon != null)
	{
		draw_image(spr_icons, icon, contentx + 12, yy + h/2, 1, 1, contentcolor, contentalpha)
		contentx += 32
	}
	
	// Draw label
	draw_label(cap, contentx, yy + h/2, fa_left, fa_middle, contentcolor, contentalpha)
	
	microani_update(mouseon, mouseclick, false, disabled)
	
	if (mouseon && mouse_left_released)
	{
		if (script != null)
			script_execute(script)
		
		return true
	}
}

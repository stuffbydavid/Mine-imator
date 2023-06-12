/// draw_button_icon(name, x, y, width, height, value, icon, [script, [disabled, [tip, [sprite]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg value
/// @arg icon
/// @arg [script
/// @arg [disabled
/// @arg [tip
/// @arg [sprite]]]]

function draw_button_icon()
{
	var name, xx, yy, wid, hei, value, icon, script, disabled, tip, sprite;
	
	name = argument[0]
	xx = argument[1]
	yy = argument[2]
	wid = argument[3]
	hei = argument[4]
	value = argument[5]
	icon = argument[6]
	script = null
	disabled = false
	tip = ""
	sprite = spr_icons
	
	if (argument_count > 7)
		script = argument[7]
	
	if (argument_count > 8)
		disabled = argument[8]
	
	if (argument_count > 9)
		tip = argument[9]
	
	if (argument_count > 10)
		if (argument[10] != null)
			sprite = argument[10]
	
	if (tip != "")
		tip_set(text_get(tip), xx, yy, wid, hei)
	
	if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
		return 0
	
	var mouseon, animated;
	
	mouseon = (content_mouseon && !disabled && app_mouse_box(xx, yy, wid, hei))
	animated = (sprite != spr_icons && sprite != null && icon = null && sprite_get_number(sprite) > 1)
	
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	microani_set(name, script, mouseon, mouseon && mouse_left, value)
	
	// Hover outline
	draw_box_hover(xx, yy, wid, hei, microani_arr[e_microani.PRESS])
	
	// Background
	var onbackcolor, onbackalpha, oniconcolor, oniconalpha, offbackcolor, offbackalpha, officoncolor, officonalpha, dropdown;
	dropdown = (icon = icons.CHEVRON_DOWN_TINY)
	
	offbackcolor = c_overlay
	offbackcolor = merge_color(offbackcolor, c_accent_overlay, microani_arr[e_microani.PRESS])
	offbackalpha = lerp(0, a_overlay, microani_arr[e_microani.HOVER])
	offbackalpha = lerp(offbackalpha, a_accent_overlay, microani_arr[e_microani.PRESS])
	
	onbackcolor = merge_color(c_accent_overlay, c_overlay, microani_arr[e_microani.HOVER])
	onbackcolor = merge_color(onbackcolor, c_accent_overlay, microani_arr[e_microani.PRESS])
	onbackalpha = lerp(a_accent_overlay, a_overlay, microani_arr[e_microani.HOVER])
	onbackalpha = lerp(onbackalpha, a_accent_overlay, microani_arr[e_microani.PRESS])
	
	onbackcolor = merge_color(offbackcolor, onbackcolor, microani_arr[e_microani.ACTIVE] * !animated)
	onbackalpha = lerp(offbackalpha, onbackalpha, microani_arr[e_microani.ACTIVE] * !animated)
	onbackalpha = lerp(onbackalpha, 0, microani_arr[e_microani.DISABLED])
	
	officoncolor = merge_color(dropdown ? c_text_tertiary : c_text_secondary, c_text_main, microani_arr[e_microani.HOVER])
	officoncolor = merge_color(officoncolor, c_accent, microani_arr[e_microani.PRESS])
	officonalpha = lerp(dropdown ? a_text_tertiary : a_text_secondary, a_text_main, microani_arr[e_microani.HOVER])
	officonalpha = lerp(officonalpha, 1, microani_arr[e_microani.PRESS])
	
	oniconcolor = merge_color(c_accent, c_accent_hover, microani_arr[e_microani.HOVER])
	oniconcolor = merge_color(oniconcolor, c_accent_pressed, microani_arr[e_microani.PRESS])
	oniconalpha = merge_color(a_accent, a_accent_hover, microani_arr[e_microani.HOVER])
	oniconalpha = merge_color(oniconalpha, a_accent_pressed, microani_arr[e_microani.PRESS])
	
	oniconcolor = merge_color(officoncolor, oniconcolor, microani_arr[e_microani.ACTIVE] * !animated)
	oniconalpha = lerp(officonalpha, oniconalpha, microani_arr[e_microani.ACTIVE] * !animated)
	
	oniconcolor = merge_color(oniconcolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
	oniconalpha = lerp(oniconalpha, a_text_tertiary, microani_arr[e_microani.DISABLED])
	
	draw_box(xx, yy, wid, hei, false, onbackcolor, onbackalpha)
	
	// Animated icon(if 'icon' is a sprite)
	if (animated)
	{
		var frame = floor((sprite_get_number(sprite) - 1) * microani_arr[e_microani.ACTIVE]);
		draw_image(sprite, frame, xx + wid/2, yy + hei/2, 1, 1, oniconcolor, oniconalpha)
	}
	else // Icon
		draw_image(sprite, icon, xx + wid/2, yy + hei/2, 1, 1, oniconcolor, oniconalpha)
	
	microani_update(mouseon, mouseon && mouse_left, value, disabled)
	
	if (mouseon && mouse_left_released)
	{
		if (script != null)
			script_execute(script, !value)
		
		app_mouse_clear()
		
		return true
	}
}

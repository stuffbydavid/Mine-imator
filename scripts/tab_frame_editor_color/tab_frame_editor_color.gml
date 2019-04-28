/// tab_frame_editor_color()

var wid, capwid;
	
// Alpha
tab_control_meter()
draw_meter("frameeditoralpha", dx, dy, dw, round(tl_edit.value[e_value.ALPHA] * 100), 56, 0, 100, 100, 1, tab.color.tbx_alpha, action_tl_frame_alpha)
tab_next()

if (tab.color.advanced)
{
	// RGB
	wid = (dw - 40 - 16) / 3
	tab_control_color()
	draw_label(text_get("frameeditorrgb") + ":", dx, dy + 16, fa_left, fa_middle)
	draw_button_color("frameeditorrgbadd", dx + 40, dy, wid, tl_edit.value[e_value.RGB_ADD], c_black, false, action_tl_frame_rgb_add)
	draw_button_color("frameeditorrgbsub", dx + 40 + wid + 8, dy, wid, tl_edit.value[e_value.RGB_SUB], c_black, false, action_tl_frame_rgb_sub)
	draw_button_color("frameeditorrgbmul", dx + 40 + (wid + 8) * 2, dy, wid, tl_edit.value[e_value.RGB_MUL], c_white, false, action_tl_frame_rgb_mul)
	tab_next()
	
	// HSB
	tab_control_color()
	draw_label(text_get("frameeditorhsb") + ":", dx, dy + 16, fa_left, fa_middle)
	draw_button_color("frameeditorhsbadd", dx + 40, dy, wid, tl_edit.value[e_value.HSB_ADD], c_black, true, action_tl_frame_hsb_add)
	draw_button_color("frameeditorhsbsub", dx + 40 + wid + 8, dy, wid, tl_edit.value[e_value.HSB_SUB], c_black, true, action_tl_frame_hsb_sub)
	draw_button_color("frameeditorhsbmul", dx + 40 + (wid + 8) * 2, dy, wid, tl_edit.value[e_value.HSB_MUL], c_white, true, action_tl_frame_hsb_mul)
	tab_next()
}
else
{
	// Blend color
	tab_control_color()
	draw_button_color("frameeditorblendcolor", dx, dy, dw, tl_edit.value[e_value.RGB_MUL], c_white, false, action_tl_frame_rgb_mul)
	tab_next()
}

// Mix and (Glow?)
var halfwid = floor(dw / 2) - 4;
var glowenabled = tl_edit.glow && !tl_edit.value_type[e_value_type.CAMERA];
capwid = text_caption_width("frameeditormixpercent", "frameeditorbrightness")

tab_control_color()
draw_button_color("frameeditormixcolor", dx, dy, (glowenabled ? halfwid : dw), tl_edit.value[e_value.MIX_COLOR], c_black, false, action_tl_frame_mix_color)

if (glowenabled)
	draw_button_color("frameeditorglowcolor", dx + halfwid + 8, dy, halfwid, tl_edit.value[e_value.GLOW_COLOR], c_white, false, action_tl_frame_glow_color)
	
tab_next()

tab_control_meter()
draw_meter("frameeditormixpercent", dx, dy, dw, floor(tl_edit.value[e_value.MIX_PERCENT] * 100), 60, 0, 100, 0, 1, tab.color.tbx_mix_percent, action_tl_frame_mix_percent, capwid)
tab_next()

// Brightness
tab_control_meter()
draw_meter("frameeditorbrightness", dx, dy, dw, round(tl_edit.value[e_value.BRIGHTNESS] * 100), 60, 0, 100, 0, 1, tab.color.tbx_brightness, action_tl_frame_brightness, capwid)
tab_next()

// Tools
tab_control(24)

if (draw_button_normal("frameeditorcolorreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.RESET))
	action_tl_frame_set_colors(1, c_black, c_black, c_white, c_black, c_black, c_white, c_black, c_black, 0, 0)
	
if (draw_button_normal("frameeditorcoloradvanced", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, tab.color.advanced, false, true, icons.ADVANCED_COLORS))
	tab.color.advanced = !tab.color.advanced
	
if (draw_button_normal("frameeditorcolorcopy", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.COPY))
{
	tab.color.copy_alpha = tl_edit.value[e_value.ALPHA]
	tab.color.copy_rgb_add = tl_edit.value[e_value.RGB_ADD]
	tab.color.copy_rgb_sub = tl_edit.value[e_value.RGB_SUB]
	tab.color.copy_rgb_mul = tl_edit.value[e_value.RGB_MUL]
	tab.color.copy_hsb_add = tl_edit.value[e_value.HSB_ADD]
	tab.color.copy_hsb_sub = tl_edit.value[e_value.HSB_SUB]
	tab.color.copy_hsb_mul = tl_edit.value[e_value.HSB_MUL]
	tab.color.copy_glow_color = tl_edit.value[e_value.GLOW_COLOR]
	tab.color.copy_mix_color = tl_edit.value[e_value.MIX_COLOR]
	tab.color.copy_mix_percent = tl_edit.value[e_value.MIX_PERCENT]
	tab.color.copy_brightness = tl_edit.value[e_value.BRIGHTNESS]
}

if (draw_button_normal("frameeditorcolorpaste", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.PASTE))
{
	action_tl_frame_set_colors(tab.color.copy_alpha, 
							   tab.color.copy_rgb_add, 
							   tab.color.copy_rgb_sub, 
							   tab.color.copy_rgb_mul, 
							   tab.color.copy_hsb_add, 
							   tab.color.copy_hsb_sub, 
							   tab.color.copy_hsb_mul, 
							   tab.color.copy_mix_color,
							   tab.color.copy_glow_color,
							   tab.color.copy_mix_percent, 
							   tab.color.copy_brightness)
}
tab_next()

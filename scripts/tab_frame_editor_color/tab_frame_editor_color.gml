/// tab_frame_editor_color()

var wid, capwid;
	
// Alpha
tab_control_meter()
draw_meter("frameeditoralpha", dx, dy, dw, round(tl_edit.value[ALPHA] * 100), 56, 0, 100, 100, 1, tab.color.tbx_alpha, action_tl_frame_alpha)
tab_next()

if (tab.color.advanced)
{
	// RGB
	wid = (dw - 40 - 16) / 3
	tab_control_color()
	draw_label(text_get("frameeditorrgb") + ":", dx, dy + 16, fa_left, fa_middle)
	draw_button_color("frameeditorrgbadd", dx + 40, dy, wid, tl_edit.value[RGBADD], c_black, false, action_tl_frame_rgbadd)
	draw_button_color("frameeditorrgbsub", dx + 40 + wid + 8, dy, wid, tl_edit.value[RGBSUB], c_black, false, action_tl_frame_rgbsub)
	draw_button_color("frameeditorrgbmul", dx + 40 + (wid + 8) * 2, dy, wid, tl_edit.value[RGBMUL], c_white, false, action_tl_frame_rgbmul)
	tab_next()
	
	// HSB
	tab_control_color()
	draw_label(text_get("frameeditorhsb") + ":", dx, dy + 16, fa_left, fa_middle)
	draw_button_color("frameeditorhsbadd", dx + 40, dy, wid, tl_edit.value[HSBADD], c_black, true, action_tl_frame_hsbadd)
	draw_button_color("frameeditorhsbsub", dx + 40 + wid + 8, dy, wid, tl_edit.value[HSBSUB], c_black, true, action_tl_frame_hsbsub)
	draw_button_color("frameeditorhsbmul", dx + 40 + (wid + 8) * 2, dy, wid, tl_edit.value[HSBMUL], c_white, true, action_tl_frame_hsbmul)
	tab_next()
}
else
{
	// Blend color
	tab_control_color()
	draw_button_color("frameeditorblendcolor", dx, dy, dw, tl_edit.value[RGBMUL], c_white, false, action_tl_frame_rgbmul)
	tab_next()
}

// Mix
capwid = text_caption_width("frameeditormixpercent", "frameeditorbrightness")
tab_control_color()
draw_button_color("frameeditormixcolor", dx, dy, dw, tl_edit.value[MIXCOLOR], c_black, false, action_tl_frame_mixcolor)
tab_next()
tab_control_meter()
draw_meter("frameeditormixpercent", dx, dy, dw, floor(tl_edit.value[MIXPERCENT] * 100), 60, 0, 100, 0, 1, tab.color.tbx_mixpercent, action_tl_frame_mixpercent, capwid)
tab_next()

// Brightness
tab_control_meter()
draw_meter("frameeditorbrightness", dx, dy, dw, round(tl_edit.value[BRIGHTNESS] * 100), 60, 0, 100, 0, 1, tab.color.tbx_brightness, action_tl_frame_brightness, capwid)
tab_next()

// Tools
tab_control(24)

if (draw_button_normal("frameeditorcolorreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.reset))
	action_tl_frame_set_colors(1, c_black, c_black, c_white, c_black, c_black, c_white, c_black, 0, 0)
	
if (draw_button_normal("frameeditorcoloradvanced", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, tab.color.advanced, false, true, icons.advancedcolors))
	tab.color.advanced = !tab.color.advanced
	
if (draw_button_normal("frameeditorcolorcopy", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.copy))
{
	tab.color.copy_alpha = tl_edit.value[ALPHA]
	tab.color.copy_rgbadd = tl_edit.value[RGBADD]
	tab.color.copy_rgbsub = tl_edit.value[RGBSUB]
	tab.color.copy_rgbmul = tl_edit.value[RGBMUL]
	tab.color.copy_hsbadd = tl_edit.value[HSBADD]
	tab.color.copy_hsbsub = tl_edit.value[HSBSUB]
	tab.color.copy_hsbmul = tl_edit.value[HSBMUL]
	tab.color.copy_mixcolor = tl_edit.value[MIXCOLOR]
	tab.color.copy_mixpercent = tl_edit.value[MIXPERCENT]
	tab.color.copy_brightness = tl_edit.value[BRIGHTNESS]
}

if (draw_button_normal("frameeditorcolorpaste", dx + 25 * 3, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.paste))
{
	action_tl_frame_set_colors(tab.color.copy_alpha, 
							   tab.color.copy_rgbadd, 
							   tab.color.copy_rgbsub, 
							   tab.color.copy_rgbmul, 
							   tab.color.copy_hsbadd, 
							   tab.color.copy_hsbsub, 
							   tab.color.copy_hsbmul, 
							   tab.color.copy_mixcolor, 
							   tab.color.copy_mixpercent, 
							   tab.color.copy_brightness)
}
tab_next()

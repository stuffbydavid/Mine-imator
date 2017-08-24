/// draw_alert(alert)
/// @arg alert

var n, alpha, yoff, mouseon, titley;
var textx, texty, textw, texth;
var iconsize;
n = argument0

// Alpha
if (alert_fadetime[n] = null)
	alpha = 1
else
	alpha = 1 - max(0, (current_time - (alert_fadestart[n] + alert_fadetime[n])) / 3000)

if (alpha < 1 && n < alert_amount - 1)
	draw_alert(n + 1)
	
if (alpha < 0)
{
	alert_close(n)
	return 0
}

draw_set_alpha(alpha_alpha * alpha)

// Set box
content_x = alert_x
content_y = alert_y
content_y += sin(current_time / 25) * max(0, 1 - (current_time - alert_created[n]) / 500) * 10 // Jump effect
content_width = alert_width
content_height = alert_height
content_mouseon = (app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon)
if (content_mouseon)
	alert_fadestart[n] = current_time

// Tip
tip_set(string_remove_newline(alert_title[n]) + "\n" + alert_text[n], alert_x, alert_y, alert_width, alert_height)

// Box
draw_box_rounded(content_x, content_y, content_width, content_height, setting_color_alerts, 1)

textx = content_x + 10
textw = content_x + content_width - textx - 10

// Icon
if (alert_icon[n] > 0)
{
	var size, iconimage;
	size = test(content_direction = e_scroll.HORIZONTAL, alert_height, alert_width)
	if (size >= 50)
	{
		iconsize = 60
		iconimage = 2
	}
	else if (size >= 30)
	{
		iconsize = 36
		iconimage = 1
	}
	else
	{
		iconsize = 20
		iconimage = 0
	}
	draw_image(spr_icons_big, alert_icon[n] + iconimage - icons.WEBSITE_SMALL, content_x + test(content_width < 100, content_width / 2, 5 + iconsize / 2), content_y + content_height / 2, 1, 1, setting_color_alerts_text, 1)
	textx += iconsize
	textw -= iconsize
}
else
	iconsize = 0

// Button
if (alert_button[n] != "")
{
	var butw = text_caption_width(alert_button[n]) - 10;
	if (butw < content_width - iconsize - 20)
	{
		if (draw_button_normal(alert_button[n], content_x + content_width - butw - 10, content_y + floor(content_height / 2) - 12, butw, 24))
		{
			if (alert_button[n] = "alerttrialbutton")
				popup_switch(popup_upgrade)
			else
				open_url(alert_button_url[n])
		}
		textw -= butw + 10
	}
}

// Text
if (alert_text[n] != "" && content_height - 40 > 16){
	titley = content_y + 5
	texty = titley + 18
	texth = content_y + content_height - 6-texty
	draw_label(string_limit_ext(alert_text[n], textw, texth), textx, texty, fa_left, fa_top, setting_color_alerts_text, 1)
}
else
	titley = content_y + floor(content_height / 2) - 8

// Title
if (content_width >= 100 || alert_icon[n] = 0)
	draw_label(string_limit(string_remove_newline(alert_title[n]), textw), textx, titley, fa_left, fa_top, setting_color_alerts_text, 1, setting_font_bold)

// Close
if (content_mouseon && (content_height > 60 || alert_button[n] = "") && draw_button_normal("alertclose", content_x + content_width - 20, content_y + 4, 16, 16, e_button.NO_TEXT, false, false, true, icons.CLOSE))
	alert_close(n)
	
draw_set_alpha(1)

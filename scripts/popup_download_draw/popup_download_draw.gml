/// popup_download_draw()

// Image
var img_h = 168
var y_prev = dy;

gpu_set_tex_filter(true)

var header = popup_download.header;
if(sprite_exists(header) && header != null)
	draw_image(header, 0, dx, dy, 420 / sprite_get_width(header), 168 / sprite_get_height(header))
	
gpu_set_tex_filter(false)

dy += img_h + 8

var hh = dh - (img_h + 8) - 48
dy += 8


var up_to_date;
up_to_date = ds_list_empty(content_list)

// Change log label
if(up_to_date)
	draw_label(text_get("downloaduptodate") + " (Minecraft " +  setting_minecraft_version + ")", dx + (dw/2), dy, fa_center, fa_middle, setting_color_text, 1, setting_font_bold)
else
	draw_label(text_get("downloadchangelog") + ": ", dx, dy, fa_left, fa_middle, setting_color_text, 1, setting_font_bold)
dy += 12

// Index through additions log
var scroll = popup_download.changelog_scroll
var logx = dx + 8;
var logy = dy + 12 + (-scroll.value);
var max_y = dy + hh

scroll.snap_value = 17

// Change popup height
popup_download.height = (600 - (16*17)) + ((min(16, ds_list_size(content_list))) * 17)

var amount = 0;

for(var l = 0; l < ds_list_size(content_list); l++)
{
	if(logy - 5 < dy || logy + 5 > max_y || amount >= 16)
	{
		logy += 17
		continue
	}	
	
	var line = content_list[|l]
	
	draw_label(line, logx, logy, fa_left, fa_middle)
	
	logy += 17
	amount++
}

if(scroll.needed)
	draw_box(dx + dw - 30, dy, 30, hh, false, c_black, 0.05)
	
scrollbar_draw(scroll, e_scroll.VERTICAL, dx + dw - 30, dy, hh, (ds_list_size(content_list) * 17) + 17, setting_color_buttons, setting_color_buttons_pressed, setting_color_background)

if(!up_to_date)
{
	dw = 100
	dh = 32
	dx = content_x + content_width / 2 - dw - 4
	dy = content_y + content_height - 32
	// Continue
	
	draw_button_normal("downloaddownload", dx, dy, dw, 32)
		// Start downloading process here

	// Cancel
	dx = content_x + content_width / 2 + 4
	if(draw_button_normal("downloadcancel", dx, dy, dw, 32))
		popup_switch(popup_startup)
}
else
{
	// Back
	dw = 100
	dh = 32
	dx = content_x + (content_width / 2) - (dw/2)
	dy = content_y + content_height - 32
	
	if(draw_button_normal("downloadback", dx, dy, dw, 32))
		if(popup_switch_from = null)
			popup_close()
		else
			popup_switch(popup_switch_from)
}

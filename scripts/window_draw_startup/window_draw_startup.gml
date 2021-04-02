/// window_draw_startup()

content_x = 0
content_y = 0
content_width = window_width
content_height = window_height
content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon

// Draw background
draw_clear_alpha(c_level_middle, 1)
draw_box(0, 0, window_width, 192, false, c_overlay, a_overlay)

var pattern = (setting_theme = theme_light ? 0 : 1);
draw_image(spr_startup_left, pattern, 0, 0)
draw_image(spr_startup_right, pattern, window_width, 0)

// Logo
draw_sprite(spr_logo, 0, window_width / 2, 96)

// Version
var trial = (trial_version ? " " + text_get("startuptrial") : "");
draw_button_text(text_get("startupversion", mineimator_version_full + trial), (window_width / 2) + 259, 130, popup_switch, popup_about)

dy = 240
dw = min(window_width - 48, 1008)

// No recent projects text
if (ds_list_size(recent_list) = 0)
{
	draw_label(text_get("recentnone"), window_width / 2, dy, fa_center, fa_middle, c_text_secondary, a_text_secondary, font_body_big)
	dy += 48
}

// Draw buttons
draw_set_font(font_button)

var newprojectwidth, browsewidth, centerx;
newprojectwidth = string_width(text_get("startupnewproject")) + button_icon_padding
browsewidth = string_width(text_get("startupbrowse")) + button_icon_padding
centerx = round((window_width / 2) - ((browsewidth + newprojectwidth) / 2))

if (ds_list_size(recent_list) > 0)
	dx = (window_width / 2) + (dw / 2)
else
	dx = centerx + (browsewidth + 24 + newprojectwidth)

// New project
dx -= newprojectwidth
if (draw_button_label("startupnewproject", dx, dy, null, icons.FILE))
{
	popup_newproject_clear()
	popup_switch(popup_newproject)
}

if (recent_list_amount > 0)
	dx -= 12 + browsewidth
else
	dx = centerx

// Browse
if (draw_button_label("startupbrowse", dx, dy, null, icons.FOLDER, e_button.PRIMARY))
{
	if (project_load())
		window_state = ""
}

// List style
if (recent_list_amount > 0)
{
	if (draw_button_icon("startuprecentdisplay", dx - 24 - 8, dy + 4, 24, 24, false, recent_display_mode = "grid" ? icons.VIEW_LIST : icons.VIEW_GRID, null, false, recent_display_mode = "grid" ? "tooltipviewlist" : "tooltipviewgrid"))
	{
		if (recent_display_mode = "list")
			recent_display_mode = "grid"
		else
			recent_display_mode = "list"
	}
}

// Show recent models
if (recent_list_amount > 0)
{
	// Recent model grid/list button
	dx -= (12 + 28)
	
	dx = (window_width / 2) - (dw / 2)
	
	draw_set_font(font_heading)
	
	// Recent models label
	draw_label(text_get("startuprecentprojects"), dx, dy + 16, fa_left, fa_middle, c_accent, 1)
	
	var labelwid = string_width(text_get("startuprecentprojects"));
	
	if (draw_button_label("startupsortby", dx + labelwid + 16, dy, null, icons.SORT_DOWN, e_button.TERTIARY))
		menu_settings_set(dx + labelwid + 16, dy, "startupsortby", 32)
	
	if (settings_menu_name = "startupsortby" && settings_menu_ani_type != "hide")
		current_mcroani.value = true
	
	dy += 72
	
	var listheight;
	
	if (recent_display_mode = "list")
		listheight = 28 + min(window_height - dy, (min(ds_list_size(recent_list), 8) * 44))
	else
		listheight = min(window_height - dy, ceil(recent_list_amount / 4) * 256)
	
	tab_control(listheight)
	draw_recent(dx, dy, dw, listheight)
	tab_next()
}
else
{
	// Jonathan splash
	var midx, midy;
	midx = snap(window_width / 2, 2)
	midy = snap(192 + ((window_height - 192) / 1.75), 2)
	
	// Only draw splash if it fits well on screen
	if ((midy + (sprite_get_height(spr_jonathan_splash) / 1.75)) < (window_height - 50))
		draw_image(spr_jonathan_splash, 0, midx, midy)
}


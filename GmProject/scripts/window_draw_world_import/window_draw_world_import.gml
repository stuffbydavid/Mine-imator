/// @desc Draw the world import interface.

function window_draw_world_import()
{
	if (keyboard_check_pressed(vk_escape))
	{
		window_state = ""
		world_import_cancel()
		return
	}

	var spacing, hasselection;
	spacing = 12
	content_x = 0
	content_y = toolbar_size
	content_width = window_width
	content_height = 40
	
	dx = content_x + 12
	dy = content_y + 8
	dw = content_width
	dh = content_height
	
	draw_clear(c_level_bottom)
	
	// Get selection status
	var confirmx, confirmy, confirmw, confirmh;
	hasselection = world_import_has_selection()
	confirmh = 64
	
	if (hasselection)
	{
		draw_set_font(font_heading_big)
		confirmw = string_width(text_get("worldimportconfirm")) + 70
	}
	else
		confirmw = 0
	
	confirmx = window_width / 2 - confirmw / 2
	confirmy = window_height - 60 - confirmh - (setting_show_shortcuts_bar * 28)
	
	// Draw surface
	var surfacey, surfaceh;
	surfacey = content_y + content_height
	surfaceh = window_height - surfacey
	if (setting_show_shortcuts_bar)
		surfaceh -= 28
	
	world_import_surface = surface_require(world_import_surface, window_width, surfaceh)
	world_import_update_surface(0, surfacey, window_width, surfaceh, confirmx, confirmy, confirmw, confirmh)
	
	draw_set_color(c_ltgray)
	draw_rectangle(0, surfacey, window_width, surfacey + surfaceh, false)
	draw_surface(world_import_surface, 0, surfacey)
	
	// Draw world import toolbar
	draw_box(content_x, content_y, content_width, content_height, false, c_level_middle, 1)
	draw_divide(content_x, content_y + content_height, content_width)
	draw_gradient(content_x, content_y + content_height, content_width, shadow_size, c_black, shadow_alpha, shadow_alpha, 0, 0)
	
	content_mouseon = true
	
	// Cancel
	draw_set_font(font_button)
	dw = string_width(text_get("worldimportcancel")) + 24
	if (draw_button_label("worldimportcancel", dx, content_y + 4, null, null, e_button.SECONDARY, null, e_anchor.LEFT))
	{
		window_state = ""
		world_import_cancel()
	}
	
	dx += dw
	
	dx += 12
	draw_divide_vertical(dx, content_y + 6, content_height - 12)
	dx += 12
	
	// World
	dw = 256
	content_capwid = 50
	draw_button_menu("worldimportworld", e_menu.LIST, dx, dy, dw, 24, world_import_world_root, world_import_world_name, world_import_select_world, false, null, null, "", null, null, content_capwid)
	
	// Dimension
	dx += dw + spacing
	dw = 208
	content_capwid = 80
	draw_button_menu("worldimportdimension", e_menu.LIST, dx, dy, dw, 24, world_import_dimension, text_get("worldimport" + string_replace_all(world_import_dimension, "_", "")), world_import_select_dimension, false, null, null, "", null, null, content_capwid)
	
	dx += dw + 12
	
	// Buttons
	dw = 24
	spacing = 4
	
	if (draw_button_icon("worldimportbrowse", dx, dy, dw, dw, false, icons.FOLDER, null, false, "worldimportbrowsetip"))
	{
		var leveldat = file_dialog_open(text_get("worldimportbrowseworlds") + " (level.dat)|level.dat;", "", minecraft_java_directory_get() + "/saves", text_get("worldimportbrowsecaption"));
		if (file_exists_lib(leveldat))
			world_import_select_world(filename_dir(leveldat))
	}
	
	dx += dw + spacing
	var worldpicked = world_import_world_root != "";
	if (draw_button_icon("worldimportreload", dx, dy, dw, dw, false, icons.REFRESH, null, !worldpicked, "worldimportreloadtip"))
		world_import_select_world(world_import_world_root, world_import_dimension)
	
	dx += dw + 12
	draw_divide_vertical(dx, content_y + 6, content_height - 12)
	
	dx += 12
	if (draw_button_icon("worldimportgotoplayer", dx, dy, dw, dw, false, icons.PATH_POINT, null, !worldpicked, "worldimportgotoplayertip"))
		world_import_go_to_player()
	dx += 24
	
	if (draw_button_icon("worldimportposition", dx, dy, 16, 24, settings_menu_name = "worldimportposition", icons.CHEVRON_DOWN_TINY, null, !worldpicked))
	{
		menu_settings_set(dx, dy, "worldimportposition", 24)
		settings_menu_script = world_import_go_to_position_draw
	}
	if (settings_menu_name = "worldimportposition" && settings_menu_ani_type != "hide")
		current_microani.active.value = true
	
	dx += 16 + spacing
	if (draw_button_icon("worldimportsettings", dx, dy, dw, dw, false, icons.SETTINGS, null, false, "worldimportsettingstip"))
		popup_show(world_import_settings_popup)
	
	dx += dw
	
	dx += 12
	draw_divide_vertical(dx, content_y + 6, content_height - 12)
	dx += 12
	
	// Selection
	dy = content_y + 4
	draw_set_font(font_label)
	spacing = 12
	dw = string_width(text_get("worldimportselection") + ":")
	draw_label(text_get("worldimportselection") + ":", dx, content_y + content_height / 2, fa_left, fa_middle, c_text_secondary, a_text_secondary)
	
	dx += dw + spacing
	draw_set_font(font_button)
	dw = string_width(text_get("worldimportselectionsmall")) + 24
	if (draw_button_label("worldimportselectionsmall", dx, dy, null, null, e_button.SECONDARY, null, e_anchor.LEFT, !worldpicked))
		world_import_set_selection("small")
	
	dx += dw + spacing
	dw = string_width(text_get("worldimportselectionmedium")) + 24
	if (draw_button_label("worldimportselectionmedium", dx, dy, null, null, e_button.SECONDARY, null, e_anchor.LEFT, !worldpicked))
		world_import_set_selection("medium")
	
	dx += dw + spacing
	dw = string_width(text_get("worldimportselectionlarge")) + 24
	if (draw_button_label("worldimportselectionlarge", dx, dy, null, null, e_button.SECONDARY, null, e_anchor.LEFT, !worldpicked))
		world_import_set_selection("large")
	
	if (world_import_has_selection())
	{
		dx += dw + 20
		var size = world_import_get_selection_size();
		draw_label(text_get("worldimportselectionsize", size[X], size[Y], size[Z]), dx, content_y + content_height / 2, fa_left, fa_middle, c_text_main, a_text_main, font_value)
	}
	
	// Draw confirm button
	content_x = 0
	content_y = 0
	content_width = window_width
	content_height = window_height
	
	if (hasselection)
		if (draw_button_label("worldimportconfirm", confirmx, confirmy, confirmw, null, e_button.BIG, null, e_anchor.LEFT))
			world_import_confirm()
	
	// Filter enabled
	if (worldpicked && setting_world_import_filter_enabled && ds_list_size(setting_world_import_filter_list) > 0)
	{
		var filtertext = text_get("worldimportfilteractive");
		draw_label(filtertext, confirmx + confirmw / 2 + 1, confirmy + 80 + 1, fa_center, fa_top, c_black, 1, font_heading_big)
		draw_label(filtertext, confirmx + confirmw / 2, confirmy + 80, fa_center, fa_top, c_warning, 1, font_heading_big)
	}
}

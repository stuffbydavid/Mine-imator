/// Initialize world import variables

function app_startup_interface_world_import()
{ 
	world_import_settings_popup = new_popup("worldsettings", popup_worldsettings_draw, 600, 532, true, false, false, true, world_import_apply_settings)
	world_import_surface = null
	world_import_add_tl = false
	world_import_temp = null
	
	world_import_settings_block_select = null
	world_import_settings_block_list = new_obj(obj_sortlist)
	world_import_settings_block_list.can_deselect = true
	world_import_settings_block_list.script = action_world_import_settings_block_select
	sortlist_column_add(world_import_settings_block_list, "blockfilter", 0)
	for (var b = 0; b < ds_list_size(mc_assets.block_list); b++)
		if (ds_list_find_index(setting_world_import_filter_list, b) < 0) // Not filtered
			sortlist_add(world_import_settings_block_list, b)
		
	world_import_settings_filter_select = null
	world_import_settings_filter_list = new_obj(obj_sortlist)
	world_import_settings_filter_list.can_deselect = true
	world_import_settings_filter_list.script = action_world_import_settings_filter_select
	sortlist_column_add(world_import_settings_filter_list, "blockfilter", 0)
	for (var i = 0; i < ds_list_size(setting_world_import_filter_list); i++) // Add indices from filter list
		sortlist_add(world_import_settings_filter_list, setting_world_import_filter_list[|i])
	
	world_import_startup()
}

/// CppSeparate void world_import_startup()
function world_import_startup()
{
}

/// Start "Import from world" mode.
function world_import_begin(addtl = true, temp = null)
{
	window_state = "world_import"
	popup_ani_type = ""
	world_import_world_root = ""
	world_import_world_name = text_get("worldimportnoworld")
	world_import_dimension = "overworld"
	world_import_add_tl = addtl
	world_import_temp = temp
}

/// CppSeparate void world_import_select_world(ScopeAny, StringType, StringType dim = "", BoolType update = false)
/// Selects a world from the given folder. If no dimension is selected the current of the player is selected.
function world_import_select_world(root, dimension = "", update = false)
{
	app.world_import_world_root = root
	app.world_import_world_name = root
	app.world_import_dimension = dimension = "" ? "overworld" : dimension
}

/// Selects a dimension from the given name.
function world_import_select_dimension(name)
{
	world_import_select_world(app.world_import_world_root, name)
}

/// CppSeparate BoolType world_import_has_dimension(StringType)
/// Returns whether a dimension is available in the current world.
function world_import_has_dimension(name)
{
	return true
}

/// CppSeparate BoolType world_import_has_selection()
/// Returns whether a selection has been created.
function world_import_has_selection()
{
	return true
}

/// CppSeparate VecType world_import_get_selection_size()
/// Returns the selection size.
function world_import_get_selection_size()
{
	return vec3(1, 2, 3)
}

/// CppSeparate void world_import_apply_settings(ScopeAny)
/// Applies the world settings after closing the popup.
function world_import_apply_settings()
{
	show_debug_message("Apply settings")
}

/// CppSeparate void world_import_go_to_player()
/// Jumps to the player or start position.
function world_import_go_to_player()
{
	show_debug_message("Go to player")
}

/// CppSeparate void world_import_set_selection(StringType size)
function world_import_set_selection(size)
{
	show_debug_message("Set selection to " + size)
}

/// CppSeparate StringType world_import_get_saves_dir()
function world_import_get_saves_dir()
{
	return "";
}

/// CppSeparate void world_import_confirm()
/// Confirms the selection in the world.
function world_import_confirm()
{
	show_debug_message("confirm")
}

function world_import_confirm_done()
{
	window_state = ""
}

/// CppSeparate void world_import_cancel()
/// Cancels the world import operation.
function world_import_cancel()
{
	show_debug_message("cancel")
	window_state = ""
}

/// CppSeparate void world_import_update_surface(IntType, IntType, IntType, IntType, IntType, IntType, IntType, IntType)
/// Update the world preview surface drawn at position x,y.
function world_import_update_surface(xx, yy, width, height, confirmx, confirmy, confirmwidth, confirmheight)
{
	surface_set_target(world_import_surface)
	draw_clear(0)
	surface_reset_target()
}

/// CppSeparate void world_import_world_menu_init()
/// Add the worlds available on the system to the menu list.
function world_import_world_menu_init()
{
	menu_add_item("Some World 1", "Some World 1")
	menu_add_item("Some World 2", "Some World 2")
	menu_add_item("Some World 3", "Some World 3")
	menu_add_item("Some World 4", "Some World 4")
}

/// Add the dimensions available on the system to the menu list.
function world_import_dimension_menu_init()
{
	menu_add_item("overworld", text_get("worldimportoverworld"))
	if (world_import_has_dimension("nether"))
		menu_add_item("nether", text_get("worldimportnether"))
	if (world_import_has_dimension("end"))
		menu_add_item("end", text_get("worldimportend"))
}

/// Draw the world import interface.
function window_draw_world_import()
{
	var spacing, capwid, hasselection, surfacey;
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
	confirmy = window_height - 40 - confirmh - (setting_show_shortcuts_bar * 28)
	
	// Draw surface
	surfacey = content_y + content_height
	world_import_surface = surface_require(world_import_surface, window_width, window_height - surfacey)
	world_import_update_surface(0, surfacey, window_width, window_height - surfacey, confirmx, confirmy, confirmw, confirmh)
	draw_surface(world_import_surface, 0, surfacey)
	
	// Draw world import toolbar
	draw_box(content_x, content_y, content_width, content_height, false, c_level_middle, 1)
	draw_divide(content_x, content_y + content_height, content_width)
	draw_gradient(content_x, content_y + content_height, content_width, shadow_size, c_black, shadow_alpha, shadow_alpha, 0, 0)
	
	content_mouseon = true
	
	// World
	dw = 256
	capwid = 50
	draw_button_menu("worldimportworld", e_menu.LIST, dx, dy, dw, 24, world_import_world_root, world_import_world_name, world_import_select_world, false, null, null, "", null, null, capwid)
	
	// Dimension
	dx += dw + spacing
	dw = 208
	capwid = 80
	draw_button_menu("worldimportdimension", e_menu.LIST, dx, dy, dw, 24, world_import_dimension, text_get("worldimport" + world_import_dimension), world_import_select_dimension, false, null, null, "", null, null, capwid)
	
	dx += dw
	
	dx += 12
	draw_divide_vertical(dx, content_y + 6, content_height - 12)
	dx += 12
	
	// Buttons
	dw = 24
	spacing = 4
	
	if (draw_button_icon("worldimportbrowse", dx, dy, dw, dw, false, icons.FOLDER, null, false, "worldimportbrowsetip"))
	{
		var leveldat = file_dialog_open(text_get("worldimportbrowseworlds") + " (level.dat)|level.dat;", "", world_import_get_saves_dir(), text_get("worldimportbrowsecaption"))
		if (file_exists_lib(leveldat))
			world_import_select_world(filename_dir(leveldat))
	}
	
	dx += dw + spacing
	if (draw_button_icon("worldimportsettings", dx, dy, dw, dw, false, icons.SETTINGS, null, false, "worldimportsettingstip"))
		popup_show(world_import_settings_popup)
	
	dx += dw + spacing
	
	var worldpicked = world_import_world_root != "";
	if (draw_button_icon("worldimportreload", dx, dy, dw, dw, false, icons.REFRESH, null, !worldpicked, "worldimportreloadtip"))
		world_import_select_world(world_import_world_root, world_import_dimension)
	
	dx += dw + spacing
	if (draw_button_icon("worldimportgotoplayer", dx, dy, dw, dw, false, icons.PATH_POINT, null, !worldpicked, "worldimportgotoplayertip"))
		world_import_go_to_player()
	
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
		draw_label(text_get("worldimportblocks", size[X], size[Y], size[Z]), dx, content_y + content_height / 2, fa_left, fa_middle, c_text_main, a_text_main, font_value)
	}
	
	// Draw confirm button
	content_x = 0
	content_y = 0
	content_width = window_width
	content_height = window_height
	if (hasselection)
		if (draw_button_label("worldimportconfirm", confirmx, confirmy, confirmw, null, e_button.BIG, null, e_anchor.LEFT))
			world_import_confirm()
}

function action_world_import_settings_filter_enabled(value)
{
	setting_world_import_filter_enabled = value
}

function action_world_import_settings_filter_mode(value)
{
	setting_world_import_filter_mode = value
}

function action_world_import_settings_block_select(value)
{
	world_import_settings_block_select = value
}

function action_world_import_settings_filter_select(value)
{
	world_import_settings_filter_select = value
}

function action_world_import_settings_unload_regions(value)
{
	setting_world_import_unload_regions = value
}

function popup_worldsettings_draw()
{
	content_mouseon = true
	dw = dw/2
	
	// Unload far away regions
	tab_control_switch()
	draw_switch("worldsettingsunloadregions", dx, dy, setting_world_import_unload_regions, action_world_import_settings_unload_regions, "worldsettingsunloadregionstip")
	tab_next()
	
	// Filter settings
	tab_control_switch()
	draw_switch("worldsettingsfilterenabled", dx, dy, setting_world_import_filter_enabled, action_world_import_settings_filter_enabled)
	tab_next()
	
	if (setting_world_import_filter_enabled)
	{
		tab_control_togglebutton()
		togglebutton_add("worldsettingsfilterremove", null, 0, setting_world_import_filter_mode = 0, action_world_import_settings_filter_mode)
		togglebutton_add("worldsettingsfilterkeep", null, 1, setting_world_import_filter_mode = 1, action_world_import_settings_filter_mode)
		draw_togglebutton("worldsettingsfiltermode", dx, dy)
		tab_next()
		
		var listdw = content_width - 24;
		
		dy += 8
		
		tab_control_sortlist(10)
		sortlist_draw(world_import_settings_block_list, dx, dy, listdw / 2 - 20, tab_control_h, world_import_settings_block_select, false, text_get("worldsettingsfilterblocks"))
		sortlist_draw(world_import_settings_filter_list, dx + listdw / 2 + 20, dy, listdw / 2 - 20, tab_control_h, world_import_settings_filter_select, false, text_get("worldsettingsfilterfiltered"))
		
		if (draw_button_icon("worldsettingsfilterright", dx + listdw / 2 - 12, dy + (tab_control_h/2) - 16, 24, 24, false, icons.CHEVRON_RIGHT_TINY, null, world_import_settings_block_select = null))
		{
			sortlist_add(world_import_settings_filter_list, world_import_settings_block_select)
			sortlist_remove(world_import_settings_block_list, world_import_settings_block_select)
			sortlist_update(world_import_settings_filter_list)
			sortlist_update(world_import_settings_block_list)
			ds_list_add(setting_world_import_filter_list, world_import_settings_block_select)
			world_import_settings_block_select = null
		}
		
		if (draw_button_icon("worldsettingsfilterleft", dx + listdw / 2 - 12, dy + (tab_control_h/2) + 16, 24, 24, false, icons.CHEVRON_LEFT_TINY, null, world_import_settings_filter_select = null))
		{
			var blocklist = world_import_settings_block_list.list;
			var index;
			for (index = 0; index < ds_list_size(blocklist); index++)
				if (blocklist[|index] > world_import_settings_filter_select)
					break;
			
			sortlist_add(world_import_settings_block_list, world_import_settings_filter_select, index)
			sortlist_remove(world_import_settings_filter_list, world_import_settings_filter_select)
			sortlist_update(world_import_settings_block_list)
			sortlist_update(world_import_settings_filter_list)
			ds_list_delete_value(setting_world_import_filter_list, world_import_settings_filter_select)
			world_import_settings_filter_select = null
		}
		
		tab_next()
		
		dw = content_width - 24
		dy += 8
		draw_tooltip_label("worldsettingsfilterhelp", icons.INFO, e_toast.INFO)
	}
}
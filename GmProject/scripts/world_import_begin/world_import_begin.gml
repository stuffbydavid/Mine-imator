/// world_import_begin(addtl, temp)
/// Start "Import from world" mode.

function world_import_begin(addtl = true, temp = null)
{
	window_state = "world_import"
	window_busy = ""
	window_focus = ""
	window_scroll_focus = ""
	popup_ani_type = ""
	world_import_world_root = ""
	world_import_world_name = text_get("worldimportnoworld")
	world_import_dimension = "overworld"
	world_import_add_tl = addtl
	world_import_temp = temp
}
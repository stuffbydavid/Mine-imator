/// action_lib_item_sheet(sheet)
/// @arg sheet

var sheet;

if (history_undo)
	sheet = history_data.oldval
else if (history_redo)
	sheet = history_data.newval
else
{
	sheet = argument0
	history_set_var(action_lib_item_sheet, temp_edit.item_sheet, sheet, false)
}

with (temp_edit)
{
	item_sheet = sheet
	temp_update_item()
}

lib_preview.update = true

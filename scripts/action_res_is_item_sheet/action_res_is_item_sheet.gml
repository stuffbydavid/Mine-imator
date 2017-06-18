/// action_res_is_item_sheet(sheet)
/// @arg sheet

var sheet;

if (history_undo)
	sheet = history_data.oldval
else if (history_redo)
	sheet = history_data.newval
else
{
	sheet = argument0
	history_set_var(action_res_is_item_sheet, res_edit.is_item_sheet, sheet, false)
}

with (res_edit)
	is_item_sheet = sheet

lib_preview.update = true

/// action_res_material_format(format)
/// @arg format

function action_res_material_format(format)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_material_format, res_edit.material_format, format, true)
	
	with (res_edit)
		material_format = format
}
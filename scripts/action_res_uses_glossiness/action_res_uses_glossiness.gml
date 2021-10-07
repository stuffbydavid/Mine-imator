/// action_res_uses_glossiness(value)
/// @arg value

function action_res_uses_glossiness(val)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_uses_glossiness, res_edit.material_uses_glossiness, val, true)
	
	with (res_edit)
		material_uses_glossiness = val
}

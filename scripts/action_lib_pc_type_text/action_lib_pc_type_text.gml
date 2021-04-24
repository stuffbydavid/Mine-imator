/// action_lib_pc_type_text(text)
/// @arg text

function action_lib_pc_type_text(text)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_text, ptype_edit.text, text, true)
	
	ptype_edit.text = text
}

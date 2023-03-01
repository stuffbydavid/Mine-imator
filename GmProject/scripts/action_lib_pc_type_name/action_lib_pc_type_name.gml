/// action_lib_pc_type_name(name)
/// @arg name

function action_lib_pc_type_name(name)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_name, ptype_edit.name, name, true)
	
	ptype_edit.name = name
}

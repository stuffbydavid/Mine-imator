/// action_lib_pc_type_temp(template)
/// @arg template

var temp;

if (history_undo)
	temp = iid_find(history_data.oldval)
else if (history_redo)
	temp = iid_find(history_data.newval)
else
{
	temp = argument0
	history_set_var(action_lib_pc_type_temp, iid_get(ptype_edit.temp), iid_get(temp), false)
}

ptype_edit.temp = temp

tab_template_editor_particles_preview_restart()

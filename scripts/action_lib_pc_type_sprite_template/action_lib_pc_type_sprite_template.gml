/// action_lib_pc_type_sprite_template(template)
/// @arg template

var temp;

if (history_undo)
	temp = history_data.old_value
else if (history_redo)
	temp = history_data.new_value
else
{
	temp = argument0
	history_set_var(action_lib_pc_type_sprite_template, ptype_edit.sprite_template, temp, false)
}

ptype_edit.sprite_template = temp

with (ptype_edit)
	ptype_update_sprite_vbuffers()

tab_template_editor_particles_preview_restart()

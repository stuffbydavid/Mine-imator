/// action_lib_pc_type_sprite_animation_onend(onend)
/// @arg onend

var onend;

if (history_undo)
	onend = history_data.old_value
else if (history_redo)
	onend = history_data.new_value
else
{
	onend = argument0
	history_set_var(action_lib_pc_type_sprite_animation_onend, ptype_edit.sprite_animation_onend, onend, false)
}

ptype_edit.sprite_animation_onend = onend
tab_template_editor_particles_preview_restart()

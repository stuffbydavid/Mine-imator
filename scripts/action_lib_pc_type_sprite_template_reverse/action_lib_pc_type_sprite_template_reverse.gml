/// action_lib_pc_type_sprite_template_reverse(reverse)
/// @arg reverse

var reverse;

if (history_undo)
	reverse = history_data.old_value
else if (history_redo)
	reverse = history_data.new_value
else
{
	reverse = argument0
	history_set_var(action_lib_pc_type_sprite_template_reverse, ptype_edit.sprite_template_reverse, reverse, true)
}

with (ptype_edit)
{
	sprite_template_reverse = reverse
	ptype_update_sprite_vbuffers()
}

tab_template_editor_particles_preview_restart()

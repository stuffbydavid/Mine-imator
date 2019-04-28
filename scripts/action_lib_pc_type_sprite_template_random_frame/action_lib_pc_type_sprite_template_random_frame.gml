/// action_lib_pc_type_sprite_template_random_frame(random_frame)
/// @arg random_frame

var random_frame;

if (history_undo)
	random_frame = history_data.old_value
else if (history_redo)
	random_frame = history_data.new_value
else
{
	random_frame = argument0
	history_set_var(action_lib_pc_type_sprite_template_random_frame, ptype_edit.sprite_template_random_frame, random_frame, true)
}

with (ptype_edit)
{
	sprite_template_random_frame = random_frame
	ptype_update_sprite_vbuffers()
}

tab_template_editor_particles_preview_restart()

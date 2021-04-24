/// action_lib_pc_type_sprite_animation_speed(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_sprite_animation_speed(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_animation_speed, ptype_edit.sprite_animation_speed, ptype_edit.sprite_animation_speed * add + val, true)
	
	ptype_edit.sprite_animation_speed = ptype_edit.sprite_animation_speed * add + val
	tab_template_editor_particles_preview_restart()
}

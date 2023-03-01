/// action_lib_pc_type_sprite_animation_speed_random_min(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_sprite_animation_speed_random_min(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_min * add + val, true)
	
	ptype_edit.sprite_animation_speed_random_min = ptype_edit.sprite_animation_speed_random_min * add + val
	tab_template_editor_particles_preview_restart()
}

/// action_lib_pc_type_sprite_animation_speed_random_min(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.oldval
else if (history_redo)
	val = history_data.newval
else
{
	val = argument0
	add = argument1
	history_set_var(action_lib_pc_type_sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_min, ptype_edit.sprite_animation_speed_random_min * add + val, true)
}

ptype_edit.sprite_animation_speed_random_min = ptype_edit.sprite_animation_speed_random_min * add + val
tab_template_editor_particles_preview_restart()

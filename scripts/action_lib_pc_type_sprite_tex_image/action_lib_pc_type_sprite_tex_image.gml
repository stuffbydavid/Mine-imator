/// action_lib_pc_type_sprite_tex_image(image)
/// @arg image

var image;

if (history_undo)
	image = history_data.old_value
else if (history_redo)
	image = history_data.new_value
else
{
	image = argument0
	history_set_var(action_lib_pc_type_sprite_tex_image, ptype_edit.sprite_tex_image, image, false)
}
	
with (ptype_edit)
{
	sprite_tex_image = image
	ptype_update_sprite_vbuffer_amount()
}

tab_template_editor_particles_preview_restart()

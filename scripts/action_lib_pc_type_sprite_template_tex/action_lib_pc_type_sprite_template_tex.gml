/// action_lib_pc_type_sprite_template_tex(resource)
/// @arg resource

var res, fn;
fn = ""

if (history_undo)
	res = history_undo_res()
else if (history_redo)
	res = history_redo_res()
else
{
	res = argument0
	if (res = e_option.BROWSE)
	{
		fn = file_dialog_open_pack()
		
		if (!file_exists_lib(fn))
			return 0
		
		res = new_res(fn, e_res_type.PACK)
		with (res)
			res_load()
	}
	history_set_res(action_lib_pc_type_sprite_template_tex, fn, ptype_edit.sprite_template_tex, res)
}

with (ptype_edit)
{
	sprite_template_tex.count--
	sprite_template_tex = res
	sprite_template_tex.count++
	ptype_update_sprite_vbuffers()
}

tab_template_editor_particles_preview_restart()

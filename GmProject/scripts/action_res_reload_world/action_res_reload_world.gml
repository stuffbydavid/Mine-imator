/// @desc Reloads the original world selection and replaces its schematic snapshot.

function action_res_reload_world()
{
	if (res_edit = null || res_edit.type != e_res_type.FROM_WORLD)
		return 0

	res_edit.world_reload = true
	
	action_res_reload()
}

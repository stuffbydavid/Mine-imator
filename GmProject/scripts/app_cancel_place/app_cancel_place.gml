/// app_cancel_place()

function app_cancel_place()
{
	if (place_tl.parent != place_tl_parent)
	{
		with (place_tl)
			tl_set_parent(app.place_tl_parent, app.place_tl_parent_index, true)
		tl_update_list()
	}

	with (place_history)
	{
		tl_value_set_vec3(e_value.POS_X, vec3(0), true)
		tl_value_set_vec3(e_value.ROT_X, vec3(0), true)
		tl_value_set_vec3(e_value.SCA_X, vec3(1), true)
	}

	with (place_tl)
	{
		tl_value_set_vec3(e_value.POS_X, vec3(0))
		tl_value_set_vec3(e_value.POS_X, vec3(0), true)
		tl_value_set_vec3(e_value.ROT_X, vec3(0))
		tl_value_set_vec3(e_value.ROT_X, vec3(0), true)
		tl_value_set_vec3(e_value.SCA_X, vec3(1))
		tl_value_set_vec3(e_value.SCA_X, vec3(1), true)
		update_matrix = true
	}

	tl_update_matrix()
	render_samples = -1
	app_stop_place()
}
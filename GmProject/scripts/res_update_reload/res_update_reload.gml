/// @desc Update templates and timelines after reloading a resource.
/// @arg [historyobject]
/// @arg [clearparts]

function res_update_reload(hobj = null, clearparts = true)
{
	with (obj_template)
	{
		if (scenery = res_edit)
			temp_set_scenery(scenery, !history_undo, hobj, clearparts)

		else if (item_tex = res_edit)
			render_generate_item()

		else if (model = res_edit)
		{
			temp_update_model()
			temp_update_model_timeline_tree(hobj)
			temp_update_model_shape()
			temp_update_display_name()
		}
		else if (model_tex = res_edit)
			temp_update_model_shape()
	}

	if (history_undo)
	{
		with (history_data)
			history_restore_parts()

		if (!clearparts)
			with (obj_timeline)
				if (scenery_animate && temp != null && temp.scenery = res_edit && temp.scenery.ready)
					tl_animate_scenery()
	}

	tl_update_length()
	tl_update_list()
	tl_update_matrix()

	app_update_tl_edit()
	project_update_counts()

	lib_preview.update = true
	res_preview.update = true
	res_preview.reset_view = true
}

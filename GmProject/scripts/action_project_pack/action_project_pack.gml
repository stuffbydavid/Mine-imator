/// action_project_pack(res, [record])

function action_project_pack(res, record = true)
{
	var fn;
	fn = ""

	if (record)
	{
		if (history_undo)
			res = history_undo_res()
		else if (history_redo)
			res = history_redo_res()
		else
		{
			if (res = e_option.BROWSE)
			{
				fn = file_dialog_open_pack()
				if (!file_exists_lib(fn))
					return 0

				action_res_pack_load(fn, false, true)
				return 0
			}

			if (is_string(res))
			{
				if (res = "")
					res = mc_res
				else
				{
					var pack = null;
					with (obj_resource)
						if (type = e_res_type.PACK && filename = res)
						{
							pack = id
							break
						}

					if (pack = null)
					{
						fn = packs_directory_get() + res
						if (!file_exists_lib(fn))
							return 0
						action_res_pack_load(fn, false, true)
						return 0
					}
					res = pack
				}
			}

			if (project_pack != res)
				history_set_res(action_project_pack, fn, project_pack, res)
		}
	}

	project_pack = res
	project_update_counts()
	
	if (!res.ready)
		return 0

	background_ground_update_texture()
	background_ground_update_texture_material()
	background_ground_update_texture_normal()
	background_sky_update_clouds()
	render_update_item()
	render_update_text()
	
	with (obj_template)
	{
		/*if (type = e_temp_type.CHARACTER || type = e_temp_type.EQUIPMENT || type = e_temp_type.SPECIAL_BLOCK || type = e_temp_type.MODEL_PART)
		{
			if (model_tex = null)
				model_tex = project_pack_res
			if (model_tex_material = null)
				model_tex_material = project_pack_res
			if (model_tex_normal = null)
				model_tex_normal = project_pack_res
			temp_update_model()
		*/
		temp_update_model_shape()
		temp_update_armor(id)
	}
	
	with (obj_timeline)
		render_update_tl_resource()
		
	with (obj_particle_type)
		ptype_update_sprite_vbuffers()
}

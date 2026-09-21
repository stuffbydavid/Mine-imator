/// app_start_place(build, [tl, spawn])

function app_start_place(build, tl = null, spawn = false)
{
	place_busy = build ? "build" : "place"
	window_busy = place_busy
	
	place_build = build
	place_tl = tl
	place_history = build ? null : history[0]
	place_spawn = build || spawn
	
	place_pos = null
	place_rot = vec3(0)
	place_sca = vec3(1)
		
	place_view_pos = null
	place_view_air = false
	place_view_color = 0
	place_view_normal = vec3(0)
	
	place_target_tl = null
	place_target_tl_part_of = null
	
	place_content_mouseon = null
	
	place_view_second_show = build && view_second.show && !window_exists(e_window.VIEW_SECOND)
	if (place_view_second_show)
		view_second.show = false

	view_main.update_place_surfaces = true
	view_main.place_depth_value = 0.995
	view_second.update_place_surfaces = true
	view_second.place_depth_value = 0.995
	
	if (build)
	{
		// Copy workbench settings into builder
		with (build_settings)
		{
			type = (app.build_type = e_tl_type.SPECIAL_BLOCK) ? e_temp_type.SPECIAL_BLOCK : e_temp_type.BLOCK
			if (type = e_temp_type.BLOCK)
			{
				block_name = app.bench_settings.block_name
				block_state = array_copy_1d(app.bench_settings.block_state)
				block_tex = project_pack_res
				block_tex_material = project_pack_res
				block_tex_normal = project_pack_res
				temp_update_rot_point()
			}
			else
			{
				model_name = app.bench_settings.model_name
				model_state = array_copy_1d(app.bench_settings.model_state)
				model_tex = project_pack_res
				model_tex_material = project_pack_res
				model_tex_normal = project_pack_res
				temp_update_model()
				temp_update_model_shape()
			}
		}
		
		// Find block selection
		var special, buildname;
		special = (build_type = e_tl_type.SPECIAL_BLOCK)
		buildname = special ? build_settings.model_name : build_settings.block_name
		
		build_mode.build_selected = null
		for (var b = 0; b < ds_list_size(build_mode.build_list.list); b++)
		{
			var value = build_mode.build_list.list[|b];
			if (value[0] = special && value[1] = buildname)
			{
				build_mode.build_selected = value
				break
			}
		}
		
		if (build_mode.build_selected != null && ds_list_find_index(build_mode.build_list.display_list, build_mode.build_selected) < 0)
		{
			build_mode.build_list.search_tbx.text = ""
			build_mode.build_list.search = false
			sortlist_update(build_mode.build_list)
		}
		build_mode.build_list.center_on_draw = (build_mode.build_selected != null)
		
		place_tl_parent = app
		place_tl_parent_index = -1
		
		if (tl_edit_amount > 0)
			action_tl_deselect_all()
		else
			app_update_tl_edit_tabs()
		
		obj_edit = build_settings
		
		tab_close(object_editor)
		tab_show(build_mode, true)
	}
	else
	{
		place_tl_render = true
		place_tl_parent = tl.parent
		place_tl_parent_index = ds_list_find_index(tl.parent.tree_list, tl)
		
		with (tl)
		{
			app.place_sca = tl_value_get_vec3(e_value.SCA_X, true)
			tl_mark_placed(true)
		}
	}
}

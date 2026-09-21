/// action_bench_create([edit, build])
/// @arg [edit]
/// @arg [build]

function action_bench_create(edit = false, build = false)
{
	var tab, editobj;
	tab = (history_undo || history_redo) ? history_data.bench_tab : bench_tab
	if (place_build && !history_undo && !history_redo)
		tab = (build_type = e_tl_type.SPECIAL_BLOCK) ? e_bench.SPECIAL_BLOCK : e_bench.BLOCK
	editobj = null
	
	if (tab = e_bench.SOUND)
		return action_bench_sound_create()
	
	if (tab = e_bench.PROJECT)
	{
		var temp = bench_settings.project_selected;
		if (temp != null && instance_exists(temp) && temp.object_index = obj_template)
		{
			if (edit)
			{
				with (temp)
					temp_select_edit()
			}
			else
			{
				temp_edit = temp
				action_lib_animate(true)
			}
		}
		return 0
	}

	if (place_build && (history_undo || history_redo))
	{
		if (place_target_tl_part_of != null && instance_exists(place_target_tl_part_of))
			with (place_target_tl_part_of)
				tl_mark_place_target(false)
		place_target_tl = null
		place_target_tl_part_of = null
	}

	if (history_undo)
	{
		with (history_data)
		{
			for (var s = 0; s < spawn_amount; s++)
			{
				with (save_id_find(spawn_save_id[s]))
				{
					if (object_index = obj_timeline)
						tl_remove_clean()
					
					instance_destroy()
				}
			}
		}

		with (obj_timeline)
			if (delete_ready)
				instance_destroy()

		if (history_data.scenery_replace_ground)
			background_ground_show = history_data.scenery_ground_show
	}
	else
	{
		var hobj, tl, particletemp, sceneryres, sceneryreplaceground, par, startplacing, buildaction;
		hobj = null
		particletemp = null
		sceneryres = null
		sceneryreplaceground = false
		startplacing = build || (setting_place_new && !keyboard_check(vk_shift))
		if (history_redo)
			buildaction = history_data.build_action
		else
			buildaction = (tab = e_bench.BLOCK || tab = e_bench.SPECIAL_BLOCK) && (place_build || startplacing)
		
		if (!history_redo && buildaction && !place_build)
		{
			build_type = (tab = e_bench.SPECIAL_BLOCK) ? e_tl_type.SPECIAL_BLOCK : e_tl_type.BLOCK
			app_start_place(true)
			return 0
		}
		
		startplacing = startplacing && !buildaction
		
		if (history_redo)
		{
			hobj = history_data
			par = save_id_find(history_data.parent_save_id)
			if (par = null)
				par = app
			hobj.spawn_amount = 0
			
			if (!history_data.build_action)
				bench_tab = history_data.bench_tab
			if (!history_data.build_action)
				history_restore_bench(history_data.bench_save_obj)
			
			if (tab = e_bench.PARTICLE_SPAWNER && history_data.particle_temp_save_id != "")
			{
				particletemp = save_id_find(history_data.particle_temp_save_id)
				bench_settings.particle_preset = particletemp
				bench_settings.particle_preset_temp = particletemp
				temp_edit = particletemp
			}
		}
		else
		{
			hobj = history_set(action_bench_create, buildaction)
			hobj.bench_save_obj = history_save_bench(buildaction ? build_settings : bench_settings)
			hobj.bench_tab = tab
			hobj.spawn_amount = 0
			hobj.open_editor = edit
			hobj.value_default = array()
			hobj.parent_save_id = save_id_get(app)
		}
		
		var temptype, tltype;
		temptype = null
		tltype = null

		switch (tab)
		{
			case e_bench.CHARACTER:			temptype = e_temp_type.CHARACTER break
			case e_bench.EQUIPMENT:			temptype = e_temp_type.EQUIPMENT break
			case e_bench.MODEL:				temptype = e_temp_type.MODEL break
			case e_bench.MODEL_PART:		temptype = e_temp_type.MODEL_PART break
			case e_bench.ITEM:				temptype = e_temp_type.ITEM break
			case e_bench.SCHEMATIC:			temptype = e_temp_type.SCENERY break
			case e_bench.BLOCK:				temptype = e_temp_type.BLOCK break
			case e_bench.SPECIAL_BLOCK:		temptype = e_temp_type.SPECIAL_BLOCK break
			case e_bench.SHAPE:				temptype = e_temp_type.CUBE + bench_settings.shape_type break
			case e_bench.TEXT:				temptype = e_temp_type.TEXT break
			case e_bench.PATH:				tltype = e_tl_type.PATH break
			case e_bench.CAMERA:			tltype = e_tl_type.CAMERA break
			case e_bench.PARTICLE_SPAWNER:	temptype = e_temp_type.PARTICLE_SPAWNER break
			case e_bench.AUDIO_TRACK:		tltype = e_tl_type.AUDIO_TRACK break
			case e_bench.LIGHT_SOURCE:		tltype = bench_settings.light_type break
			case e_bench.ENVIRONMENT:		tltype = e_tl_type.BACKGROUND break
		}

		if (tab = e_bench.SCHEMATIC)
		{
			if (history_redo)
			{
				if (history_data.scenery_res_save_obj != null)
				{
					sceneryres = history_restore_res(history_data.scenery_res_save_obj)
					sceneryres.display_name = history_data.scenery_res_save_obj.display_name
					bench_settings.scenery = sceneryres
				}
			}
			else
			{
				hobj.scenery_res_save_obj = null
				sceneryres = action_bench_schematic_create_resource()
				if (sceneryres != null)
					hobj.scenery_res_save_obj = history_save_res(sceneryres)
			}
		}
		else if (tab = e_bench.PARTICLE_SPAWNER && !history_redo)
			particletemp = bench_settings.particle_preset_temp

		if (tltype != null) // Timeline
		{
			tl = new_tl(tltype)
			editobj = tl
			with (hobj)
			{
				spawn_save_id[spawn_amount] = tl.save_id
				spawn_amount++
			}
			
			if (tab = e_bench.CAMERA)
				view_second.show = true
		}
		else if (particletemp != null)
		{
			with (particletemp)
				tl = temp_animate()

			temp_edit = particletemp
			editobj = particletemp

			with (hobj)
			{
				spawn_save_id[spawn_amount] = tl.save_id
				spawn_amount++
				if (!app.history_redo)
					particle_temp_save_id = particletemp.save_id
			}
		}
		else if (temptype != null)
		{
			if (tab = e_bench.BLOCK)
			{
				tl = new_obj(obj_timeline)
				with (tl)
				{
					var buildsource = app.place_build ? app.build_settings : app.bench_settings;
					if (app.history_redo && history_data.build_action)
						buildsource = history_data.bench_save_obj
					
					type = e_tl_type.BLOCK
					id.temp = id
					has_temp = false
					
					block_name = buildsource.block_name
					block_state = array_copy_1d(buildsource.block_state)
					block_tex = buildsource.block_tex
					block_tex_material = buildsource.block_tex_material
					block_tex_normal = buildsource.block_tex_normal
					block_repeat_enable = buildsource.block_repeat_enable
					block_repeat = array_copy_1d(buildsource.block_repeat)
					block_center_legacy = false
					block_center = buildsource.block_center
					block_randomize = buildsource.block_randomize
					block_vbuffer = null
					inherit_alpha = true
					inherit_color = true
					inherit_texture = true
					texture_filtering = true
					
					tl_update_scenery_part()
					temp_update_rot_point()
					tl_update()
					tl_set_parent_root()
					tl_value_spawn()
				}

				with (hobj)
				{
					spawn_save_id[spawn_amount] = tl.save_id
					spawn_amount++
				}
				editobj = tl
			}
			else if (tab = e_bench.SPECIAL_BLOCK)
			{
				tl = new_obj(obj_timeline)
				with (tl)
				{
					var buildsource = app.place_build ? app.build_settings : app.bench_settings;
					if (app.history_redo && history_data.build_action)
						buildsource = history_data.bench_save_obj
					
					type = e_tl_type.SPECIAL_BLOCK
					id.temp = id
					has_temp = false
					
					model_name = buildsource.model_name
					model_state = array_copy_1d(buildsource.model_state)
					model_tex = buildsource.model_tex
					model_tex_material = buildsource.model_tex_material
					model_tex_normal = buildsource.model_tex_normal
					model_use_blend_color = buildsource.model_use_blend_color
					model_blend_color = buildsource.model_blend_color
					model_blend_color_default = buildsource.model_blend_color_default
					
					pattern_base_color = buildsource.pattern_base_color
					pattern_pattern_list = array_copy_1d(buildsource.pattern_pattern_list)
					pattern_color_list = array_copy_1d(buildsource.pattern_color_list)
					
					inherit_alpha = true
					inherit_color = true
					inherit_texture = true
					
					tl_update_scenery_part()

					part_list = ds_list_create()
					if (model_file != null)
					{
						for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
						{
							var part = model_file.file_part_list[|p];
							if (model_hide_list = null || ds_list_find_index(model_hide_list, part.name) = -1)
								ds_list_add(part_list, tl_new_part(part))
						}
						tl_update_part_list(model_file, id)
					}

					tl_update()
					tl_set_parent_root()
					tl_value_spawn()
				}

				with (hobj)
				{
					spawn_save_id[spawn_amount] = tl.save_id
					spawn_amount++
				}
				editobj = tl
			}
			else with (bench_settings)
			{
				type = temptype
				
				var temp = temp_duplicate();
				
				// Don't copy into template 
				if (temp.type != e_temp_type.CUBE && temp.type != e_temp_type.CYLINDER && temp.type != e_temp_type.CONE) 
					temp.shape_tex_mapped = false
				
				if (temp.type = e_temp_type.PARTICLE_SPAWNER)
					temp.pc_spawn_region_path = null
				
				with (hobj)
				{
					spawn_save_id[spawn_amount] = temp.save_id
					spawn_amount++
				}
				
				with (temp)
				{
					if (type != e_temp_type.MODEL && model != null)
						model = null
					
					if (type != e_temp_type.CHARACTER && type != e_temp_type.EQUIPMENT && type != e_temp_type.SPECIAL_BLOCK && type != e_temp_type.MODEL_PART && type != e_temp_type.MODEL)
					{
						model_tex = null
						model_tex_material = null
						model_tex_normal = null
						model_file = null
						model_part = null
						model_state = array()
					}
					
					if (type != e_temp_type.ITEM)
					{
						item_tex = null
						item_tex_material = null
						item_tex_normal = null
					}
					
					if (type != e_temp_type.BLOCK && type != e_temp_type.SCENERY)
					{
						block_tex = null
						block_tex_material = null
						block_tex_normal = null
						block_state = array()
					}
					
					if (type != e_temp_type.SCENERY && scenery != null)
						scenery = null
					
					if (!type_is_shape(type))
					{
						if (shape_tex != null)
							shape_tex = null
						
						if (shape_tex_material != null)
							shape_tex_material = null
						
						if (shape_tex_normal != null)
							shape_tex_normal = null
					}
					
					if (type != e_temp_type.TEXT)
						text_font = null
					
					tl = temp_animate()
					
					if (type = e_temp_type.TEXT && other.text != "")
						tl.text = other.text
					
					temp_add_lists()
				}
				
				temp_edit = temp
				editobj = temp
			}
			
			// Add templates connected to the bench
			with (obj_template)
			{
				if (creator != app.bench_settings)
					continue
				
				temp_add_lists()
				creator = app
				
				with (hobj)
				{
					spawn_save_id[spawn_amount] = other.save_id
					spawn_amount++
				}
			}
		}
		if (sceneryres != null)
		{
			with (hobj)
			{
				spawn_save_id[spawn_amount] = sceneryres.save_id
				spawn_amount++
			}
		}

		if (tab = e_bench.SCHEMATIC)
		{
			if (history_redo)
				sceneryreplaceground = history_data.scenery_replace_ground
			else if (setting_scenery_replace_ground && tl.temp.scenery != null &&
				tl.temp.scenery.scenery_size[X] > scenery_large_threshold && tl.temp.scenery.scenery_size[Y] > scenery_large_threshold)
			{
				sceneryreplaceground = true
				hobj.scenery_replace_ground = true
				hobj.scenery_ground_show = background_ground_show
			}

			if (sceneryreplaceground)
				with (tl)
					tl_replace_ground()
		}
		
		if (history_redo)
		{
			if (!history_data.build_action)
				with (bench_settings)
					temp_particles_type_clear()
			
			with (tl)
			{
				tl_set_parent(par)
				tl_value_copy_vec3(e_value.POS_X, value_default, history_data.value_default)
				tl_value_copy_vec3(e_value.ROT_X, value_default, history_data.value_default)
				tl_value_copy_vec3(e_value.SCA_X, value_default, history_data.value_default)
				tl_value_copy_vec3(e_value.POS_X, value, value_default)
				tl_value_copy_vec3(e_value.ROT_X, value, value_default)
				tl_value_copy_vec3(e_value.SCA_X, value, value_default)
			}
		}
		else
		{
			if (buildaction)
			{
				with (tl)
				{
					tl_value_set_matrix(id, matrix_create(app.place_pos, app.place_rot, app.place_sca), true)
					update_matrix = true
					if (app.place_target_tl != null && instance_exists(app.place_target_tl))
					{
						var action = tl_get_parent_action(app.place_target_tl);
						if (is_array(action) && array_length(action) > e_parent_action.TARGET)
							tl_set_parent(action[e_parent_action.TARGET], -1, true)
					}
				}
			}
			
			with (hobj)
			{
				tl_value_copy_vec3(e_value.POS_X, value_default, tl.value_default)
				tl_value_copy_vec3(e_value.ROT_X, value_default, tl.value_default)
				tl_value_copy_vec3(e_value.SCA_X, value_default, tl.value_default)
				parent = tl.parent
				parent_save_id = save_id_get(tl.parent)
			}
			
			// Start placing
			if (startplacing &&
				tl.type != e_tl_type.FOLDER &&
				tl.type != e_tl_type.CAMERA &&
				(tl.type != e_tl_type.SCENERY || tl.temp.scenery != null) &&
				(tl.type != e_tl_type.MODEL || tl.temp.model != null) &&
				!sceneryreplaceground &&
				tl.value_type[e_value_type.TRANSFORM_POS])
				app_start_place(false, tl, true)
			
			log("Created", tl_type_name_list[|tl.type])

			// Encourage parenting armor to a character
			if (!setting_advanced_mode && tab = e_bench.EQUIPMENT)
			{
				toast_new(e_toast.INFO, text_get("alertequiparmor"))
				toast_last.dismiss_time = 15
			}
		}
	}
	
	if (!history_undo && (edit || (history_redo && history_data.open_editor)) && editobj != null)
	{
		obj_edit = editobj
		tab_object_editor_update_ptype_list()
		if (!place_build)
			tab_show(object_editor)
	}
	
	if (tab = e_bench.PARTICLE_SPAWNER)
	{
		if (!history_undo && !history_redo)
			action_bench_particles_folder(bench_particle_preset_folder)
		
		particle_spawner_clear()
		preview_reset_view()
		update = true
	}
	
	if (!history_undo && tab = e_bench.TEXT)
		bench_settings.text = ""

	tl_update_list()
	tl_update_matrix()
	if (history_undo)
		app_update_tl_edit()
	
	project_update_counts()
	lib_preview.update = true
	
	if (place_build)
	{
		place_pos = null
		place_view_pos = null
		view_main.update_place_surfaces = true
		view_second.update_place_surfaces = true
	}
}

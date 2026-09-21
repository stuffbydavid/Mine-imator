/// action_bench_create([edit, build])
/// @arg [edit]
/// @arg [build]

function action_bench_create(edit = false, build = false)
{
	var tab, editobj;
	tab = (history_undo || history_redo) ? history_data.bench_tab : bench_tab
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
		buildaction = startplacing && (bench_tab = e_bench.BLOCK || bench_tab = e_bench.SPECIAL_BLOCK)
		
		if (history_redo)
		{
			hobj = history_data
			par = save_id_find(history_data.parent_save_id)
			if (par = null)
				par = app
			hobj.spawn_amount = 0
			bench_tab = history_data.bench_tab
			history_restore_bench(history_data.bench_save_obj)
			if (bench_tab = e_bench.PARTICLE_SPAWNER && history_data.particle_temp_save_id != "")
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
			hobj.bench_save_obj = history_save_bench()
			hobj.bench_tab = bench_tab
			hobj.spawn_amount = 0
			hobj.open_editor = edit
			hobj.value_default = array()
			hobj.parent_save_id = save_id_get(app)
		}
		
		var temptype, tltype;
		temptype = null
		tltype = null

		switch (bench_tab)
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

		if (bench_tab = e_bench.SCHEMATIC)
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
		else if (bench_tab = e_bench.PARTICLE_SPAWNER && !history_redo)
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
			
			if (bench_tab = e_bench.CAMERA)
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
			if (bench_tab = e_bench.BLOCK)
			{
				tl = new_obj(obj_timeline)
				with (tl)
				{
					type = e_tl_type.BLOCK
					id.temp = id
					has_temp = false
					block_name = app.bench_settings.block_name
					block_state = array_copy_1d(app.bench_settings.block_state)
					block_tex = app.bench_settings.block_tex
					block_tex_material = app.bench_settings.block_tex_material
					block_tex_normal = app.bench_settings.block_tex_normal
					block_repeat_enable = app.bench_settings.block_repeat_enable
					block_repeat = array_copy_1d(app.bench_settings.block_repeat)
					block_center_legacy = false
					block_center = app.bench_settings.block_center
					block_randomize = app.bench_settings.block_randomize
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
			else if (bench_tab = e_bench.SPECIAL_BLOCK)
			{
				tl = new_obj(obj_timeline)
				with (tl)
				{
					type = e_tl_type.SPECIAL_BLOCK
					id.temp = id
					has_temp = false
					model_name = app.bench_settings.model_name
					model_state = array_copy_1d(app.bench_settings.model_state)
					model_tex = app.bench_settings.model_tex
					model_tex_material = app.bench_settings.model_tex_material
					model_tex_normal = app.bench_settings.model_tex_normal
					model_use_blend_color = app.bench_settings.model_use_blend_color
					model_blend_color = app.bench_settings.model_blend_color
					model_blend_color_default = app.bench_settings.model_blend_color_default
					pattern_base_color = app.bench_settings.pattern_base_color
					pattern_pattern_list = array_copy_1d(app.bench_settings.pattern_pattern_list)
					pattern_color_list = array_copy_1d(app.bench_settings.pattern_color_list)
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

		if (bench_tab = e_bench.SCHEMATIC)
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
			with (hobj)
			{
				tl_value_copy_vec3(e_value.POS_X, value_default, tl.value_default)
				tl_value_copy_vec3(e_value.ROT_X, value_default, tl.value_default)
				tl_value_copy_vec3(e_value.SCA_X, value_default, tl.value_default)
				parent = app
			}
			
			// Start placing
			if (startplacing &&
				tl.type != e_tl_type.FOLDER &&
				tl.type != e_tl_type.CAMERA &&
				(tl.type != e_tl_type.SCENERY || tl.temp.scenery != null) &&
				(tl.type != e_tl_type.MODEL || tl.temp.model != null) &&
				!sceneryreplaceground &&
				tl.value_type[e_value_type.TRANSFORM_POS])
			{
				app_start_place(tl, true)
				
				// Start build mode
				if (bench_tab = e_bench.BLOCK || bench_tab = e_bench.SPECIAL_BLOCK)
				{
					place_build = true
					
					place_view_second_show = view_second.show && !window_exists(e_window.VIEW_SECOND)
					if (place_view_second_show)
						view_second.show = false
						
					with (tl)
						tl_mark_placed(true)
					
					tl_deselect_all()
					
					obj_edit = tl
					tab_show(object_editor, true)
				}
			}
			if (buildaction && !place_build)
				hobj.build_action = false
			
			log("Created", tl_type_name_list[|tl.type])

			// Encourage parenting armor to a character
			if (!setting_advanced_mode && bench_tab = e_bench.EQUIPMENT)
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
		tab_show(object_editor)
	}
	
	if (bench_tab = e_bench.PARTICLE_SPAWNER)
	{
		if (!history_undo && !history_redo)
			action_bench_particles_folder(bench_particle_preset_folder)
		
		particle_spawner_clear()
		preview_reset_view()
		update = true
	}
	
	if (!history_undo && bench_tab = e_bench.TEXT)
		bench_settings.text = ""

	tl_update_list()
	tl_update_matrix()
	project_update_counts()
	lib_preview.update = true
}

/// bench_click(tab)
/// @arg tab

function bench_click(tab, key = false)
{
	// Double clicked, create asset
	if (bench_tab = tab && tab != e_bench.WORLD && bench_show_ani_type = "")
	{
		if (tab = e_bench.PROJECT && (bench_settings.project_selected = null || bench_settings.project_selected.object_index != obj_template))
			return 0
		if (tab = e_bench.SCHEMATIC && bench_settings.scenery = null)
			return 0
		if (tab = e_bench.SOUND && !is_array(bench_settings.sound_list_current.select))
			return 0

		action_bench_create()
		bench_show_ani_type = "hide"
		return 0
	}

	if (bench_tab = e_bench.SOUND && tab != e_bench.SOUND)
	{
		if (bench_settings.sound_list_current.source = "music" && !bench_music_mode)
			bench_music_stop()
		else if (bench_settings.sound_list_current.source != "music")
			with (bench_settings.preview)
				preview_sound_stop()
	}

	bench_tab = tab
	
	with (bench_settings)
	{
		name = ""

		switch (tab)
		{
			case e_bench.CHARACTER:
			{
				type = e_temp_type.CHARACTER
				
				if (ds_list_find_index(char_list.list, model_name) < 0)
				{
					model_name = default_model
					model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
				}
			
				model_tex = project_pack_res
				model_tex_material = project_pack_res
				model_tex_normal = project_pack_res
			
				temp_update_model()
				temp_update_model_shape()
				break
			}
			
			case e_bench.EQUIPMENT:
			{
				type = e_temp_type.EQUIPMENT
				
				if (ds_list_find_index(equipment_list.list, model_name) < 0)
				{
					model_name = default_equipment
					model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
				}
				
				model_tex = project_pack_res
				model_tex_material = project_pack_res
				model_tex_normal = project_pack_res
			
				temp_update_model()
				temp_update_model_shape()
				break
			}
			
			case e_bench.SPECIAL_BLOCK:
			{
				type = e_temp_type.SPECIAL_BLOCK
				
				if (ds_list_find_index(special_block_list.list, model_name) < 0)
				{
					model_name = default_special_block
					model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
				}
			
			model_tex = project_pack_res
			model_tex_material = project_pack_res
			model_tex_normal = project_pack_res
			
				temp_update_model()
				temp_update_model_shape()
			
				break
			}
			
			case e_bench.MODEL_PART:
			{
				type = e_temp_type.MODEL_PART
				
				model_name = default_model_part_model
				model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
				model_tex = project_pack_res
				model_tex_material = project_pack_res
				model_tex_normal = project_pack_res
			
				temp_update_model()
				temp_update_model_part()
				temp_update_model_shape()
				break
			}
			
			case e_bench.BLOCK:
			{
				type = e_temp_type.BLOCK
				temp_update_block()
				break
			}
			
			case e_bench.ITEM:
			{
				type = e_temp_type.ITEM
				render_generate_item()
				break
			}
			
			case e_bench.SHAPE:
			{
				type = e_temp_type.CUBE + shape_type
				temp_update_shape()
				break
			}
			
			case e_bench.MODEL:
			{
				type = e_temp_type.MODEL
				model_tex = null
				model_tex_material = null
				model_tex_normal = null
			
				temp_update_model()
				temp_update_model_shape()
			
				// Modelbench popup
				if (show_modelbench_popup)
					with (app)
						if (!popup_modelbench.hidden && !popup_modelbench.not_now)
							popup_show(popup_modelbench)
				break
			}
			
			case e_bench.SOUND:
			{
				type = e_tl_type.AUDIO_TRACK
				
				if (!minecraft_game_found)
				{
					with (app)
						action_bench_sound_source("project")
				}
				else if (ds_list_empty(sounds_list.list))
					soundlist_load(sounds_list, music_list)
					
				if (minecraft_game_found)
					soundlist_select_default(sound_list_current)
				bench_audio_track_update()
				
				break
			}

			case e_bench.AUDIO_TRACK:	type = e_tl_type.AUDIO_TRACK break

			case e_bench.WORLD:
			case e_bench.SCHEMATIC:			type = e_temp_type.SCENERY break
			case e_bench.TEXT:				type = e_temp_type.TEXT break
			case e_bench.PATH:				type = e_tl_type.PATH break
			case e_bench.CAMERA:			type = e_tl_type.CAMERA break
			case e_bench.PARTICLE_SPAWNER:  type = e_temp_type.PARTICLE_SPAWNER break
			case e_bench.LIGHT_SOURCE:		type = light_type break
			case e_bench.ENVIRONMENT:		type = e_tl_type.BACKGROUND break
		}
	}
	
	var sortlist, sortvalue;
	sortlist = null
	sortvalue = null
	switch (tab)
	{
		case e_bench.CHARACTER: 		sortlist = bench_settings.char_list break
		case e_bench.EQUIPMENT: 		sortlist = bench_settings.equipment_list break
		case e_bench.SPECIAL_BLOCK: 	sortlist = bench_settings.special_block_list break
		case e_bench.MODEL_PART: 		sortlist = bench_settings.model_part_model_list break
		case e_bench.BLOCK:
		{
			sortlist = bench_settings.block_list
			sortvalue = bench_settings.block_name
			break
		}
		case e_bench.SHAPE:
		{
			sortlist = bench_settings.shape_list
			sortvalue = bench_settings.shape_type
			break
		}
		case e_bench.PARTICLE_SPAWNER:
		{
			sortlist = bench_settings.particle_preset_list
			sortvalue = bench_settings.particle_preset
			break
		}
	}
	if (sortlist != null)
	{
		if (sortvalue = null)
			sortvalue = bench_settings.model_name

		sortlist_view(sortlist, sortvalue)
		window_scroll_focus = string(sortlist.scroll)
	}
	
	with (bench_settings.preview)
	{
		particle_spawner_clear()
		preview_reset_view()
		update = true
	}
	
	bench_clear()
	
	if (tab = e_bench.PROJECT)
	{
		action_bench_project_select(bench_settings.project_selected)
		window_scroll_focus = string(bench_settings.project_list.scroll)
	}
	else if (tab = e_bench.SCHEMATIC)
	{
		action_bench_schematic_folder(bench_schematic_folder)
		window_scroll_focus = string(bench_settings.schematic_list.scroll)
	}
	else if (tab = e_bench.PARTICLE_SPAWNER)
	{
		action_bench_particles_folder(bench_particle_preset_folder)
		window_scroll_focus = string(bench_settings.particle_preset_list.scroll)
	}
	else if (tab = e_bench.TEXT)
	{
		preview_zoom_text(bench_settings.preview, bench_settings.text, bench_settings.text_font)
		if (!key)
			window_focus = string(bench_settings.tbx_text)
	}
		
	bench_settings_ani = 0
}

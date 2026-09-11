/// bench_click(tab)
/// @arg tab

function bench_click(tab)
{
	// Double clicked, create asset
	if (bench_tab = tab && tab != e_workbench.WORLD && bench_show_ani_type = "")
	{
		action_bench_create()
		bench_show_ani_type = "hide"
		
		return 0
	}

	bench_tab = tab
	
	with (bench_settings)
	{
		switch (tab)
		{
			case e_workbench.CHARACTER:
			{
				type = e_temp_type.CHARACTER
				
				if (ds_list_find_index(char_list.list, model_name) < 0)
				{
					model_name = default_model
					model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
				}
			
				model_tex = mc_res
				model_tex_material = mc_res
				model_tex_normal = mc_res
			
				temp_update_model()
				temp_update_model_shape()
				break
			}
			
			case e_workbench.EQUIPMENT:
			{
				type = e_temp_type.EQUIPMENT
				
				if (ds_list_find_index(equipment_list.list, model_name) < 0)
				{
					model_name = default_equipment
					model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
				}
				
				model_tex = mc_res
				model_tex_material = mc_res
				model_tex_normal = mc_res
			
				temp_update_model()
				temp_update_model_shape()
				break
			}
			
			case e_workbench.SPECIAL_BLOCK:
			{
				type = e_temp_type.SPECIAL_BLOCK
				
				if (ds_list_find_index(special_block_list.list, model_name) < 0)
				{
					model_name = default_special_block
					model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
				}
			
				model_tex = mc_res
				model_tex_material = mc_res
				model_tex_normal = mc_res
			
				temp_update_model()
				temp_update_model_shape()
			
				break
			}
			
			case e_workbench.MODEL_PART:
			{
				type = e_temp_type.MODEL_PART
				
				model_name = default_model_part_model
				model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
				model_tex = mc_res
				model_tex_material = mc_res
				model_tex_normal = mc_res
			
				temp_update_model()
				temp_update_model_part()
				temp_update_model_shape()
				break
			}
			
			case e_workbench.BLOCK:
			{
				type = e_temp_type.BLOCK
				temp_update_block()
				break
			}
			
			case e_workbench.ITEM:
			{
				type = e_temp_type.ITEM
				render_generate_item()
				break
			}
			
			case e_workbench.SHAPE:
			{
				type = e_tl_type.SHAPE
				temp_update_shape()
				break
			}
			
			case e_workbench.MODEL:
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

			case e_workbench.WORLD:
			case e_workbench.SCHEMATIC:			type = e_temp_type.SCENERY break
			case e_workbench.TEXT:				type = e_temp_type.TEXT break
			case e_workbench.PATH:				type = e_tl_type.PATH break
			case e_workbench.CAMERA:			type = e_tl_type.CAMERA break
			case e_workbench.PARTICLE_SPAWNER:  type = e_temp_type.PARTICLE_SPAWNER break
			case e_workbench.LIGHT_SOURCE:		type = e_tl_type.LIGHT_SOURCE break
			case e_workbench.AUDIO:				type = e_tl_type.AUDIO break
			case e_workbench.ENVIRONMENT:		type = e_tl_type.BACKGROUND break
		}
	}
	
	// Switch to particles
	if (bench_tab = e_workbench.PARTICLE_SPAWNER)
		bench_update_particles_list()
	
	with (bench_settings.preview)
	{
		particle_spawner_clear()
		preview_reset_view()
		update = true
	}
	
	bench_clear()
	
	if (tab = e_workbench.SCHEMATIC)
		action_bench_schematic_folder(bench_schematic_folder)
		
	bench_settings_ani = 0
}

/// action_bench_create([edit])
/// @arg [edit]

function action_bench_create(edit = false)
{
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
	}
	else
	{
		var hobj, tl;
		hobj = null
		
		if (history_redo)
		{
			history_restore_bench(history_data.bench_save_obj)
			
			if (history_data.open_editor)
			{
				tab_template_editor_update_ptype_list()
				tab_show(template_editor)
			}
		}
		else
		{
			hobj = history_set(action_bench_create)
			hobj.bench_save_obj = history_save_bench()
			hobj.spawn_amount = 0
			hobj.open_editor = edit
			
			if (edit)
				tab_show(template_editor)
		}
		
		if (type_is_timeline(bench_settings.type)) // Timeline
		{
			tl = new_tl(bench_settings.type = e_tl_type.LIGHT_SOURCE ? bench_settings.light_type : bench_settings.type)
			with (hobj)
			{
				spawn_save_id[spawn_amount] = tl.save_id
				spawn_amount++
			}
			
			if (bench_settings.type = e_tl_type.CAMERA)
				view_second.show = true
		}
		else
		{
			with (bench_settings)
			{
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
					{
						model.count--
						model = null
					}
					
					if (type != e_temp_type.CHARACTER && type != e_temp_type.SPECIAL_BLOCK && type != e_temp_type.BODYPART && type != e_temp_type.MODEL)
					{
						if (model_tex != null)
							model_tex.count--
						
						if (model_tex_material != null)
							model_tex_material.count--
						
						if (model_tex_normal != null)
							model_tex_normal.count--
						
						model_tex = null
						model_tex_material = null
						model_tex_normal = null
						model_file = null
						model_part = null
						model_state = array()
					}
					
					if (type != e_temp_type.ITEM)
					{
						item_tex.count--
						
						if (item_tex_material != null)
							item_tex_material.count--
						
						if (item_tex_normal != null)
							item_tex_normal.count--
						
						item_tex = null
						item_tex_material = null
						item_tex_normal = null
					}
					
					if (type != e_temp_type.BLOCK && type != e_temp_type.SCENERY)
					{
						block_tex.count--
						block_tex = null
						block_tex_material.count--
						block_tex_material = null
						block_tex_normal.count--
						block_tex_normal = null
						block_state = array()
					}
					
					if (type != e_temp_type.SCENERY && scenery != null)
					{
						scenery.count--
						scenery = null
					}
					
					if (!type_is_shape(type))
					{
						if (shape_tex != null)
						{
							if (shape_tex.type != e_tl_type.CAMERA)
								shape_tex.count--
							shape_tex = null
						}
						
						if (shape_tex_material != null)
						{
							shape_tex_material.count--
							shape_tex_material = null
						}
						
						if (shape_tex_normal != null)
						{
							shape_tex_normal.count--
							shape_tex_normal = null
						}
					}
					
					if (type != e_temp_type.TEXT)
					{
						text_font.count--
						text_font = null
					}
					
					tl = temp_animate()
					sortlist_add(app.lib_list, id)
				}
				
				temp_edit = temp
			}
			
			// Add templates connected to the bench
			with (obj_template)
			{
				if (creator != app.bench_settings)
					continue
				
				sortlist_add(app.lib_list, id)
				creator = app
				
				if (model_tex != null)
					model_tex.count++
				
				if (model_tex_material != null)
					model_tex_material.count++
				
				if (model_tex_normal != null)
					model_tex_normal.count++
				
				if (item_tex != null)
					item_tex.count++
				
				if (item_tex_material != null)
					item_tex_material.count++
				
				if (item_tex_normal != null)
					item_tex_normal.count++
				
				if (block_tex != null)
					block_tex.count++
				
				if (block_tex_material != null)
					block_tex_material.count++
				
				if (block_tex_normal != null)
					block_tex_normal.count++
				
				if (scenery > 0)
					scenery.count++
				
				if (shape_tex != null && shape_tex.type != e_tl_type.CAMERA)
					shape_tex.count++
				
				if (shape_tex_material != null)
					shape_tex_material.count++
				
				if (shape_tex_normal != null)
					shape_tex_normal.count++
				
				if (text_font != null)
					text_font.count++
				
				with (hobj)
				{
					spawn_save_id[spawn_amount] = other.save_id
					spawn_amount++
				}
			}
		}
		
		if (history_redo)
		{
			with (bench_settings)
				temp_particles_type_clear()
			
			with (tl)
			{
				value_default[e_value.POS_X] = history_data.value_default[e_value.POS_X]
				value_default[e_value.POS_Y] = history_data.value_default[e_value.POS_Y]
				value_default[e_value.POS_Z] = history_data.value_default[e_value.POS_Z]
				value_default[e_value.ROT_X] = history_data.value_default[e_value.ROT_X]
				value_default[e_value.ROT_Y] = history_data.value_default[e_value.ROT_Y]
				value_default[e_value.ROT_Z] = history_data.value_default[e_value.ROT_Z]
				value[e_value.POS_X] = value_default[e_value.POS_X]
				value[e_value.POS_Y] = value_default[e_value.POS_Y]
				value[e_value.POS_Z] = value_default[e_value.POS_Z]
				value[e_value.ROT_X] = value_default[e_value.ROT_X]
				value[e_value.ROT_Y] = value_default[e_value.ROT_Y]
				value[e_value.ROT_Z] = value_default[e_value.ROT_Z]
			}
		}
		else
		{
			with (hobj)
			{
				value_default[e_value.POS_X] = tl.value_default[e_value.POS_X]
				value_default[e_value.POS_Y] = tl.value_default[e_value.POS_Y]
				value_default[e_value.POS_Z] = tl.value_default[e_value.POS_Z]
				value_default[e_value.ROT_X] = tl.value_default[e_value.ROT_X]
				value_default[e_value.ROT_Y] = tl.value_default[e_value.ROT_Y]
				value_default[e_value.ROT_Z] = tl.value_default[e_value.ROT_Z]
			}
			
			log("Created", tl_type_name_list[|bench_settings.type])
		}
	}
	
	if (!history_redo && edit)
		tab_template_editor_update_ptype_list()
	
	tl_update_list()
	tl_update_matrix()
	lib_preview.update = true
}

/// action_bench_create()

if (history_undo)
{
	with (history_data)
		for (var s = 0; s < spawn_amount; s++)
			with (iid_find(spawn[s]))
				instance_destroy()
}
else
{
	var hobj, tl;
	hobj = null
	
	if (history_redo)
		history_restore_bench(history_data.save_bench)
	else
	{
		hobj = history_set(action_bench_create)
		hobj.save_bench = history_save_bench()
		hobj.spawn_amount = 0
	}
	
	if (type_is_timeline(bench_settings.type)) // Timeline
	{
		tl = new_tl(bench_settings.type)
		with (hobj)
		{
			spawn[spawn_amount] = tl.iid
			spawn_amount++
		}
		
		if (bench_settings.type = "camera")
			view_second.show = true
	}
	else
	{
		with (bench_settings)
		{
			var temp = temp_duplicate();
			with (hobj)
			{
				spawn[spawn_amount] = temp.iid
				spawn_amount++
			}
			
			with (temp)
			{
				if (type != "char" && type != "spblock" && type != "bodypart")
				{
					skin.count--
					skin = null
					char_model = null
				}
				
				if (type != "item")
				{
					item_tex.count--
					item_tex = null
				}
				
				if (type != "block" && type != "scenery")
				{
					block_tex.count--
					block_tex = null
				}
				
				if (type != "scenery" && scenery)
				{
					scenery.count--
					scenery = null
				}
				
				if (!type_is_shape(type) && shape_tex)
				{
					if (shape_tex.type != "camera")
						shape_tex.count--
					shape_tex = null
				}
				
				if (type != "text")
				{
					text_font.count--
					text_font = null
				}
				
				tl = temp_animate()
			}
			sortlist_add(app.lib_list, temp)
			temp_edit = temp
		}
		with (obj_template) // Add templates connected to the bench
		{
			if (creator != app.bench_settings)
				continue
				
			sortlist_add(app.lib_list, id)
			creator = app
			
			if (char_skin)
				char_skin.count++
				
			if (item_tex)
				item_tex.count++
				
			if (block_tex)
				block_tex.count++
				
			if (scenery)
				scenery.count++
				
			if (shape_tex && shape_tex.type != "camera")
				shape_tex.count++
				
			if (text_font)
				text_font.count++
				
			with (hobj)
			{
				spawn[spawn_amount] = other.iid
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
			value_default[XPOS] = history_data.value_default[XPOS]
			value_default[YPOS] = history_data.value_default[YPOS]
			value_default[ZPOS] = history_data.value_default[ZPOS]
			value_default[XROT] = history_data.value_default[XROT]
			value_default[YROT] = history_data.value_default[YROT]
			value_default[ZROT] = history_data.value_default[ZROT]
			value[XPOS] = value_default[XPOS]
			value[YPOS] = value_default[YPOS]
			value[ZPOS] = value_default[ZPOS]
			value[XROT] = value_default[XROT]
			value[YROT] = value_default[YROT]
			value[ZROT] = value_default[ZROT]
		}
	}
	else
	{
		with (hobj)
		{
			value_default[XPOS] = tl.value_default[XPOS]
			value_default[YPOS] = tl.value_default[YPOS]
			value_default[ZPOS] = tl.value_default[ZPOS]
			value_default[XROT] = tl.value_default[XROT]
			value_default[YROT] = tl.value_default[YROT]
			value_default[ZROT] = tl.value_default[ZROT]
		}
		
		log("Created", bench_settings.type)
	}
}

tl_update_list()
tl_update_matrix()
lib_preview.update = true

/// minecraft_assets_reload()
/// @desc Debug use only.

function minecraft_assets_reload()
{
	var fname = minecraft_directory + minecraft_version + ".midata";
	
	log("Reloading models")
	
	var typemap, map;
	typemap = ds_map_create()
	map = json_load(fname, typemap)
	if (!ds_map_valid(map))
	{
		log("Could not parse JSON", fname)
		ds_map_destroy(typemap)
		return false
	}
	
	load_assets_model_file_map = ds_map_create() // filename -> model
	
	with (mc_assets)
	{
		ds_map_clear(model_name_map)
		ds_list_clear(char_list)
		ds_list_clear(special_block_list)
		
		// Characters
		var characterslist = map[?"characters"];
		if (is_undefined(characterslist))
		{
			log("No character list found")
			break
		}
		
		for (var i = 0; i < ds_list_size(characterslist); i++)
		{
			var model = model_load(characterslist[|i], load_assets_dir + mc_character_directory);
			if (!model) // Something went wrong!
			{
				log("Could not load model")
				continue
			}
			
			model_name_map[?model.name] = model
			
			ds_list_add(char_list, model)
		}
		
		// Special blocks
		var specialblockslist = map[?"special_blocks"];
		if (is_undefined(specialblockslist))
		{
			log("No special block list found")
			break
		}
		
		for (var i = 0; i < ds_list_size(specialblockslist); i++)
		{
			var model = model_load(specialblockslist[|i], load_assets_dir + mc_special_block_directory);
			if (!model) // Something went wrong!
			{
				log("Could not load model")
				continue
			}
			
			model_name_map[?model.name] = model
			
			ds_list_add(special_block_list, model)
		}
		
		// Clear up loaded models
		var key = ds_map_find_first(load_assets_model_file_map);
		while (!is_undefined(key))
		{
			with (load_assets_model_file_map[?key])
				instance_destroy()
			key = ds_map_find_next(load_assets_model_file_map, key)
		}
	}
	
	ds_map_destroy(load_assets_model_file_map)
	ds_map_destroy(map)
	ds_map_destroy(typemap)
	
	with (obj_template)
		if (type = e_temp_type.CHARACTER || type = e_temp_type.SPECIAL_BLOCK)
			temp_update_model()
	
	with (obj_timeline)
		tl_update_scenery_part()
}

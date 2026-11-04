/// @desc Debug use only.

function minecraft_assets_reload()
{
	var fn = minecraft_directory + minecraft_assets_version + ".midata";
	
	log("Reloading models")
	
	var typemap, map;
	typemap = ds_int_map_create()
	map = json_load(fn, typemap)
	
	if (!ds_map_valid(map))
	{
		log("Could not parse JSON", fn)
		ds_map_destroy(typemap)
		return false
	}
	
	load_assets_model_file_map = ds_map_create() // filename -> model
	
	with (mc_assets)
	{
		ds_map_clear(model_name_map)
		ds_map_clear(entity_model_map)
		ds_list_clear(char_list)
		ds_list_clear(special_block_list)
		ds_list_clear(equipment_list)
		
		// Characters
		var charlist = map[?"characters"];
		if (!ds_list_valid(charlist))
		{
			log("No character list found")
			break
		}
		
		for (var i = 0; i < ds_list_size(charlist); i++)
		{
			var model = model_load(charlist[|i], load_assets_dir + mc_character_directory);
			if (!model) // Something went wrong!
			{
				log("Could not load model")
				continue
			}
			
			model_name_map[?model.name] = model
			
			ds_list_add(char_list, model)
		}

		// Equipment
		var equiplist = map[?"equipment"];
		if (ds_list_valid(equiplist))
		{
			for (var i = 0; i < ds_list_size(equiplist); i++)
			{
				var model = model_load(equiplist[|i], load_assets_dir + mc_equipment_directory);
				if (!model) // Something went wrong!
				{
					log("Could not load model")
					continue
				}

				model_name_map[?model.name] = model
				ds_list_add(equipment_list, model)
			}
		}
		
		// Special blocks
		var spblocklist = map[?"special_blocks"];
		if (!ds_list_valid(spblocklist))
		{
			log("No special block list found")
			break
		}
		
		for (var i = 0; i < ds_list_size(spblocklist); i++)
		{
			var model, entity;
			model = model_load(spblocklist[|i], load_assets_dir + mc_special_block_directory)
			if (!model) // Something went wrong!
			{
				log("Could not load model")
				continue
			}
			
			model_name_map[?model.name] = model
			
			ds_list_add(special_block_list, model)

			entity = spblocklist[|i][?"entity"]
			if (is_string(entity))
				entity_model_map[?string_lower(string_replace(entity, "minecraft:", ""))] = model
		}
		
		// Item place targets
		minecraft_assets_load_item_place_target(map[?"item_place_target"])
		
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
		if (type = e_temp_type.CHARACTER || type = e_temp_type.EQUIPMENT || type = e_temp_type.SPECIAL_BLOCK)
			temp_update_model()
	
	with (obj_timeline)
		tl_update_scenery_part()
}

/// legacy_startup()
/// @desc Load various lookup tables from the legacy.midata file for loading old formats.

function legacy_startup()
{
	globalvar legacy_model_id_05_map, legacy_model_id_06_map, legacy_model_id_100_demo_map;
	globalvar legacy_model_part_map, legacy_model_name_map;
	globalvar legacy_block_set, legacy_block_id, legacy_block_obj, legacy_block_state_vars, legacy_block_state_id, legacy_block_mc_id;
	globalvar legacy_block_texture_name_map, legacy_block_05_texture_list, legacy_block_07_demo_texture_list, legacy_block_100_texture_list;
	globalvar legacy_item_texture_name_map;
	globalvar legacy_biomes_map, legacy_biomes_ids_map, biomes_ids_map, legacy_model_names_map, legacy_model_states_map, legacy_model_state_values_map, legacy_block_names_map, legacy_block_states_map, legacy_block_state_values_map, legacy_particles_map;
	
	var map = json_load(legacy_file);
	if (!ds_map_valid(map))
	{
		log("Error loading legacy.midata")
		return false
	}
	log("Loading legacy file", legacy_file)
	
	// Models
	legacy_model_id_05_map = map[?"legacy_model_id_05"]
	legacy_model_id_06_map = map[?"legacy_model_id_06"]
	legacy_model_id_100_demo_map = map[?"legacy_model_id_100_demo"]
	
	ds_map_merge(legacy_model_id_05_map, map[?"legacy_model_id"])
	ds_map_merge(legacy_model_id_06_map, map[?"legacy_model_id"])
	ds_map_merge(legacy_model_id_100_demo_map, map[?"legacy_model_id"])
	
	legacy_model_part_map = map[?"legacy_model_part"]
	legacy_model_name_map = map[?"legacy_model_name"]
	
	// Blocks
	legacy_block_set[255] = false
	legacy_block_id = map[?"legacy_block_id"]
	legacy_block_texture_name_map = map[?"legacy_block_texture_name"]
	legacy_block_05_texture_list = map[?"legacy_block_05_textures"]
	legacy_block_07_demo_texture_list = map[?"legacy_block_07_demo_textures"]
	legacy_block_100_texture_list = map[?"legacy_block_100_textures"]
	
	for (var i = 0; i < 256; i++)
	{
		for (var d = 0; d < 16; d++)
		{
			legacy_block_obj[i, d] = null
			legacy_block_state_id[i, d] = 0
			legacy_block_mc_id[i, d] = ""
		}
	}
	
	// Items
	legacy_item_texture_name_map = map[?"legacy_item_texture_name"]
	
	// Biomes
	legacy_biomes_map = map[?"legacy_biomes"]
	legacy_biomes_ids_map = ds_int_map_create()
	var key = ds_map_find_first(map[?"legacy_biome_ids"]);
	while (!is_undefined(key))
	{
		legacy_biomes_ids_map[?string_get_real(key)] = ds_map_find_value(map[?"legacy_biome_ids"], key)
		key = ds_map_find_next(map[?"legacy_biome_ids"], key)
	}
	
	biomes_ids_map = ds_int_map_create()
	key = ds_map_find_first(map[?"biome_ids"]);
	while (!is_undefined(key))
	{
		biomes_ids_map[?string_get_real(key)] = ds_map_find_value(map[?"biome_ids"], key)
		key = ds_map_find_next(map[?"biome_ids"], key)
	}
		
	// Model names
	legacy_model_names_map = map[?"legacy_model_names"]
	
	// Model states
	legacy_model_states_map = map[?"legacy_model_states"]
	
	legacy_model_state_values_map = map[?"legacy_model_state_values"]
	
	// Block names
	legacy_block_names_map = map[?"legacy_block_names"]
	
	// Block states
	legacy_block_states_map = map[?"legacy_block_states"]
	
	legacy_block_state_values_map = map[?"legacy_block_state_values"]
	
	// Particles
	legacy_particles_map = map[?"legacy_particles"]
	
	return true
}

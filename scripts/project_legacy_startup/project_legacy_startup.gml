/// project_legacy_startup()

globalvar legacy_model_id_map, legacy_model_id_05_map, legacy_model_id_06_map, legacy_model_id_100_demo_map;
globalvar legacy_model_part_map, legacy_model_name_map;
globalvar legacy_block_05_texture_list, legacy_block_07_demo_texture_list, legacy_block_100_texture_list;

legacy_model_id_map = null
legacy_model_id_05_map = null
legacy_model_id_06_map = null
legacy_model_id_100_demo_map = null
legacy_model_part_map = null
legacy_model_name_map = null

var map = json_load(legacy_file);
if (!ds_map_valid(map))
	return false
		
legacy_model_id_map = map[?"legacy_model_id_map"]
legacy_model_id_05_map = map[?"legacy_model_id_05_map"]
legacy_model_id_06_map = map[?"legacy_model_id_06_map"]
legacy_model_id_100_demo_map = map[?"legacy_model_id_100_demo_map"]
	
ds_map_merge(legacy_model_id_05_map, legacy_model_id_map)
ds_map_merge(legacy_model_id_06_map, legacy_model_id_map)
ds_map_merge(legacy_model_id_100_demo_map, legacy_model_id_map)
	
legacy_model_part_map = map[?"legacy_model_part_map"]
legacy_model_name_map = map[?"legacy_model_name_map"]

legacy_block_05_texture_list = map[?"legacy_block_05_textures"]
legacy_block_07_demo_texture_list = map[?"legacy_block_07_demo_textures"]
legacy_block_100_texture_list = map[?"legacy_block_100_textures"]

return true
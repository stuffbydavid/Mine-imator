/// project_legacy_startup()

globalvar legacy_model_id_map, legacy_model_id_05_map, legacy_model_id_06_map, legacy_model_id_100_demo_map;
globalvar legacy_model_part_map, legacy_model_name_map;

legacy_model_id_map = null
legacy_model_id_05_map = null
legacy_model_id_06_map = null
legacy_model_id_100_demo_map = null
legacy_model_part_map = null
legacy_model_name_map = null

var json, rootmap;
json = file_text_contents(legacy_file)
rootmap = json_decode(json)
if (rootmap < 0)
	return false
		
legacy_model_id_map = rootmap[?"legacy_model_id_map"]
legacy_model_id_05_map = rootmap[?"legacy_model_id_05_map"]
legacy_model_id_06_map = rootmap[?"legacy_model_id_06_map"]
legacy_model_id_100_demo_map = rootmap[?"legacy_model_id_100_demo_map"]
	
ds_map_merge(legacy_model_id_05_map, legacy_model_id_map)
ds_map_merge(legacy_model_id_06_map, legacy_model_id_map)
ds_map_merge(legacy_model_id_100_demo_map, legacy_model_id_map)
	
legacy_model_part_map = rootmap[?"legacy_model_part_map"]
legacy_model_name_map = rootmap[?"legacy_model_name_map"]

return true
/// project_load_legacy_model_name(id)
/// @arg id

var modelid = argument0;

if (load_format >= e_project.FORMAT_100_DEMO_2)
	return legacy_model_id_100_demo_map[?string(modelid)]
else if (load_format >= e_project.FORMAT_06)
	return legacy_model_id_06_map[?string(modelid)]
else
	return legacy_model_id_05_map[?string(modelid)]

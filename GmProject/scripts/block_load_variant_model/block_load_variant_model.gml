/// block_load_variant_model(map, type)
/// @arg type

function block_load_variant_model(map, type)
{
	if (is_undefined(map[?"model"]))
	{
		log("Missing parameter \"model\"")
		return false
	}
	
	// Model
	var blockname, blockmodel;
	blockname = string_replace(map[?"model"], "minecraft:", "")
	blockmodel = block_load_model_file(load_assets_dir + mc_models_directory + blockname + ".json")
	
	if (!blockmodel)
		return false
	
	// Rotation
	var rot = vec3(0, 0, 0);
	if (!is_undefined(map[?"x"]))
		rot[X] = clamp(snap(map[?"x"], 90), 0, 270)
	if (!is_undefined(map[?"y"]))
		rot[Z] = clamp(snap(map[?"y"], 90), 0, 270)
	if (!is_undefined(map[?"z"]))
		rot[Y] = clamp(snap(map[?"z"], 90), 0, 270)
	
	// UV lock
	var uvlock = false;
	if (is_bool(map[?"uvlock"]))
		uvlock = map[?"uvlock"]
	else if (is_string(map[?"uvlock"]))
		uvlock = (map[?"uvlock"] = "true")
		
	// Weight
	var weight = 1;
	if (!is_undefined(map[?"weight"]))
		weight = map[?"weight"]
	total_weight += weight
	
	model_state_obj = other
	
	// Create model for rendering
	model[model_amount] = block_load_render_model(blockmodel, rot, uvlock, false, weight)
	
	if (type = "leaves") // For "Opaque leaves" setting
		model[model_amount].opaque = block_load_render_model(blockmodel, rot, uvlock, true, weight)
	
	model_amount++
	
	return true
}

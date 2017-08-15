/// block_load_state_models(list, type)
/// @arg list
/// @arg type

var list, type;
list = argument0
type = argument1

model_amount = 0
total_weight = 0

for (var i = 0; i < ds_list_size(list); i++)
{
	var modelmap = list[|i];
	if (is_undefined(modelmap[?"model"]))
	{
		log("Missing parameter \"model\"")
		return false
	}
			
	// Model
	var blockmodel = block_load_model_file("block/" + modelmap[?"model"] + ".json")
	if (!blockmodel)
		return false
				
	// Rotation
	var rot = vec3(0, 0, 0);
	if (!is_undefined(modelmap[?"x"]))
		rot[X] = clamp(snap(modelmap[?"x"], 90), 0, 270)
	if (!is_undefined(modelmap[?"y"]))
		rot[Z] = clamp(snap(modelmap[?"y"], 90), 0, 270)
	
	// UV lock
	var uvlock = false;
	if (!is_undefined(modelmap[?"uvlock"]))
		uvlock = (modelmap[?"uvlock"] = "true")
					
	// Weight
	var weight = 1;
	if (!is_undefined(modelmap[?"weight"]))
		weight = modelmap[?"weight"]
	total_weight += weight
				
	// Create model for rendering
	model[model_amount] = block_load_render_model(blockmodel, rot, uvlock, false, weight)
	
	if (type = "leaves") // For "Opaque leaves" setting
		model_opaque[model_amount] = block_load_render_model(blockmodel, rot, uvlock, true, weight)
	
	model_amount++
}

return true
/// block_load_variant_model(map, type)
/// @arg type

var map, type;
map = argument0
type = argument1

if (is_undefined(map[?"model"]))
{
	log("Missing parameter \"model\"")
	return false
}
			
// Model
var blockmodel = block_load_model_file(load_assets_dir + mc_models_directory + "block/" + map[?"model"] + ".json")
if (!blockmodel)
	return false
				
// Rotation
var rot = vec3(0, 0, 0);
if (!is_undefined(map[?"x"]))
	rot[X] = clamp(snap(map[?"x"], 90), 0, 270)
if (!is_undefined(map[?"y"]))
	rot[Z] = clamp(snap(map[?"y"], 90), 0, 270)
	
// UV lock
var uvlock = false;
if (is_real(map[?"uvlock"]))
	uvlock = map[?"uvlock"]
else if (is_string(map[?"uvlock"]))
	uvlock = (map[?"uvlock"] = "true")
					
// Weight
var weight = 1;
if (!is_undefined(map[?"weight"]))
	weight = map[?"weight"]
total_weight += weight
				
// Create model for rendering
model[model_amount] = block_load_render_model(blockmodel, rot, uvlock, false, weight)
	
if (type = "leaves") // For "Opaque leaves" setting
	model[model_amount].opaque = block_load_render_model(blockmodel, rot, uvlock, true, weight)
	
model_amount++

return true